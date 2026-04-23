package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.model.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/UpdateApplicationServlet")
public class UpdateApplicationServlet extends HttpServlet {

    private final ApplicationDao appDao = new ApplicationDao();
    private final JobDao jobDao = new JobDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String jobId = request.getParameter("jobId");
        String status = request.getParameter("status");

        if (studentId == null || jobId == null || status == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters.");
            return;
        }

        // --- 核心修改：20小时硬性拦截逻辑 ---
        if ("Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status)) {
            int acceptedHours = appDao.getTotalWorkingHours(studentId, "Accepted");

            int currentJobHours = 0;
            List<Job> allJobs = jobDao.getAllJobs();
            for (Job j : allJobs) {
                if (j.getJobId().equals(jobId)) {
                    try {
                        // 移除单位 'h' 后解析
                        String hStr = j.getWorkingHours().toLowerCase().replace("h", "").trim();
                        currentJobHours = Integer.parseInt(hStr);
                    } catch (Exception e) { currentJobHours = 0; }
                    break;
                }
            }

            // 🌟 核心改动：如果超限，弹窗后使用 history.back() 或者是原地待命，而不是跳往 manage_students.jsp
            if (acceptedHours + currentJobHours > 20) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<script>");
                response.getWriter().println("alert('Error: This student\\'s total workload will exceed 20 hours!');");
                // 🛑 关键：禁止跳转到 manage_students.jsp，改为返回上一页或留在原地
                response.getWriter().println("history.back();");
                response.getWriter().println("</script>");
                return;
            }
        }

        boolean isAccepted = "Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status);
        String normalizedStatus = isAccepted ? "Accepted" : status;

        boolean isSuccess = appDao.updateApplicationStatus(studentId, jobId, normalizedStatus);

        if (isSuccess && isAccepted) {
            jobDao.decreasePosition(jobId);
        }

        if (isSuccess) {
            // 🌟 正常处理成功后，返回来源页面，而不是写死管理员页面
            String referer = request.getHeader("Referer");
            if (referer != null && !referer.isEmpty()) {
                response.sendRedirect(referer);
            } else {
                response.sendRedirect("manage_students.jsp");
            }
        } else {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('Update failed!'); history.back();</script>");
        }
    }
}
