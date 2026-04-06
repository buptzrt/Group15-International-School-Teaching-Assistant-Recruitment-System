package com.me.finaldesignproject.controller;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao; // ✅ 新增导入
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdateApplicationServlet")
public class UpdateApplicationServlet extends HttpServlet {

    // 初始化 DAO 实例
    private final ApplicationDao appDao = new ApplicationDao();
    private final JobDao jobDao = new JobDao(); // ✅ 新增 JobDao 实例

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 接收来自 view_applications.jsp 的参数
        String studentId = request.getParameter("studentId");
        String jobId = request.getParameter("jobId");
        String status = request.getParameter("status"); // 值为 "Pass" 或 "Reject"

        // 2. 校验参数
        if (studentId == null || jobId == null || status == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters.");
            return;
        }

        // 3. 调用 DAO 统一执行文件读写逻辑
        boolean isSuccess = appDao.updateApplicationStatus(studentId, jobId, status);

        // 4. ✅ 核心逻辑：如果更新申请状态成功，且 MO 点击的是 "Pass"
        if (isSuccess && "Pass".equalsIgnoreCase(status)) {
            // 调用 JobDao 减少该职位的名额 (需确保 JobDao 中已实现该方法)
            boolean jobUpdated = jobDao.decreasePosition(jobId);
            if (!jobUpdated) {
                System.err.println("[UpdateApplicationServlet] Warning: Application passed but position count update failed for JobID: " + jobId);
            }
        }

        if (isSuccess) {
            // 5. 成功后重定向回管理页面（之前改为 view_applications.jsp）
            response.sendRedirect("view_applications.jsp");
        } else {
            // 6. 失败处理
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('Update failed! Record might not exist.'); history.back();</script>");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}