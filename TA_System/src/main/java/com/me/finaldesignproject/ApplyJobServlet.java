package com.me.finaldesignproject.controller;

import com.me.finaldesignproject.dao.ApplicationDao; // 确保导入了你的 DAO
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

    // 建议：复用一个 DAO 实例
    private final ApplicationDao appDao = new ApplicationDao();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // 1. 获取当前登录的用户ID（确保登录时 session 存的是 "userId"）
        String userId = (String) session.getAttribute("userId");
        String jobId = request.getParameter("jobId");

        // 2. 安全检查：如果没登录或没传 jobId，返回禁止访问
        if (userId == null || jobId == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN); // 403
            return;
        }

        // 3. 调用 DAO 进行持久化存储 (存入 E:\... 路径)
        // synchronized 逻辑已经建议写在 DAO 里，Servlet 保持干净
        boolean success = appDao.saveApplication(userId, jobId);

        if (success) {
            // 4. 成功：返回 200，让前端 fetch 能执行 .then() 里的变灰逻辑
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            // 5. 失败：返回 500
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}