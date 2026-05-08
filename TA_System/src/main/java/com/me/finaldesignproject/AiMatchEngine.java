package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.StudentProfile;

import java.io.*;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import com.google.gson.JsonElement;


//具体逻辑如下：
//每一次前端（无论是学生还是 MO）呼叫 AiMatchEngine.evaluate() 时，引擎都会做两步检查：
//
//看有没有缓存？
//
//看缓存有没有过期？（对比缓存的 timestamp 和简历/岗位 JSON 文件的最后修改时间）。
//总结： 我们的引擎是完全中立的公共服务。谁第一个在数据变动后去查分数，谁就负责“等”大模型算完并生成缓存；后来的人（不管是 MO 还是学生）就直接享受秒出的缓存成果。
public class AiMatchEngine {
    private static final Gson GSON = new Gson();
    // ⚠️ 填入你的真实 API Key
    private static final String QWEN_API_KEY = "sk-b1563cddb70642b2907dcb49fb883fca";
    private static final String QWEN_API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";

    // 缓存文件路径
    private static final String CACHE_FILE_NAME = "ai_match_cache.json";

    /**
     * 内部类：统一的返回结果结构
     */
    public static class MatchResult {
        public int score;
        public String reason;
        public long timestamp; // 记录生成时间

        public MatchResult(int score, String reason, long timestamp) {
            this.score = score;
            this.reason = reason;
            this.timestamp = timestamp;
        }
    }

    /**
     * 获取缓存文件的绝对路径
     */
    private static String getCacheFilePath() {
        String baseDir = ApplicationDao.getFilePath().replace("applications.json", "");
        return baseDir + CACHE_FILE_NAME;
    }

    /**
     * 🌟 核心引擎入口：带智能缓存的匹配度计算
     */
    public static MatchResult evaluate(Job job, StudentProfile profile, String pdfText) {
        String cacheKey = job.getJobId() + "_" + profile.getStudentId();

        // 1. 尝试读取缓存
        MatchResult cachedResult = readFromCache(cacheKey);

        // 2. 智能判断缓存是否过期
        // 原理：比较缓存的 timestamp 和 student_profiles.json / jobs.json 的最后修改时间
        long profilesLastMod = new File(ApplicationDao.getFilePath().replace("applications.json", "student_profiles.json")).lastModified();
        long jobsLastMod = new File(ApplicationDao.getFilePath().replace("applications.json", "jobs.json")).lastModified();

        boolean isCacheValid = cachedResult != null &&
                cachedResult.timestamp > profilesLastMod &&
                cachedResult.timestamp > jobsLastMod;

        if (isCacheValid) {
            System.out.println(">>> [AiEngine] 命中有效缓存，0ms返回！CacheKey: " + cacheKey);
            return cachedResult;
        }

        System.out.println(">>> [AiEngine] 缓存未命中或已过期，呼叫大模型重新计算... CacheKey: " + cacheKey);

        // 3. 如果没缓存或已过期，调用大模型
        MatchResult freshResult = callAiForEvaluation(job, profile, pdfText);

        // 4. 保存新结果到缓存
        if (freshResult != null) {
            saveToCache(cacheKey, freshResult);
        }

        return freshResult;
    }

    /**
     * 🧠 呼叫大模型进行三维打分
     */
    private static MatchResult callAiForEvaluation(Job job, StudentProfile profile, String pdfText) {
        try {
            // 构建学生的完整上下文（包含了我们上一战役新增的三个重要字段！）
            StringBuilder candidateData = new StringBuilder();
            candidateData.append("[Logistics] Campus: ").append(profile.getCampusPreference()).append("\n");
            candidateData.append("[Logistics] Availability: ").append(profile.getAvailability()).append("\n");
            candidateData.append("[Academic] Major: ").append(profile.getMajorProgramme()).append("\n");
            candidateData.append("[Academic] Grade: ").append(profile.getGrade()).append("\n");
            candidateData.append("[Skills] Stated: ").append(profile.getSkills()).append("\n");
            candidateData.append("[Experience] Projects: ").append(profile.getProjectExperience()).append("\n");
            candidateData.append("[Experience] TA/Mentoring: ").append(profile.getTaExperience()).append("\n");
            candidateData.append("[Soft Skills] Self Eval: ").append(profile.getSelfEvaluation()).append("\n");
            if (pdfText != null && !pdfText.isEmpty()) {
                candidateData.append("[PDF Resume Extract]:\n").append(pdfText).append("\n");
            }

            // 严格的系统提示词，强制要求 JSON 输出
            String systemPrompt = "You are an expert University Module Organizer (MO) hiring a Teaching/Lab Assistant. " +
                    "Evaluate the candidate against the Job Requirements based on 3 dimensions:\n" +
                    "1) Logistics & Requirements: Check Campus Preference, Availability, and Major match.\n" +
                    "2) Technical Match: Assess hard skills and Project Experience.\n" +
                    "3) Mentoring Potential: Assess TA Experience and Soft Skills.\n" +
                    "Output STRICTLY a JSON object without markdown blocks. Format: {\"score\": 85, \"reason\":\"• Logistics: ...\\n• Technical: ...\\n• Mentoring: ...\"}\n" +
                    "The 'reason' MUST be exactly 3 bullet points separated by newline (\\n). Be extremely objective and critical.";

            String userPrompt = "Job Info:\n" +
                    "- Title: " + job.getJobTitle() + "\n" +
                    "- Location/Campus: " + job.getLocation() + "\n" +
                    "- Working Hours: " + job.getWorkingHours() + "\n" +
                    "- Preferred Major: " + job.getPreferredMajor() + "\n" +
                    "- Required Skills: " + job.getRequiredSkills() + "\n\n" +
                    "Candidate Data:\n" + candidateData.toString();

            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "qwen-plus");
            com.google.gson.JsonArray messages = new com.google.gson.JsonArray();
            JsonObject sysMsg = new JsonObject(); sysMsg.addProperty("role", "system"); sysMsg.addProperty("content", systemPrompt);
            JsonObject userMsg = new JsonObject(); userMsg.addProperty("role", "user"); userMsg.addProperty("content", userPrompt);
            messages.add(sysMsg); messages.add(userMsg);
            requestBody.add("messages", messages);

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(45)).build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(QWEN_API_URL))
                    .timeout(Duration.ofSeconds(60)) //
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + QWEN_API_KEY)
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody.toString()))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            JsonObject jsonRes = GSON.fromJson(response.body(), JsonObject.class);

            if (jsonRes.has("choices")) {
                String aiResultText = jsonRes.getAsJsonArray("choices").get(0).getAsJsonObject()
                        .getAsJsonObject("message").get("content").getAsString();
                aiResultText = aiResultText.replace("```json", "").replace("```", "").trim();

                JsonObject resultObj = GSON.fromJson(aiResultText, JsonObject.class);
                int score = resultObj.has("score") ? resultObj.get("score").getAsInt() : 0;
                String reason = resultObj.has("reason") ? resultObj.get("reason").getAsString() : "No reason provided.";

                return new MatchResult(score, reason, System.currentTimeMillis());
            }
        } catch (Exception e) {
            System.err.println(">>> [Error] Engine 打分失败: " + e.getMessage());
        }
        return new MatchResult(0, "AI Analysis Error. Please manually review the resume.", System.currentTimeMillis());
    }

    // --- 缓存读写操作 ---
    private static MatchResult readFromCache(String cacheKey) {
        File file = new File(getCacheFilePath());
        if (!file.exists()) return null;
        try (FileReader reader = new FileReader(file)) {
            JsonObject cacheMap = JsonParser.parseReader(reader).getAsJsonObject();
            if (cacheMap.has(cacheKey)) {
                return GSON.fromJson(cacheMap.get(cacheKey), MatchResult.class);
            }
        } catch (Exception e) { System.err.println(">>> Cache read error: " + e.getMessage()); }
        return null;
    }

    private static synchronized void saveToCache(String cacheKey, MatchResult result) {
        File file = new File(getCacheFilePath());
        JsonObject cacheMap = new JsonObject();
        try {
            if (file.exists()) {
                try (FileReader reader = new FileReader(file)) {
                    JsonElement parsed = JsonParser.parseReader(reader);
                    if (parsed.isJsonObject()) cacheMap = parsed.getAsJsonObject();
                }
            }
            cacheMap.add(cacheKey, GSON.toJsonTree(result));
            try (FileWriter writer = new FileWriter(file)) {
                GSON.toJson(cacheMap, writer);
            }
        } catch (Exception e) { System.err.println(">>> Cache write error: " + e.getMessage()); }
    }
}
