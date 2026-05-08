package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.StudentProfile;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/GetAiScoreServlet")
public class GetAiScoreServlet extends HttpServlet {
    private static final Gson GSON = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        System.out.println("\n========== [GetAiScoreServlet] 收到 AI 打分请求 ==========");

        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.out.println("❌ 失败原因: Session 已过期或为空");
                response.getWriter().write("{\"success\":false, \"message\":\"登录失效\"}");
                return;
            }

            String studentId = (String) session.getAttribute("userId");
            if (studentId == null || studentId.isEmpty()) {
                studentId = (String) session.getAttribute("enrollment_no");
            }
            System.out.println("👉 当前请求学号: " + studentId);

            if (studentId == null || studentId.isEmpty()) {
                System.out.println("❌ 失败原因: Session 中没有学号信息");
                response.getWriter().write("{\"success\":false, \"message\":\"未登录\"}");
                return;
            }

            String jobId = request.getParameter("jobId");
            System.out.println("👉 目标岗位ID: " + jobId);

            if (jobId == null || jobId.trim().isEmpty()) {
                System.out.println("❌ 失败原因: 前端传来的 jobId 是空的！");
                response.getWriter().write("{\"success\":false, \"message\":\"缺JobID\"}");
                return;
            }
            jobId = jobId.trim();

            Job targetJob = null;
            for (Job j : new JobDao().getAllJobs()) {
                if (j.getJobId().equals(jobId)) { targetJob = j; break; }
            }

            if (targetJob == null) {
                System.out.println("❌ 失败原因: 数据库中找不到对应 ID 的岗位");
                response.getWriter().write("{\"success\":false, \"message\":\"无此岗位\"}");
                return;
            }

            StudentProfile profile = new StudentProfileDao().getByEnrollment(studentId);
            if (profile == null) {
                System.out.println("❌ 失败原因: 数据库中查不到该学生的简历");
                response.getWriter().write("{\"success\":false, \"message\":\"缺简历\"}");
                return;
            }

            System.out.println("✅ 数据全通，准备呼叫引擎或读取缓存...");
            AiMatchEngine.MatchResult res = AiMatchEngine.evaluate(targetJob, profile, "");

            if (res == null) {
                System.out.println("❌ 失败原因: AiMatchEngine 返回了 null，可能是大模型死锁");
                response.getWriter().write("{\"success\":false, \"message\":\"引擎崩溃\"}");
                return;
            }

            System.out.println("🎉 打分成功！最终分数: " + res.score);
            JsonObject json = new JsonObject();
            json.addProperty("success", true);
            json.addProperty("score", res.score);
            json.addProperty("reason", res.reason);

            response.getWriter().write(GSON.toJson(json));

        } catch (Exception e) {
            System.out.println("❌ 失败原因: 后端发生未知崩溃！");
            e.printStackTrace();
            response.getWriter().write("{\"success\":false, \"message\":\"后台崩溃\"}");
        }
        System.out.println("========================================================\n");
    }
}
