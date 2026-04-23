package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.StudentProfile;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

public class MOAiMatchServlet extends HttpServlet {
    private static final Gson GSON = new Gson();

    // ⚠️ 建议测试完成后，去阿里云后台把这个 Key 删掉重新生成一个，防止被盗用额度
    private static final String QWEN_API_KEY = "sk-b1563cddb70642b2907dcb49fb883fca";
    private static final String QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String jobId = request.getParameter("jobId");

        try {
            Job targetJob = findJobById(jobId);
            if (targetJob == null) { response.getWriter().write("[]"); return; }

            // 1. 调用最新重写的精准名单获取方法
            List<String> applicantIds = getApplicantIds(jobId);
            if (applicantIds.isEmpty()) { response.getWriter().write("[]"); return; }

            // ====== 2. 构建候选人与岗位的全量上下文 ======
            StudentProfileDao profileDao = new StudentProfileDao();
            StringBuilder candidatesContext = new StringBuilder();

            for (String sId : applicantIds) {
                StudentProfile profile = profileDao.getByEnrollment(sId);
                if (profile != null) {
                    candidatesContext.append("### Candidate ID: ").append(sId).append(" ###\n");
                    candidatesContext.append("[Logistics] Campus Preference: ").append(profile.getCampusPreference() != null ? profile.getCampusPreference() : "N/A").append("\n");
                    candidatesContext.append("[Logistics] Availability: ").append(profile.getAvailability() != null ? profile.getAvailability() : "N/A").append("\n");
                    candidatesContext.append("[Academic] Major: ").append(profile.getMajorProgramme() != null ? profile.getMajorProgramme() : "N/A").append("\n");
                    candidatesContext.append("[Academic] Grade: ").append(profile.getGrade() != null ? profile.getGrade() : "N/A").append("\n");
                    candidatesContext.append("[Skills] Stated: ").append(profile.getSkills() != null ? profile.getSkills() : "N/A").append("\n");

                    String pdfText = extractTextFromPdf(request, profile.getResumePath());
                    if (!pdfText.isEmpty()) {
                        candidatesContext.append("[PDF Resume Extract]:\n").append(pdfText).append("\n");
                    }
                    candidatesContext.append("\n---\n");
                }
            }

            // ====== 3. MO 视角的 Prompt ======
            String systemPrompt = "You are an expert University Module Organizer (MO) hiring a Teaching/Lab Assistant. " +
                    "Evaluate candidates based on 3 dimensions: " +
                    "1) Logistics & Requirements: Check if the candidate's Campus Preference, Availability, and Major match the Job's Location, Working Hours, and Preferred Major. " +
                    "2) Technical Match: Assess hard skills from stated skills and PDF resume. " +
                    "3) Mentoring Potential: Look for teaching interest, empathy, or communication skills in the resume. " +
                    "Output ONLY a valid JSON array. Format: [{\"studentId\":\"ID\", \"score\": 85, \"reason\":\"• Logistics: ...\\n• Technical: ...\\n• Mentoring: ...\"}] " +
                    "The 'reason' MUST be exactly 3 bullet points separated by newline (\\n).";

            String userPrompt = "Job Info:\n" +
                    "- Title: " + targetJob.getJobTitle() + "\n" +
                    "- Location/Campus: " + targetJob.getLocation() + "\n" +
                    "- Working Hours: " + targetJob.getWorkingHours() + "\n" +
                    "- Preferred Major: " + targetJob.getPreferredMajor() + "\n" +
                    "- CGPA Required: " + targetJob.getCgpaRequired() + "\n" +
                    "- Required Skills: " + targetJob.getRequiredSkills() + "\n\n" +
                    "Candidates Data:\n" + candidatesContext.toString();

            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "qwen-plus");
            JsonArray messages = new JsonArray();
            JsonObject sysMsg = new JsonObject(); sysMsg.addProperty("role", "system"); sysMsg.addProperty("content", systemPrompt);
            JsonObject userMsg = new JsonObject(); userMsg.addProperty("role", "user"); userMsg.addProperty("content", userPrompt);
            messages.add(sysMsg); messages.add(userMsg);
            requestBody.add("messages", messages);

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(60)).build();
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(QWEN_API_URL))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + QWEN_API_KEY)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody.toString()))
                    .build();

            HttpResponse<String> aiResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            String responseBody = aiResponse.body();

            System.out.println(">>> [Debug] AI 原始返回报文: " + responseBody);

            JsonObject jsonRes = GSON.fromJson(responseBody, JsonObject.class);

            // 🚨 增加了防爆盾：确保有 choices 才去解析，防止报 NullPointerException
            if (jsonRes.has("choices")) {
                String aiResultText = jsonRes.getAsJsonArray("choices").get(0).getAsJsonObject()
                        .getAsJsonObject("message").get("content").getAsString();

                aiResultText = aiResultText.replace("```json", "").replace("```", "").trim();

                // ====== 4. 把 resumePath 和其他信息传给前端 ======
                JsonArray aiResultsArray = GSON.fromJson(aiResultText, JsonArray.class);
                for (JsonElement element : aiResultsArray) {
                    JsonObject obj = element.getAsJsonObject();
                    String sId = obj.get("studentId").getAsString();
                    StudentProfile p = profileDao.getByEnrollment(sId);

                    if (p != null) {
                        obj.addProperty("name", p.getFullName() != null ? p.getFullName() : "Unknown");
                        obj.addProperty("major", p.getMajorProgramme() != null ? p.getMajorProgramme() : "Unknown");
                        obj.addProperty("resumePath", p.getResumePath() != null ? p.getResumePath() : "");
                    }
                }
                response.getWriter().write(GSON.toJson(aiResultsArray));
            } else {
                System.err.println(">>> [Error] 大模型接口报错: " + responseBody);
                response.setStatus(500);
                response.getWriter().write("{\"error\": \"AI 接口调用失败，请检查控制台\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\": \"Server failed: " + e.getMessage() + "\"}");
        }
    }

    private String extractTextFromPdf(HttpServletRequest request, String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) return "";
        String realPath = request.getServletContext().getRealPath("/") + relativePath;
        File pdfFile = new File(realPath);
        if (!pdfFile.exists()) return "";
        try (PDDocument document = PDDocument.load(pdfFile)) {
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setEndPage(2);
            return stripper.getText(document).trim();
        } catch (IOException e) { return ""; }
    }

    private Job findJobById(String id) {
        for (Job j : new JobDao().getAllJobs()) {
            if (j.getJobId().equals(id)) return j;
        }
        return null;
    }

    // 🌟 核心修复：完美适配你的按行存储 (NDJSON) 的 applications.json
    private List<String> getApplicantIds(String jobId) {
        List<String> ids = new ArrayList<>();
        File file = new File(ApplicationDao.getFilePath());
        if (!file.exists()) return ids;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            // 逐行读取，因为你的每一行都是一个独立的 JSON 对象
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                try {
                    JsonObject app = GSON.fromJson(line, JsonObject.class);
                    if (app.has("jobId") && app.has("studentId")) {
                        String currentJobId = app.get("jobId").getAsString();
                        String status = app.has("status") ? app.get("status").getAsString() : "Pending";

                        // 只有 jobId 匹配，且状态为 Pending 的人才进入 AI 筛选
                        boolean isPending = !"Accepted".equalsIgnoreCase(status) && !"Rejected".equalsIgnoreCase(status);

                        if (currentJobId.equals(jobId) && isPending) {
                            ids.add(app.get("studentId").getAsString());
                        }
                    }
                } catch (Exception e) {
                    // 忽略格式错误的行，继续下一行
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println(">>> [Debug] 最终提交给大模型筛选的待定名单: " + ids);
        return ids;
    }
}
