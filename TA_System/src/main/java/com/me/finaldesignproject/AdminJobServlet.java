package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@WebServlet("/AdminJobServlet")
public class AdminJobServlet extends HttpServlet {
    private final JobDao jobDao = new JobDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null ||
                !"Admin".equalsIgnoreCase(String.valueOf(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String adminId = String.valueOf(session.getAttribute("userId"));
        if (adminId == null || "null".equals(adminId)) {
            adminId = String.valueOf(session.getAttribute("user_id"));
        }
        if (adminId == null || "null".equals(adminId)) {
            adminId = "ADMIN";
        }

        if ("create".equalsIgnoreCase(action)) {
            Job job = new Job();
            job.setJobId(UUID.randomUUID().toString());
            job.setCreatorId(adminId);
            job.setCreatorRole("Admin");
            job.setCreatorName(resolveCreatorName(adminId));
            fillJobDataFromRequest(job, request);
            job.setStatus("Open");
            job.setPostedDate(LocalDate.now().toString());
            job.setLastUpdatedDate(LocalDate.now().toString());
            job.setLastModifiedBy(adminId);
            job.setLastModifiedRole("Admin");
            job.setDeleted(false);
            job.setApplicationsReceived(0);
            job.setApplicationsAccepted(0);
            job.setStudentCanApply(true);
            job.setEditable(true);
            job.setDeletable(true);
            jobDao.addJob(job);
        } else if ("edit".equalsIgnoreCase(action)) {
            String jobId = request.getParameter("jobId");
            Job target = findJobById(jobId);
            if (target != null) {
                fillJobDataFromRequest(target, request);
                target.setLastUpdatedDate(LocalDate.now().toString());
                target.setLastModifiedBy(adminId);
                target.setLastModifiedRole("Admin");
                if (target.getNumberOfPositions() <= 0) {
                    target.setStatus("Closed");
                    target.setStudentCanApply(false);
                }
                jobDao.updateJob(target);
            }
        } else if ("close".equalsIgnoreCase(action)) {
            updateJobStatus(request.getParameter("jobId"), "Closed", adminId);
        } else if ("reopen".equalsIgnoreCase(action)) {
            Job target = findJobById(request.getParameter("jobId"));
            if (target != null && target.getNumberOfPositions() > 0) {
                updateJobStatus(target.getJobId(), "Open", adminId);
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String jobId = request.getParameter("jobId");
            if (jobId != null && !jobId.trim().isEmpty()) {
                jobDao.deleteJob(jobId);
            }
        }

        response.sendRedirect("manage_jobs.jsp");
    }

    private String resolveCreatorName(String userId) {
        User user = userDao.getUserByEnrollment(userId);
        if (user != null && user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
            return user.getFullName();
        }
        return "Admin";
    }

    private Job findJobById(String jobId) {
        if (jobId == null || jobId.trim().isEmpty()) return null;
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job job : allJobs) {
            if (jobId.equals(job.getJobId())) {
                return job;
            }
        }
        return null;
    }

    private void updateJobStatus(String jobId, String status, String adminId) {
        Job target = findJobById(jobId);
        if (target == null) return;
        target.setStatus(status);
        target.setStudentCanApply("Open".equalsIgnoreCase(status) && target.getNumberOfPositions() > 0);
        target.setLastUpdatedDate(LocalDate.now().toString());
        target.setLastModifiedBy(adminId);
        target.setLastModifiedRole("Admin");
        jobDao.updateJob(target);
    }

    private void fillJobDataFromRequest(Job job, HttpServletRequest request) {
        job.setModuleCode(request.getParameter("moduleCode"));
        job.setCourseName(request.getParameter("courseName"));
        job.setJobTitle(request.getParameter("jobTitle"));
        job.setActivityType(request.getParameter("activityType"));
        job.setNumberOfPositions(parseInt(request.getParameter("numberOfPositions"), 1));
        job.setApplicationDeadline(request.getParameter("applicationDeadline"));
        job.setWorkingHours(request.getParameter("workingHours"));
        job.setRequiredSkills(request.getParameter("requiredSkills"));
        job.setJobResponsibilities(request.getParameter("jobResponsibilities"));
        job.setSemester(request.getParameter("semester"));
        job.setLocation(request.getParameter("location"));
        job.setPreferredMajor(request.getParameter("preferredMajor"));
        job.setContactEmail(request.getParameter("contactEmail"));
        job.setContactPhone(request.getParameter("contactPhone"));
        job.setCgpaRequired(parseDouble(request.getParameter("cgpaRequired"), 0.0));
    }

    private int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private double parseDouble(String value, double defaultValue) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
