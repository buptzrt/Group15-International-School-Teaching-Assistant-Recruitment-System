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

        // --- 逻辑 A：保留原有工时逻辑（用于后端记录，不影响 MO 审批） ---
        int acceptedHours = appDao.getTotalWorkingHours(userId, "Accepted");
        int currentJobHours = 0;
        try {
            // 健壮性处理：确保 getWorkingHours() 不为 null
            String workHoursStr = targetJob.getWorkingHours();
            String hStr = (workHoursStr != null) ? workHoursStr.toLowerCase().replace("h", "").trim() : "0";
            currentJobHours = Integer.parseInt(hStr);
        } catch (Exception e) { currentJobHours = 0; }
        boolean willExceedHours = (acceptedHours + currentJobHours) > 20;

        // --- 🌟 逻辑 B：新增申请职位条数逻辑（针对学生的 20 个职位警告） 🌟 ---
        // 调用 DAO 统计该学生申请的总条数
        int currentAppliedCount = appDao.getTotalApplicationCount(userId);
        // 判定：加上本次后是否达到 20 个
        boolean willExceedCount = (currentAppliedCount + 1) >= 20;


        // 2. 执行保存申请
        boolean success = appDao.saveApplication(userId, jobId);

        if (success) {
            String requestedWith = request.getHeader("X-Requested-With");

            if ("XMLHttpRequest".equals(requestedWith)) {
                // 情况 1: fetch/AJAX 请求
                response.setStatus(HttpServletResponse.SC_OK);
                // 🌟 如果条数达到 20，返回专门的信号给前端
                if (willExceedCount) {
                    response.getWriter().write("WARNING_COUNT_LIMIT");
                } else {
                    response.getWriter().write("SUCCESS");
                }
            } else {
                // 情况 2: 普通页面跳转
                if (willExceedCount) {
                    response.getWriter().println("<script>");
                    response.getWriter().println("alert('Applied successfully! \\n\\nWarning: You have reached or exceeded the limit of 20 applications. Please manage your applications properly.');");
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