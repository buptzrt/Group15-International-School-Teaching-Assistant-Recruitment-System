package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.UserDao; // 注入 UserDao
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.User; // 注入 User 模型

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
    private UserDao userDao = new UserDao(); // 实例化 UserDao

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // 校验登录状态
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String moId = (String) session.getAttribute("userId"); // 获取当前登录的工号
        List<Job> moJobs = jobDao.getJobsByMoId(moId); // 获取该 MO 发布的职位

        request.setAttribute("jobList", moJobs);
        request.getRequestDispatcher("mo_postjob.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // 校验登录状态
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String moId = (String) session.getAttribute("userId");
        String action = request.getParameter("action");

        // 1. 创建职位逻辑
        if ("create".equals(action)) {
            // --- 新增：获取发布者姓名逻辑 ---
            String creatorFullName = "Unknown";
            List<User> users = userDao.getAllUsers(); // 获取所有用户
            for (User u : users) {
                if (u.getEnrollmentNo() != null && u.getEnrollmentNo().equals(moId)) {
                    creatorFullName = u.getFullName(); // 匹配并获取姓名
                    break;
                }
            }
            // ---------------------------

            Job newJob = new Job();
            newJob.setJobId(UUID.randomUUID().toString());
            newJob.setCreatorId(moId);
            newJob.setCreatorName(creatorFullName); // 将姓名存入 Job 对象

            // 填充表单数据
            fillJobDataFromRequest(newJob, request);

            newJob.setStatus("Open");
            newJob.setPostedDate(LocalDate.now().toString());
            newJob.setApplicationsReceived(0);

            // 设置初始权限
            newJob.setStudentCanApply(true);
            newJob.setEditable(true);
            newJob.setDeletable(true);

            jobDao.addJob(newJob);

            // 2. 修改职位逻辑
        } else if ("edit".equals(action)) {
            String jobId = request.getParameter("jobId");
            List<Job> allJobs = jobDao.getAllJobs();
            for (Job j : allJobs) {
                // 安全校验：仅限发布者本人修改
                if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                    fillJobDataFromRequest(j, request);
                    j.setLastModifiedBy(moId);
                    j.setLastUpdatedDate(LocalDate.now().toString());
                    jobDao.updateJob(j);
                    break;
                }
            }
            // 3. 状态变更与删除逻辑
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
        response.sendRedirect("MOJobServlet"); // 重定向防止重复提交
    }

    // 公共方法：从请求中提取数据填充职位对象
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

    // 更新职位状态及操作记录
    private void updateJobStatus(String jobId, String moId, String status) {
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job j : allJobs) {
            if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                j.setStatus(status);
                j.setLastModifiedBy(moId);
                j.setLastUpdatedDate(LocalDate.now().toString());
                jobDao.updateJob(j);
                break;
            }
        }
    }
}