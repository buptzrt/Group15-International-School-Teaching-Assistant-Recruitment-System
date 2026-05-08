package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.model.User;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class StudentResumeUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new Gson();
    private static final String RESUME_RELATIVE_DIR = "resumes";

    // ⚠️ 填入你的千问 API Key
    private static final String QWEN_API_KEY = "sk-b1563cddb70642b2907dcb49fb883fca";
    private static final String QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("enrollment_no") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                return;
            }

            String enrollmentNo = (String) session.getAttribute("enrollment_no");
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "No file selected")));
                return;
            }

            String fileName = extractFileName(filePart);
            String fileExtension = getFileExtension(fileName);
            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;

            // --- 1. 执行你的双路同步保存逻辑 ---
            List<Path> uploadPaths = new ArrayList<>();
            String runtimeBaseDir = getServletContext().getRealPath("/");
            if (runtimeBaseDir != null) {
                uploadPaths.add(Paths.get(runtimeBaseDir).resolve(RESUME_RELATIVE_DIR).normalize());
                int targetIndex = runtimeBaseDir.indexOf(File.separator + "target" + File.separator);
                if (targetIndex == -1) targetIndex = runtimeBaseDir.indexOf("/target/");
                int outIndex = runtimeBaseDir.indexOf(File.separator + "out" + File.separator + "artifacts");
                if (outIndex == -1) outIndex = runtimeBaseDir.indexOf("/out/artifacts");

                String projectRootPath = null;
                if (targetIndex != -1) projectRootPath = runtimeBaseDir.substring(0, targetIndex);
                else if (outIndex != -1) projectRootPath = runtimeBaseDir.substring(0, outIndex);

                if (projectRootPath != null) {
                    File srcFolder = new File(projectRootPath, "src/main/webapp/" + RESUME_RELATIVE_DIR);
                    if (!srcFolder.getParentFile().exists()) srcFolder = new File(projectRootPath, "TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
                    if (!srcFolder.getParentFile().exists()) srcFolder = new File(projectRootPath, "TA_System/TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
                    uploadPaths.add(srcFolder.toPath().normalize());
                }
            }

            File targetFileForAI = null;
            for (Path resumeDir : uploadPaths) {
                if (!Files.exists(resumeDir)) Files.createDirectories(resumeDir);
                Path targetFile = resumeDir.resolve(uniqueFileName).normalize();
                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
                }
                targetFileForAI = targetFile.toFile(); // 记录一个文件用来给AI读取
            }

            String resumePath = RESUME_RELATIVE_DIR + "/" + uniqueFileName;

            // 更新数据库
            StudentProfileDao profileDao = new StudentProfileDao();
            StudentProfile studentProfile = profileDao.getByEnrollment(enrollmentNo);
            if (studentProfile == null) {
                studentProfile = new StudentProfile();
                studentProfile.setEnrollmentNo(enrollmentNo);
            }
            studentProfile.setResumePath(resumePath);
            profileDao.save(studentProfile);

            // --- 2. 🚀 核心重构：调用 AI 解析 PDF ---
            JsonObject aiParsedData = new JsonObject();
            if (targetFileForAI != null && "pdf".equals(fileExtension)) {
                String pdfText = extractTextFromPdf(targetFileForAI);
                if (!pdfText.isEmpty()) {
                    System.out.println(">>> [AI Auto-fill] 开始解析简历，长度: " + pdfText.length());
                    aiParsedData = extractInfoWithAI(pdfText);
                }
            }

            // --- 3. 将解析结果返回给前端 ---
            ApiResponse apiResponse = new ApiResponse(true, "File uploaded and parsed successfully", resumePath);
            apiResponse.parsedData = aiParsedData; // 把 AI 提取的 JSON 挂载到返回包里

            response.getWriter().write(GSON.toJson(apiResponse));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ApiResponse(false, "Upload error: " + e.getMessage())));
        }
    }

    // --- 提取 PDF 文本 ---
    private String extractTextFromPdf(File pdfFile) {
        try (PDDocument document = PDDocument.load(pdfFile)) {
            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setEndPage(2); // 只读前2页，省Token
            String text = stripper.getText(document).trim();
            // 防爆截断：最多保留 2000 个字符
            return text.length() > 2000 ? text.substring(0, 2000) : text;
        } catch (IOException e) { return ""; }
    }

    // --- 调用 Qwen 大模型进行 JSON 信息提取 ---
    private JsonObject extractInfoWithAI(String pdfText) {
        try {
            // 🌟 升级版 Prompt：严禁 AI 总结或篡改长文本经历，必须原样复制 (Verbatim)！
            String systemPrompt = "You are a Resume Parsing Assistant. Extract the candidate's info from the text. " +
                    "Output STRICTLY a valid JSON object. Do not include markdown code blocks. " +
                    "If a field is not found, leave it as an empty string \"\". " +
                    "Keys required: fullName, chineseName, gender, qmId, buptId, buptClass, majorProgramme, grade, email, mobilePhone, wechatId, skills, " +
                    "projectExperience, taExperience, selfEvaluation. " +
                    "For 'skills', extract keywords separated by commas. " +
                    "CRITICAL RULE FOR LONG TEXT: For 'projectExperience', 'taExperience', and 'selfEvaluation', you MUST extract the EXACT original text verbatim from the resume. " +
                    "Do NOT summarize. Do NOT paraphrase. Do NOT infer. Just copy and paste the relevant original sentences or bullet points exactly as they appear in the provided text.";

            String userPrompt = "Resume Text:\n" + pdfText;

            com.google.gson.JsonArray messages = new com.google.gson.JsonArray();
            JsonObject sysMsg = new JsonObject(); sysMsg.addProperty("role", "system"); sysMsg.addProperty("content", systemPrompt);
            JsonObject userMsg = new JsonObject(); userMsg.addProperty("role", "user"); userMsg.addProperty("content", userPrompt);
            messages.add(sysMsg); messages.add(userMsg);

            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "qwen-plus");
            requestBody.add("messages", messages);

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(30)).build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(QWEN_API_URL))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + QWEN_API_KEY)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody.toString()))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            JsonObject jsonRes = GSON.fromJson(response.body(), JsonObject.class);

            if (jsonRes.has("choices")) {
                String content = jsonRes.getAsJsonArray("choices").get(0).getAsJsonObject()
                        .getAsJsonObject("message").get("content").getAsString();
                content = content.replace("```json", "").replace("```", "").trim();
                return GSON.fromJson(content, JsonObject.class);
            }
        } catch (Exception e) {
            System.err.println(">>> [Error] AI 解析简历失败: " + e.getMessage());
        }
        return new JsonObject(); // 如果失败，返回空对象，不影响主流程
    }

    // --- 工具类方法保持不变 ---
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String s : contentDisp.split(";")) {
            if (s.trim().startsWith("filename")) return s.substring(s.indexOf('=') + 1).trim().replace("\"", "");
        }
        return "upload_" + System.currentTimeMillis();
    }
    private String getFileExtension(String fileName) { return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase(); }

    static class ApiResponse {
        boolean success; String message; String path;
        JsonObject parsedData; // 新增字段，用于承载 AI 解析结果

        ApiResponse(boolean success, String message) { this.success = success; this.message = message; }
        ApiResponse(boolean success, String message, String path) { this.success = success; this.message = message; this.path = path; }
    }
}
