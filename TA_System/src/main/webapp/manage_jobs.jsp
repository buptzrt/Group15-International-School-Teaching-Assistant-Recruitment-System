<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%
    if (session == null || session.getAttribute("role") == null ||
            !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    JobDao jobDao = new JobDao();
    List<Job> jobs = jobDao.getAllJobs();
    LocalDate today = LocalDate.now();

    String editId = request.getParameter("editId");
    Job editJob = null;
    if (editId != null && !editId.trim().isEmpty()) {
        for (Job j : jobs) {
            if (editId.equals(j.getJobId())) {
                editJob = j;
                break;
            }
        }
    }

    int hallVisibleCount = 0;
    int expiredRemovedCount = 0;
    int zeroQuotaClosedCount = 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Jobs</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: -1;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(44, 62, 80, 0.95);
            padding: 15px 30px;
        }

        .navbar-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .navbar-left h2 {
            margin: 0;
            color: #f9ca24;
        }

        .navbar a {
            color: white;
            text-decoration: none;
            padding: 8px 14px;
            border-radius: 6px;
        }

        .navbar a:hover {
            background-color: #00b894;
        }

        .container {
            width: 94%;
            margin: 18px auto;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 18px;
            box-sizing: border-box;
        }

        h3 {
            margin: 0 0 12px;
            color: #f9ca24;
        }

        .summary {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 16px;
        }

        .summary-item {
            background: rgba(255, 255, 255, 0.12);
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            min-width: 240px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(160px, 1fr));
            gap: 10px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .form-group label {
            color: white;
            font-size: 14px;
            font-weight: bold;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ddd;
            box-sizing: border-box;
        }

        .form-actions {
            margin-top: 10px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn {
            border: none;
            border-radius: 6px;
            padding: 8px 12px;
            cursor: pointer;
            color: #fff;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary { background: #1e90ff; }
        .btn-success { background: #2ecc71; }
        .btn-warning { background: #f39c12; }
        .btn-danger { background: #e74c3c; }
        .btn-muted { background: #7f8c8d; }

        .table-wrap {
            overflow-x: auto;
            margin-top: 14px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: rgba(0, 0, 0, 0.18);
            min-width: 1200px;
        }

        th, td {
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 8px;
            text-align: left;
            vertical-align: top;
            white-space: nowrap;
        }

        th {
            color: #f9ca24;
            background: rgba(0, 188, 212, 0.2);
        }

        .ok { color: #2ecc71; font-weight: 700; }
        .warn { color: #f39c12; font-weight: 700; }
        .bad { color: #ff7f7f; font-weight: 700; }

        .inline-form {
            display: inline;
            margin-right: 6px;
        }
    </style>
</head>
<body>
<div class="navbar">
    <div class="navbar-left">
        <h2>Admin Dashboard</h2>
        <a href="admin_home.jsp">Home</a>
        <a href="manage_students.jsp">Manage Students</a>
        <a href="manage_jobs.jsp">Manage Jobs</a>
    </div>
</div>

<% if (false) { %>
<div class="container">
    <h3><%= editJob == null ? "Create Recruitment Position (Admin Control)" : "Edit Recruitment Position (Admin Control)" %></h3>
    <form action="AdminJobServlet" method="post">
        <input type="hidden" name="action" value="<%= editJob == null ? "create" : "edit" %>">
        <input type="hidden" name="jobId" value="<%= editJob == null ? "" : editJob.getJobId() %>">
        <div class="form-grid">
            <div class="form-group">
                <label>【Module Code】</label>
                <input name="moduleCode" required value="<%= editJob == null ? "" : editJob.getModuleCode() %>">
            </div>
            <div class="form-group">
                <label>【Course Name】</label>
                <input name="courseName" required value="<%= editJob == null ? "" : editJob.getCourseName() %>">
            </div>
            <div class="form-group">
                <label>【Job Title】</label>
                <input name="jobTitle" required value="<%= editJob == null ? "" : editJob.getJobTitle() %>">
            </div>
            <div class="form-group">
                <label>【Activity Type】</label>
                <select name="activityType">
                    <option value="Teaching Assistant" <%= (editJob != null && "Teaching Assistant".equals(editJob.getActivityType())) ? "selected" : "" %>>Teaching Assistant</option>
                    <option value="Invigilation" <%= (editJob != null && "Invigilation".equals(editJob.getActivityType())) ? "selected" : "" %>>Invigilation</option>
                    <option value="Grading" <%= (editJob != null && "Grading".equals(editJob.getActivityType())) ? "selected" : "" %>>Grading</option>
                </select>
            </div>
            <div class="form-group">
                <label>【Quota】</label>
                <input name="numberOfPositions" type="number" min="0" required value="<%= editJob == null ? "1" : editJob.getNumberOfPositions() %>">
            </div>
            <div class="form-group">
                <label>【Application Deadline】</label>
                <input name="applicationDeadline" type="date" required value="<%= editJob == null ? "" : editJob.getApplicationDeadline() %>">
            </div>
            <div class="form-group">
                <label>【Working Hours】</label>
                <input name="workingHours" value="<%= editJob == null ? "" : (editJob.getWorkingHours() == null ? "" : editJob.getWorkingHours()) %>">
            </div>
            <div class="form-group">
                <label>【Semester】</label>
                <input name="semester" value="<%= editJob == null ? "" : (editJob.getSemester() == null ? "" : editJob.getSemester()) %>">
            </div>
            <div class="form-group">
                <label>【Location】</label>
                <input name="location" value="<%= editJob == null ? "" : (editJob.getLocation() == null ? "" : editJob.getLocation()) %>">
            </div>
            <div class="form-group">
                <label>【Required Skills】</label>
                <input name="requiredSkills" value="<%= editJob == null ? "" : (editJob.getRequiredSkills() == null ? "" : editJob.getRequiredSkills()) %>">
            </div>
            <div class="form-group">
                <label>【Preferred Major】</label>
                <input name="preferredMajor" value="<%= editJob == null ? "" : (editJob.getPreferredMajor() == null ? "" : editJob.getPreferredMajor()) %>">
            </div>
            <div class="form-group">
                <label>【Min CGPA】</label>
                <input name="cgpaRequired" type="number" step="0.01" min="0" max="10" value="<%= editJob == null ? "" : editJob.getCgpaRequired() %>">
            </div>
            <div class="form-group">
                <label>【Contact Email】</label>
                <input name="contactEmail" value="<%= editJob == null ? "" : (editJob.getContactEmail() == null ? "" : editJob.getContactEmail()) %>">
            </div>
            <div class="form-group">
                <label>【Contact Phone】</label>
                <input name="contactPhone" value="<%= editJob == null ? "" : (editJob.getContactPhone() == null ? "" : editJob.getContactPhone()) %>">
            </div>
            <div class="form-group">
                <label>【Responsibilities】</label>
                <input name="jobResponsibilities" value="<%= editJob == null ? "" : (editJob.getJobResponsibilities() == null ? "" : editJob.getJobResponsibilities()) %>">
            </div>
        </div>
        <div class="form-actions">
            <button class="btn btn-primary" type="submit"><%= editJob == null ? "Create Position" : "Save Position" %></button>
            <% if (editJob != null) { %>
            <a class="btn btn-muted" href="manage_jobs.jsp">Cancel Edit</a>
            <% } %>
        </div>
    </form>
</div>
<% } %>

<div class="container">
    <h3>Hall Monitoring Rules (Admin)</h3>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Course</th>
                <th>Title</th>
                <th>Creator</th>
                <th>Deadline</th>
                <th>Quota Left</th>
                <th>Status</th>
                <th>Hall</th>
                <th>What This Means</th>
                <th>Admin Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                if (jobs == null || jobs.isEmpty()) {
            %>
            <tr><td colspan="9">No jobs found.</td></tr>
            <%
                } else {
                    for (Job job : jobs) {
                        boolean hallVisible = jobDao.isVisibleInHall(job, today);
                        boolean deadlineExpired = false;
                        try {
                            deadlineExpired = LocalDate.parse(job.getApplicationDeadline()).isBefore(today);
                        } catch (Exception ignored) {}

                        String ruleCheck;
                        if (hallVisible) {
                            ruleCheck = "<span class='ok'>Visible to students</span>";
                        } else if (deadlineExpired) {
                            ruleCheck = "<span class='ok'>Deadline passed, hidden</span>";
                        } else if (job.getNumberOfPositions() <= 0 && "Closed".equalsIgnoreCase(job.getStatus())) {
                            ruleCheck = "<span class='ok'>No slots left, auto-closed</span>";
                        } else if (job.getNumberOfPositions() <= 0 && !"Closed".equalsIgnoreCase(job.getStatus())) {
                            ruleCheck = "<span class='bad'>No slots left but still open</span>";
                        } else {
                            ruleCheck = "<span class='warn'>Please review this job</span>";
                        }
            %>
            <tr>
                <td><%= job.getCourseName() %> (<%= job.getModuleCode() %>)</td>
                <td><%= job.getJobTitle() %></td>
                <td><%= job.getCreatorName() == null ? "-" : job.getCreatorName() %> / <%= job.getCreatorId() %></td>
                <td><%= job.getApplicationDeadline() %></td>
                <td><%= job.getNumberOfPositions() %></td>
                <td><%= job.getStatus() %></td>
                <td><%= hallVisible ? "Visible" : "Removed" %></td>
                <td><%= ruleCheck %></td>
                <td>
                    <a class="btn btn-primary" href="manage_jobs.jsp?editId=<%= job.getJobId() %>">Edit</a>
                    <% if ("Open".equalsIgnoreCase(job.getStatus())) { %>
                    <form class="inline-form" action="AdminJobServlet" method="post">
                        <input type="hidden" name="action" value="close">
                        <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
                        <button class="btn btn-warning" type="submit">Close</button>
                    </form>
                    <% } else if (job.getNumberOfPositions() > 0) { %>
                    <form class="inline-form" action="AdminJobServlet" method="post">
                        <input type="hidden" name="action" value="reopen">
                        <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
                        <button class="btn btn-success" type="submit">Re-open</button>
                    </form>
                    <% } %>
                    <form class="inline-form" action="AdminJobServlet" method="post" onsubmit="return confirm('Delete this position?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
                        <button class="btn btn-danger" type="submit">Delete</button>
                    </form>
                </td>
            </tr>
            <% if (editJob != null && editJob.getJobId() != null && editJob.getJobId().equals(job.getJobId())) { %>
            <tr>
                <td colspan="9">
                    <div style="background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.25); border-radius: 10px; padding: 14px;">
                        <h3 style="margin-bottom: 10px;">Edit Recruitment Position (Admin Control)</h3>
                        <form action="AdminJobServlet" method="post">
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="jobId" value="<%= editJob.getJobId() %>">
                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Module Code</label>
                                    <input name="moduleCode" required value="<%= editJob.getModuleCode() %>">
                                </div>
                                <div class="form-group">
                                    <label>Course Name</label>
                                    <input name="courseName" required value="<%= editJob.getCourseName() %>">
                                </div>
                                <div class="form-group">
                                    <label>Job Title</label>
                                    <input name="jobTitle" required value="<%= editJob.getJobTitle() %>">
                                </div>
                                <div class="form-group">
                                    <label>Activity Type</label>
                                    <select name="activityType">
                                        <option value="Teaching Assistant" <%= "Teaching Assistant".equals(editJob.getActivityType()) ? "selected" : "" %>>Teaching Assistant</option>
                                        <option value="Invigilation" <%= "Invigilation".equals(editJob.getActivityType()) ? "selected" : "" %>>Invigilation</option>
                                        <option value="Grading" <%= "Grading".equals(editJob.getActivityType()) ? "selected" : "" %>>Grading</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Quota</label>
                                    <input name="numberOfPositions" type="number" min="0" required value="<%= editJob.getNumberOfPositions() %>">
                                </div>
                                <div class="form-group">
                                    <label>Application Deadline</label>
                                    <input name="applicationDeadline" type="date" required value="<%= editJob.getApplicationDeadline() %>">
                                </div>
                                <div class="form-group">
                                    <label>Working Hours</label>
                                    <input name="workingHours" value="<%= editJob.getWorkingHours() == null ? "" : editJob.getWorkingHours() %>">
                                </div>
                                <div class="form-group">
                                    <label>Semester</label>
                                    <input name="semester" value="<%= editJob.getSemester() == null ? "" : editJob.getSemester() %>">
                                </div>
                                <div class="form-group">
                                    <label>Location</label>
                                    <input name="location" value="<%= editJob.getLocation() == null ? "" : editJob.getLocation() %>">
                                </div>
                                <div class="form-group">
                                    <label>Required Skills</label>
                                    <input name="requiredSkills" value="<%= editJob.getRequiredSkills() == null ? "" : editJob.getRequiredSkills() %>">
                                </div>
                                <div class="form-group">
                                    <label>Preferred Major</label>
                                    <input name="preferredMajor" value="<%= editJob.getPreferredMajor() == null ? "" : editJob.getPreferredMajor() %>">
                                </div>
                                <div class="form-group">
                                    <label>Min CGPA</label>
                                    <input name="cgpaRequired" type="number" step="0.01" min="0" max="10" value="<%= editJob.getCgpaRequired() %>">
                                </div>
                                <div class="form-group">
                                    <label>Contact Email</label>
                                    <input name="contactEmail" value="<%= editJob.getContactEmail() == null ? "" : editJob.getContactEmail() %>">
                                </div>
                                <div class="form-group">
                                    <label>Contact Phone</label>
                                    <input name="contactPhone" value="<%= editJob.getContactPhone() == null ? "" : editJob.getContactPhone() %>">
                                </div>
                                <div class="form-group">
                                    <label>Responsibilities</label>
                                    <input name="jobResponsibilities" value="<%= editJob.getJobResponsibilities() == null ? "" : editJob.getJobResponsibilities() %>">
                                </div>
                            </div>
                            <div class="form-actions">
                                <button class="btn btn-primary" type="submit">Save Position</button>
                                <a class="btn btn-muted" href="manage_jobs.jsp">Cancel Edit</a>
                            </div>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
            <%
                    }
                }
            %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
