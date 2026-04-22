package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.model.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

    private final ApplicationDao appDao = new ApplicationDao();
    private final JobDao jobDao = new JobDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String jobId = request.getParameter("jobId");

        // 🌟 设置编码，确保弹窗中文不乱码
        response.setContentType("text/html;charset=UTF-8");

        if (userId == null || jobId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Login required.");
            return;
        }

        // 1. 获取目标岗位信息
        Job targetJob = null;
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job job : allJobs) {
            if (jobId.equals(job.getJobId())) {
                targetJob = job;
                break;
            }
        }

        if (targetJob == null || !jobDao.isVisibleInHall(targetJob, LocalDate.now())) {
            response.sendError(HttpServletResponse.SC_CONFLICT, "Job no longer available.");
            return;
        }

        // --- 核心逻辑：计算并判断是否需要弹窗警告 ---

        // A. 获取已录用的时长 (Accepted)
        int acceptedHours = appDao.getTotalWorkingHours(userId, "Accepted");

        // B. 当前申请岗位的时长 (支持解析 "5h" 或 "5")
        int currentJobHours = 0;
        try {
            String hStr = targetJob.getWorkingHours().toLowerCase().replace("h", "").trim();
            currentJobHours = Integer.parseInt(hStr);
        } catch (Exception e) { currentJobHours = 0; }

        // 🌟 判定：已通过 + 本次申请 是否超过 20h
        boolean willExceed = (acceptedHours + currentJobHours) > 20;

        // 2. 执行保存申请 (无论超没超，都允许申请)
        boolean success = appDao.saveApplication(userId, jobId);

        if (success) {
            // 判断请求来源，决定如何返回弹窗提醒
            String requestedWith = request.getHeader("X-Requested-With");

            if ("XMLHttpRequest".equals(requestedWith)) {
                // 情况 1: 如果是 fetch/AJAX 请求，返回标记让前端处理 alert
                response.setStatus(HttpServletResponse.SC_OK);
                if (willExceed) {
                    response.getWriter().write("WARNING_OVER_20H");
                } else {
                    response.getWriter().write("SUCCESS");
                }
            } else {
                // 情况 2: 如果是普通页面链接跳转，直接输出 JS 脚本弹窗
                if (willExceed) {
                    response.getWriter().println("<script>");
                    response.getWriter().println("alert('Applied successfully! \\n\\nWarning: Your total workload (" + (acceptedHours + currentJobHours) + "h) exceeds the 20h limit. MO may not approve this application.');");
                    response.getWriter().println("window.location.href='StudentJobServlet';");
                    response.getWriter().println("</script>");
                } else {
                    response.sendRedirect("StudentJobServlet");
                }
            }
        } else {
            // 失败处理
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("<script>alert('Application failed!'); history.back();</script>");
        }
    }
}