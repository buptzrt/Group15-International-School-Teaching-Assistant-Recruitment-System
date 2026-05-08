package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.ApplicationDao;
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

@WebServlet("/MOJobServlet")
public class MOJobServlet extends HttpServlet {
    private final JobDao jobDao = new JobDao();
    private final UserDao userDao = new UserDao();
    private final ApplicationDao applicationDao = new ApplicationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String moId = String.valueOf(session.getAttribute("userId"));
        List<Job> moJobs = jobDao.getJobsByMoId(moId);
        request.setAttribute("jobList", moJobs);
        request.getRequestDispatcher("mo_postjob.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String moId = String.valueOf(session.getAttribute("userId"));
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            if (!validateDeadline(request, null, response)) return;
            createJob(request, moId);
        } else if ("edit".equals(action)) {
            Job target = findOwnedJob(request.getParameter("jobId"), moId);
            if (!validateDeadline(request, target, response)) return;
            editJob(request, moId);
        } else if ("close".equals(action)) {
            updateJobStatus(request.getParameter("jobId"), moId, "Closed");
        } else if ("reopen".equals(action)) {
            updateJobStatus(request.getParameter("jobId"), moId, "Open");
        } else if ("delete".equals(action)) {
            String jobId = request.getParameter("jobId");
            if (hasOwnedJob(jobId, moId)) {
                if (applicationDao.hasApplicationsForJob(jobId)) {
                    response.setContentType("text/html;charset=UTF-8");
                    response.getWriter().println("<script>");
                    response.getWriter().println("alert('This vacancy already has student applications and cannot be deleted. Please close it instead.');");
                    response.getWriter().println("window.location.href='MOJobServlet';");
                    response.getWriter().println("</script>");
                    return;
                }
                jobDao.deleteJob(jobId);
            }
        }

        response.sendRedirect("MOJobServlet");
    }

    private void createJob(HttpServletRequest request, String moId) {
        String creatorFullName = "Unknown";
        List<User> users = userDao.getAllUsers();
        for (User u : users) {
            if (u.getEnrollmentNo() != null && u.getEnrollmentNo().equals(moId)) {
                creatorFullName = u.getFullName();
                break;
            }
        }

        Job newJob = new Job();
        newJob.setJobId(UUID.randomUUID().toString());
        newJob.setCreatorId(moId);
        newJob.setCreatorName(creatorFullName);
        fillJobDataFromRequest(newJob, request);
        newJob.setStatus("Open");
        newJob.setPostedDate(LocalDate.now().toString());
        newJob.setApplicationsReceived(0);
        newJob.setApplicationsAccepted(0);
        newJob.setDeleted(false);
        newJob.setStudentCanApply(true);
        newJob.setEditable(true);
        newJob.setDeletable(true);
        jobDao.addJob(newJob);
    }

    private void editJob(HttpServletRequest request, String moId) {
        String jobId = request.getParameter("jobId");
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job j : allJobs) {
            if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                fillJobDataFromRequest(j, request);
                j.setLastModifiedBy(moId);
                j.setLastUpdatedDate(LocalDate.now().toString());
                if ("Open".equalsIgnoreCase(j.getStatus())) {
                    j.setStudentCanApply(j.getNumberOfPositions() > 0);
                }
                jobDao.updateJob(j);
                break;
            }
        }
    }

    private boolean hasOwnedJob(String jobId, String moId) {
        if (jobId == null || jobId.trim().isEmpty()) return false;
        for (Job j : jobDao.getAllJobs()) {
            if (jobId.equals(j.getJobId()) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                return true;
            }
        }
        return false;
    }

    private Job findOwnedJob(String jobId, String moId) {
        if (jobId == null || jobId.trim().isEmpty()) return null;
        for (Job j : jobDao.getAllJobs()) {
            if (jobId.equals(j.getJobId()) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                return j;
            }
        }
        return null;
    }

    private boolean validateDeadline(HttpServletRequest request, Job existingJob, HttpServletResponse response) throws IOException {
        String deadlineValue = request.getParameter("applicationDeadline");
        try {
            LocalDate deadline = LocalDate.parse(deadlineValue);
            LocalDate minDate = LocalDate.now();

            if (existingJob != null && existingJob.getPostedDate() != null && !existingJob.getPostedDate().trim().isEmpty()) {
                LocalDate postedDate = LocalDate.parse(existingJob.getPostedDate().trim());
                if (postedDate.isAfter(minDate)) {
                    minDate = postedDate;
                }
            }

            if (deadline.isBefore(minDate)) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<script>");
                response.getWriter().println("alert('The application deadline cannot be earlier than the posting date.');");
                response.getWriter().println("window.location.href='MOJobServlet';");
                response.getWriter().println("</script>");
                return false;
            }
            return true;
        } catch (Exception e) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>");
            response.getWriter().println("alert('Invalid application deadline.');");
            response.getWriter().println("window.location.href='MOJobServlet';");
            response.getWriter().println("</script>");
            return false;
        }
    }

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
            if (j.getJobId().equals(jobId) && j.getCreatorId() != null && j.getCreatorId().equals(moId)) {
                j.setStatus(status);
                j.setStudentCanApply("Open".equalsIgnoreCase(status) && j.getNumberOfPositions() > 0);
                j.setLastModifiedBy(moId);
                j.setLastUpdatedDate(LocalDate.now().toString());
                jobDao.updateJob(j);
                break;
            }
        }
    }
}
