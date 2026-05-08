<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="java.time.LocalDate" %>
<%
    String userRole = (session != null) ? (String) session.getAttribute("role") : null;
    if (session == null || userRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAuthorized = "MO".equalsIgnoreCase(userRole) || "Student".equalsIgnoreCase(userRole);
    if (!isAuthorized) {
        response.sendRedirect("login.jsp");
        return;
    }

    String jobId = request.getParameter("jobId");
    String from = request.getParameter("from");

    String backUrl = "mo_job_list.jsp";
    if (from != null && !from.trim().isEmpty()) {
        backUrl = from;
    }
    boolean fromMyApplications = "my_applications.jsp".equalsIgnoreCase(backUrl);

    JobDao jobDao = new JobDao();
    Job currentJob = null;

    if (jobId != null && !jobId.trim().isEmpty()) {
        for (Job j : jobDao.getAllJobs()) {
            if (j.getJobId().equals(jobId)) {
                currentJob = j;
                break;
            }
        }
    }

    if (currentJob == null) {
        out.println("<h2 style='color:#ff4d4d; text-align:center; margin-top:100px; font-family:sans-serif;'>Error: Job not found.</h2>");
        out.println("<div style='text-align:center;'><a href='" + backUrl + "' style='color:#9bd3ff; text-decoration:none;'>&#8592; Return to Job List</a></div>");
        return;
    }

    boolean isStudent = "Student".equalsIgnoreCase(userRole);
    boolean isClosedForStudent = "Closed".equalsIgnoreCase(currentJob.getStatus()) || !currentJob.isStudentCanApply();
    boolean isOverdueForStudent = false;
    try {
        String deadlineValue = currentJob.getApplicationDeadline();
        if (deadlineValue != null && !deadlineValue.trim().isEmpty()) {
            isOverdueForStudent = LocalDate.parse(deadlineValue.trim()).isBefore(LocalDate.now());
        }
    } catch (Exception e) {
        isOverdueForStudent = false;
    }

    boolean allowClosedFromMyApplications = isStudent && fromMyApplications && isClosedForStudent && !isOverdueForStudent;

    if (isStudent && (currentJob.isDeleted() || (!allowClosedFromMyApplications && isClosedForStudent) || isOverdueForStudent)) {
        String blockedLabel = isOverdueForStudent ? "Overdue" : (isClosedForStudent ? "Close" : "Unavailable");
        out.println("<h2 style='color:#ffb366; text-align:center; margin-top:100px; font-family:sans-serif;'>This job is " + blockedLabel + " and can no longer be viewed.</h2>");
        out.println("<div style='text-align:center; margin-top:16px;'><a href='" + backUrl + "' style='color:#9bd3ff; text-decoration:none;'>&#8592; Return to Job List</a></div>");
        return;
    }

    String moduleCode = currentJob.getModuleCode() != null ? currentJob.getModuleCode() : "N/A";
    String courseName = currentJob.getCourseName() != null ? currentJob.getCourseName() : "N/A";
    String jobTitle = currentJob.getJobTitle() != null ? currentJob.getJobTitle() : "N/A";
    String activityType = currentJob.getActivityType() != null ? currentJob.getActivityType() : "N/A";
    String semester = currentJob.getSemester() != null && !currentJob.getSemester().isEmpty() ? currentJob.getSemester() : "Not specified";
    String applicationDeadline = currentJob.getApplicationDeadline() != null ? currentJob.getApplicationDeadline() : "N/A";
    String numberOfPositions = String.valueOf(currentJob.getNumberOfPositions());
    String cgpaRequired = String.valueOf(currentJob.getCgpaRequired());
    String preferredMajor = currentJob.getPreferredMajor() != null && !currentJob.getPreferredMajor().isEmpty() ? currentJob.getPreferredMajor() : "No preference";
    String location = currentJob.getLocation() != null ? currentJob.getLocation() : "N/A";
    String requiredSkills = currentJob.getRequiredSkills() != null && !currentJob.getRequiredSkills().isEmpty() ? currentJob.getRequiredSkills() : "None specified";
    String workingHours = currentJob.getWorkingHours() != null && !currentJob.getWorkingHours().isEmpty() ? currentJob.getWorkingHours() : "Not specified";
    String jobDescription = currentJob.getJobResponsibilities() != null && !currentJob.getJobResponsibilities().isEmpty() ? currentJob.getJobResponsibilities() : "No description provided.";
    String contactEmail = currentJob.getContactEmail() != null && !currentJob.getContactEmail().isEmpty() ? currentJob.getContactEmail() : "N/A";
    String contactPhone = currentJob.getContactPhone() != null && !currentJob.getContactPhone().isEmpty() ? currentJob.getContactPhone() : "N/A";
    String status = currentJob.getStatus() != null ? currentJob.getStatus() : "Open";
    String postedDate = currentJob.getPostedDate() != null ? currentJob.getPostedDate() : "N/A";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Job Details</title>
    <style>
        body { margin: 0; padding: 36px 18px; font-family: Georgia, "Times New Roman", serif; background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg"); background-size: cover; background-position: center; background-attachment: fixed; color: #f4f7fb; min-height: 100vh; position: relative; }
        body::before { content: ''; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(18, 35, 61, 0.78); z-index: -1; }
        .page-container { max-width: 980px; margin: 0 auto; }
        .header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 24px; }
        .header-left { display: flex; align-items: center; gap: 15px; }
        .header-left a { text-decoration: none; color: #9bd3ff; font-size: 28px; transition: 0.3s; font-weight: bold; }
        .header-left a:hover { color: #ffd166; transform: translateX(-3px); }
        .header h2 { margin: 0; font-size: 32px; color: #ffd166; }
        .card { background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(10px); border-radius: 18px; padding: 30px; border: 1px solid rgba(255, 255, 255, 0.14); }
        .section-title { color: #9bd3ff; margin-bottom: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; font-size: 14px; }
        .detail-grid { display: grid; grid-template-columns: repeat(2, minmax(240px, 1fr)); gap: 18px; }
        .detail-item { background: rgba(255, 255, 255, 0.06); border-radius: 14px; padding: 18px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .detail-item strong { display: block; margin-bottom: 8px; font-size: 14px; color: #ffd166; }
        .detail-item span { color: #e9effe; line-height: 1.7; }
        .description { margin-top: 26px; background: rgba(255, 255, 255, 0.06); border-radius: 16px; padding: 24px; border: 1px solid rgba(255, 255, 255, 0.1); color: #edf2ff; line-height: 1.9; }
        .description p { margin: 8px 0; }
        .footer { margin-top: 28px; display: flex; flex-wrap: wrap; gap: 16px; }
        .pill { display: inline-flex; align-items: center; padding: 12px 18px; border-radius: 999px; background: rgba(255, 255, 255, 0.08); color: #edf2ff; font-size: 13px; border: 1px solid rgba(255, 255, 255, 0.12); }
        .status-open { color: #2ecc71; }
        .status-closed { color: #e74c3c; }
        @media (max-width: 760px) { .detail-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="page-container">
    <div class="header">
        <div class="header-left">
            <a href="<%= backUrl %>" title="Back to List">&#8592;</a>
            <h2>Job Details</h2>
        </div>
        <div class="pill">Status: <strong class="<%= "Open".equals(status) ? "status-open" : "status-closed" %>" style="margin-left: 6px;"><%= status %></strong></div>
    </div>
    <div class="card">
        <div class="section-title">Job Information</div>
        <div class="detail-grid">
            <div class="detail-item"><strong>Course</strong><span><%= courseName %> (<%= moduleCode %>)</span></div>
            <div class="detail-item"><strong>Job Title & Type</strong><span><%= jobTitle %> [<%= activityType %>]</span></div>
            <div class="detail-item"><strong>Semester</strong><span><%= semester %></span></div>
            <div class="detail-item"><strong>Available Positions</strong><span><%= numberOfPositions %></span></div>
            <div class="detail-item"><strong>Deadline</strong><span><%= applicationDeadline %></span></div>
            <div class="detail-item"><strong>Min CGPA</strong><span><%= cgpaRequired %></span></div>
            <div class="detail-item"><strong>Preferred Major</strong><span><%= preferredMajor %></span></div>
            <div class="detail-item"><strong>Location</strong><span><%= location %></span></div>
        </div>
        <div class="description">
            <div class="section-title">Requirements</div>
            <p><strong style="color: #ffd166;">Working Hours:</strong> <%= workingHours %></p>
            <p><strong style="color: #ffd166;">Required Skills:</strong> <%= requiredSkills %></p>
        </div>
        <div class="description">
            <div class="section-title">Responsibilities</div>
            <p style="white-space: pre-wrap;"><%= jobDescription %></p>
        </div>
        <div class="footer">
            <div class="pill">Posted: <strong><%= postedDate %></strong></div>
            <div class="pill">Email: <strong><%= contactEmail %></strong></div>
            <div class="pill">Phone: <strong><%= contactPhone %></strong></div>
        </div>
    </div>
</div>
</body>
</html>
