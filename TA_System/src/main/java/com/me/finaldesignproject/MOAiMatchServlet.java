package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
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
import java.util.ArrayList;
import java.util.List;

public class MOAiMatchServlet extends HttpServlet {
    private static final Gson GSON = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String jobId = request.getParameter("jobId");

        try {
            Job targetJob = findJobById(jobId);
            if (targetJob == null) { response.getWriter().write("[]"); return; }

            List<String> applicantIds = getApplicantIds(jobId);
            if (applicantIds.isEmpty()) { response.getWriter().write("[]"); return; }

            StudentProfileDao profileDao = new StudentProfileDao();
            JsonArray aiResultsArray = new JsonArray();

            // 🌟 遍历每个申请人，呼叫 AiMatchEngine 引擎打分
            for (String sId : applicantIds) {
                StudentProfile profile = profileDao.getByEnrollment(sId);
                if (profile != null) {

                    // 1. 提取该学生的 PDF 原文
                    String pdfText = extractTextFromPdf(request, profile.getResumePath());

                    // 2. 🚀 核心：直接调用带缓存的通用打分引擎！
                    AiMatchEngine.MatchResult matchResult = AiMatchEngine.evaluate(targetJob, profile, pdfText);

                    // 3. 将结果组装成 JSON 发给前端
                    JsonObject obj = new JsonObject();
                    obj.addProperty("studentId", sId);
                    obj.addProperty("score", matchResult.score);
                    obj.addProperty("reason", matchResult.reason);
                    obj.addProperty("name", profile.getFullName() != null ? profile.getFullName() : "Unknown");
                    obj.addProperty("major", profile.getMajorProgramme() != null ? profile.getMajorProgramme() : "Unknown");
                    obj.addProperty("resumePath", profile.getResumePath() != null ? profile.getResumePath() : "");

                    aiResultsArray.add(obj);
                }
            }

            // 返回给前端的 mo_filter_students.jsp 进行渲染
            response.getWriter().write(GSON.toJson(aiResultsArray));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().write("{\"error\": \"Match Engine failed: " + e.getMessage() + "\"}");
        }
    }

    // --- 以下为工具方法，保持不变 ---
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

    private List<String> getApplicantIds(String jobId) {
        List<String> ids = new ArrayList<>();
        File file = new File(ApplicationDao.getFilePath());
        if (file.exists()) {
            try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                String line;
                while ((line = br.readLine()) != null) {
                    if (line.contains("\"jobId\":\"" + jobId + "\"") && !line.contains("\"status\":\"Accepted\"") && !line.contains("\"status\":\"Rejected\"")) {
                        ids.add(line.split("\"studentId\":\"")[1].split("\"")[0]);
                    }
                }
            } catch (Exception ignore) {}
        }
        return ids;
    }
}
