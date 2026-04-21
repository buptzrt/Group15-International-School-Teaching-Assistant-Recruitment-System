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
import jakarta.servlet.annotation.WebServlet;
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

//站在 MO 角度怎么选人？
//真实的 MO 选人逻辑是**“三维漏斗”**：
//
//第一关（后勤与硬性条件）：时间地点冲不冲突？专业对不对口？
//
//第二关（技术实力）：技术能不能胜任 Lab Assistant？
//
//第三关（软素质）：有没有辅导耐心和表达能力？

// 注意：这里删除了 @WebServlet 注解，因为我们在 web.xml 中注册了，避免冲突
public class MOAiMatchServlet extends HttpServlet {
    private static final Gson GSON = new Gson();

    // ⚠️ 记得填入你的 API KEY
    private static final String QWEN_API_KEY = "sk-b1563cddb70642b2907dcb49fb883fca";
    private static final String QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String jobId = request.getParameter("jobId");

        try {
            Job targetJob = findJobById(jobId);
            if (targetJob == null) { response.getWriter().write("[]"); return; }

            List<String> applicantIds = getApplicantIds(jobId);
            if (applicantIds.isEmpty()) { response.getWriter().write("[]"); return; }

            // ====== 1. 构建候选人与岗位的全量上下文 ======
            StudentProfileDao profileDao = new StudentProfileDao();
            StringBuilder candidatesContext = new StringBuilder();

            for (String sId : applicantIds) {
                StudentProfile profile = profileDao.getByEnrollment(sId);
                if (profile != null) {
                    candidatesContext.append("### Candidate ID: ").append(sId).append(" ###\n");
                    // 补充完整的硬性条件
                    candidatesContext.append("[Logistics] Campus Preference: ").append(profile.getCampusPreference()).append("\n");
                    candidatesContext.append("[Logistics] Availability: ").append(profile.getAvailability()).append("\n");
                    candidatesContext.append("[Academic] Major: ").append(profile.getMajorProgramme()).append("\n");
                    candidatesContext.append("[Academic] Grade: ").append(profile.getGrade()).append("\n");
                    candidatesContext.append("[Skills] Stated: ").append(profile.getSkills()).append("\n");

                    String pdfText = extractTextFromPdf(request, profile.getResumePath());
                    if (!pdfText.isEmpty()) {
                        candidatesContext.append("[PDF Resume Extract]:\n").append(pdfText).append("\n");
                    }
                    candidatesContext.append("\n---\n");
                }
            }

            // ====== 2. 🌟 终极版 MO 视角的 Prompt ======
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
            JsonObject jsonRes = GSON.fromJson(aiResponse.body(), JsonObject.class);
            String aiResultText = jsonRes.getAsJsonArray("choices").get(0).getAsJsonObject()
                    .getAsJsonObject("message").get("content").getAsString();

            aiResultText = aiResultText.replace("```json", "").replace("```", "").trim();

            // ====== 3. 🌟 把 resumePath 一起发给前端 ======
            JsonArray aiResultsArray = GSON.fromJson(aiResultText, JsonArray.class);
            for (JsonElement element : aiResultsArray) {
                JsonObject obj = element.getAsJsonObject();
                String sId = obj.get("studentId").getAsString();
                StudentProfile p = profileDao.getByEnrollment(sId);

                if (p != null) {
                    obj.addProperty("name", p.getFullName() != null ? p.getFullName() : "Unknown");
                    obj.addProperty("major", p.getMajorProgramme() != null ? p.getMajorProgramme() : "Unknown");
                    // 新增：把 PDF 路径传给前端
                    obj.addProperty("resumePath", p.getResumePath() != null ? p.getResumePath() : "");
                }
            }
            response.getWriter().write(GSON.toJson(aiResultsArray));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\": \"AI service failed: " + e.getMessage() + "\"}");
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

    private List<String> getApplicantIds(String jobId) throws IOException {
        List<String> ids = new ArrayList<>();
        File file = new File(ApplicationDao.getFilePath());
        if (file.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.contains("\"jobId\":\"" + jobId + "\"")) {
                        ids.add(line.split("\"studentId\":\"")[1].split("\"")[0]);
                    }
                }
            }
        }
        return ids;
    }
}
