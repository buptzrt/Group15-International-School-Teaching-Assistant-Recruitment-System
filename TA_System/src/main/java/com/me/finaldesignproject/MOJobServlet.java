package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.model.Job;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/MOJobServlet")
public class MOJobServlet extends HttpServlet {
    private JobDao jobDao = new JobDao();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // ⚠️ 【核心修改】：匹配 LoginServlet 存的 "userId"，判断为空时踢回登录
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ⚠️ 【核心修改】：强制转换为 String，因为 enrollmentNo 存的是字符串！
        String moId = (String) session.getAttribute("userId");
        List<Job> moJobs = jobDao.getJobsByMoId(moId);

        request.setAttribute("jobList", moJobs);
        request.getRequestDispatcher("mo_postjob.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // ⚠️ 再次校验 String 类型的 userId
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ⚠️ 获取 String 类型的 moId
        String moId = (String) session.getAttribute("userId");
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            Job newJob = new Job();
            newJob.setJobId(UUID.randomUUID().toString());
            // 💡 这里传入 String，与 Job.java 匹配
            newJob.setCreatorId(moId);

            newJob.setModuleCode(request.getParameter("moduleCode"));
            newJob.setCourseName(request.getParameter("courseName"));
            newJob.setJobTitle(request.getParameter("jobTitle"));
            newJob.setActivityType(request.getParameter("activityType"));
            newJob.setNumberOfPositions(Integer.parseInt(request.getParameter("numberOfPositions")));
            newJob.setApplicationDeadline(request.getParameter("applicationDeadline"));
            newJob.setWorkingHours(request.getParameter("workingHours"));
            newJob.setRequiredSkills(request.getParameter("requiredSkills"));
            newJob.setJobResponsibilities(request.getParameter("jobResponsibilities"));

            newJob.setSemester(request.getParameter("semester"));
            newJob.setLocation(request.getParameter("location"));
            newJob.setPreferredMajor(request.getParameter("preferredMajor"));
            newJob.setContactEmail(request.getParameter("contactEmail"));
            newJob.setContactPhone(request.getParameter("contactPhone"));

            String cgpaStr = request.getParameter("cgpaRequired");
            newJob.setCgpaRequired((cgpaStr != null && !cgpaStr.trim().isEmpty()) ? Double.parseDouble(cgpaStr) : 0.0);

            newJob.setStatus("Open");
            newJob.setPostedDate(LocalDate.now().toString());
            newJob.setApplicationsReceived(0);

            // 👇 在保存之前，手动赋予它们 true 的权限
            newJob.setStudentCanApply(true);
            newJob.setEditable(true);
            newJob.setDeletable(true);

            jobDao.addJob(newJob);

            // 💡 【新增】处理 "edit" 修改逻辑
        } else if ("edit".equals(action)) {
            String jobId = request.getParameter("jobId");
            List<Job> allJobs = jobDao.getAllJobs();
            for (Job j : allJobs) {
                // 安全校验：只有自己能修改自己的职位
                if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {

                    fillJobDataFromRequest(j, request); // 用表单传来的新数据覆盖旧数据

                    // 记录修改人和修改时间
                    j.setLastModifiedBy(moId);
                    j.setLastUpdatedDate(LocalDate.now().toString());

                    jobDao.updateJob(j);
                    break;
                }
            }
        } else if ("close".equals(action)) {
            updateJobStatus(request.getParameter("jobId"), moId, "Closed");
        } else if ("reopen".equals(action)) {
            updateJobStatus(request.getParameter("jobId"), moId, "Open");
        } else if ("delete".equals(action)) {
            String jobId = request.getParameter("jobId");
            List<Job> allJobs = jobDao.getAllJobs();
            for (Job j : allJobs) {
                if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                    jobDao.deleteJob(jobId);
                    break;
                }
            }
        }
        // 操作结束后重定向回 Get 请求，重新渲染页面
        response.sendRedirect("MOJobServlet");
    }

    // 💡 提取出一个公共方法，用于把 request 里的数据塞进 Job 对象，因为 create 和 edit 都要用到
    private void fillJobDataFromRequest(Job job, HttpServletRequest request) {
        job.setModuleCode(request.getParameter("moduleCode"));
        job.setCourseName(request.getParameter("courseName"));
        job.setJobTitle(request.getParameter("jobTitle"));
        job.setActivityType(request.getParameter("activityType"));
        job.setNumberOfPositions(Integer.parseInt(request.getParameter("numberOfPositions")));
        job.setApplicationDeadline(request.getParameter("applicationDeadline"));
        job.setWorkingHours(request.getParameter("workingHours"));
        job.setRequiredSkills(request.getParameter("requiredSkills"));
        job.setJobResponsibilities(request.getParameter("jobResponsibilities"));
        job.setSemester(request.getParameter("semester"));
        job.setLocation(request.getParameter("location"));
        job.setPreferredMajor(request.getParameter("preferredMajor"));
        job.setContactEmail(request.getParameter("contactEmail"));
        job.setContactPhone(request.getParameter("contactPhone"));

        String cgpaStr = request.getParameter("cgpaRequired");
        job.setCgpaRequired((cgpaStr != null && !cgpaStr.trim().isEmpty()) ? Double.parseDouble(cgpaStr) : 0.0);
    }


    private void updateJobStatus(String jobId, String moId, String status) {
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job j : allJobs) {
            // 找到对应的职位，且确实是当前 MO 发布的
            if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {

                // 1. 更新状态 (Open / Closed)
                j.setStatus(status);

                // 👇 2. 新增记录：记录是谁修改了它 (记录当前操作的 MO 的 ID)
                j.setLastModifiedBy(moId);

                // 👇 3. 新增记录：记录修改的时间
                j.setLastUpdatedDate(LocalDate.now().toString());

                // 4. 保存进 JSON 数据库
                jobDao.updateJob(j);
                break;
            }
        }
    }
}
