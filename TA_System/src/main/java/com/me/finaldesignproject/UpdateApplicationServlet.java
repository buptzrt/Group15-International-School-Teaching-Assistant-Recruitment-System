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

        // 🌟 核心配合修改：将 force 接收改为 ignoreOvertime (由 manage_students 或 manage_applications 传回)
        String ignoreOvertime = request.getParameter("ignoreOvertime");
        if (ignoreOvertime == null) {
            ignoreOvertime = request.getParameter("force"); // 兼容可能存在的旧参数名
        }

        if (studentId == null || jobId == null || status == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters.");
            return;
        }

        // --- 核心修改：增加 ignoreOvertime 判断，如果为 true 则跳过拦截 ---
        if (("Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status)) && !"true".equalsIgnoreCase(ignoreOvertime)) {
            int acceptedHours = appDao.getTotalWorkingHours(studentId, "Accepted");

            int currentJobHours = 0;
            List<Job> allJobs = jobDao.getAllJobs();
            for (Job j : allJobs) {
                if (j.getJobId().equals(jobId)) {
                    try {
                        // 移除单位 'h' 后解析
                        String workHrsStr = (j.getWorkingHours() != null) ? String.valueOf(j.getWorkingHours()) : "0";
                        String hStr = workHrsStr.toLowerCase().replace("h", "").trim();
                        currentJobHours = Integer.parseInt(hStr);
                    } catch (Exception e) { currentJobHours = 0; }
                    break;
                }
            }

            // 如果超限且没有 ignoreOvertime 标志，则拦截
            if (acceptedHours + currentJobHours > 20) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<script>");
                response.getWriter().println("alert('Error: This student\\'s total workload will exceed 20 hours!');");
                response.getWriter().println("history.back();");
                response.getWriter().println("</script>");
                return;
            }
        }

        // 识别是否为“撤回”操作 (状态设回 Pending)
        boolean isWithdraw = "Pending".equalsIgnoreCase(status);
        boolean isAccepted = "Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status);
        String normalizedStatus = isAccepted ? "Accepted" : status;

        // 🌟 执行状态更新：同时传入 ignoreOvertime 标志，确保状态被持久化到 JSON
        boolean isSuccess = appDao.updateApplicationStatus(studentId, jobId, normalizedStatus, ignoreOvertime);

        // 名额联动逻辑
        if (isSuccess) {
            if (isAccepted) {
                // 接受申请：名额 -1
                jobDao.decreasePosition(jobId);
            } else if (isWithdraw) {
                // 撤回申请：名额 +1 (调用 JobDao 方法)
                jobDao.increasePosition(jobId);
            }
        }

        if (isSuccess) {
            // 正常处理成功后，返回来源页面
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