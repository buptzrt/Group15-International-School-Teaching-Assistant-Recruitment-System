<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%!
    private String jsValue(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }
%>
<%
    if (session == null || session.getAttribute("role") == null ||
            !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    JobDao jobDao = new JobDao();
    List<Job> jobs = jobDao.getAllJobs();
    if (jobs != null) {
        jobs.sort(new Comparator<Job>() {
            private LocalDate parseDeadline(Job job) {
                try {
                    String deadline = job == null ? null : job.getApplicationDeadline();
                    if (deadline == null || deadline.trim().isEmpty()) {
                        return LocalDate.MAX;
                    }
                    return LocalDate.parse(deadline.trim());
                } catch (Exception ignored) {
                    return LocalDate.MAX;
                }
            }

            @Override
            public int compare(Job a, Job b) {
                return parseDeadline(a).compareTo(parseDeadline(b));
            }
        });
    }
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
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

        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ddd;
            box-sizing: border-box;
        }

        .form-group textarea {
            min-height: 96px;
            resize: vertical;
            font: inherit;
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

        .admin-job-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin: 18px 0 10px;
            flex-wrap: wrap;
        }

        .admin-job-search {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1 1 520px;
            min-width: min(100%, 320px);
        }

        .admin-job-search input {
            width: min(620px, 100%);
            min-height: 48px;
            border-radius: 12px;
            border: 1px solid rgba(214, 231, 249, 0.34);
            background: rgba(92, 119, 151, 0.62);
            color: #eef4fb;
            padding: 0 16px;
            font-size: 16px;
            font-weight: 700;
            outline: none;
            box-sizing: border-box;
        }

        .admin-job-search input::placeholder {
            color: rgba(238, 244, 251, 0.72);
        }

        .admin-job-search input:focus {
            border-color: rgba(127, 208, 255, 0.8);
            box-shadow: 0 0 0 3px rgba(127, 208, 255, 0.16);
        }

        .admin-job-search .search-btn {
            min-height: 48px;
            padding: 0 22px;
            border-radius: 12px;
            border: 1px solid rgba(214, 231, 249, 0.34);
            background: rgba(92, 119, 151, 0.62);
            color: #eef4fb;
            font-size: 16px;
            font-weight: 800;
            cursor: pointer;
        }

        .admin-job-sort-note {
            color: rgba(238, 244, 251, 0.86);
            font-size: 15px;
            font-weight: 700;
            white-space: nowrap;
        }

        .admin-job-no-results {
            display: none;
            text-align: center;
            color: rgba(238, 244, 251, 0.82);
            font-weight: 800;
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

        #adminJobModal .modal-content.detail-surface {
            padding: 64px 40px 34px !important;
            overflow-y: auto !important;
        }

        #adminJobForm {
            display: grid;
            gap: 18px;
        }

        #adminJobForm .admin-form-row {
            display: grid !important;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px 20px !important;
            align-items: start;
        }

        #adminJobForm .admin-form-row.three-col {
            grid-template-columns: repeat(3, minmax(0, 1fr));
        }

        #adminJobForm .form-group {
            gap: 8px;
            min-width: 0;
        }

        #adminJobForm .form-group label {
            color: #eef4fb;
            font-size: 15px;
            line-height: 1.2;
        }

        #adminJobForm input,
        #adminJobForm select,
        #adminJobForm textarea {
            width: 100%;
            min-height: 46px;
            padding: 12px 14px;
            border-radius: 13px;
            border: 1px solid rgba(214, 231, 249, 0.26);
            background: rgba(92, 119, 151, 0.62) !important;
            color: #eef4fb !important;
            box-sizing: border-box;
            font-size: 16px;
            line-height: 1.35;
            box-shadow: none;
        }

        #adminJobForm input[type="date"] {
            color-scheme: dark;
        }

        #adminJobForm select option {
            background: #20364f;
            color: #eef4fb;
        }

        #adminJobForm textarea {
            min-height: 118px;
            resize: vertical;
        }

        #adminJobForm input:focus,
        #adminJobForm select:focus,
        #adminJobForm textarea:focus {
            outline: none;
            border-color: rgba(127, 208, 255, 0.8);
            box-shadow: 0 0 0 3px rgba(127, 208, 255, 0.16);
        }

        #adminJobForm .full-width-field {
            grid-column: 1 / -1;
        }

        .job-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 76px;
            min-height: 30px;
            padding: 6px 12px;
            border-radius: 999px;
            font-weight: 800;
            font-size: 14px;
            line-height: 1.15;
            text-align: center;
            border: 2px solid currentColor;
            box-shadow: none;
        }

        .job-status-open {
            background: rgba(46, 204, 113, 0.16);
            color: #9ff0bd;
        }

        .job-status-closed {
            background: rgba(231, 76, 60, 0.16);
            color: #ffaaa2;
        }

        th.status-column,
        td.status-column {
            text-align: center !important;
            vertical-align: middle !important;
        }

        #adminJobsTable { table-layout: fixed; }
        #adminJobsTable th,
        #adminJobsTable td { vertical-align: middle; }
        #adminJobsTable,
        #adminJobsTable th,
        #adminJobsTable td {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif !important;
        }
        #adminJobsTable th {
            color: #ffd166 !important;
            font-size: 15px !important;
            font-weight: 800 !important;
            line-height: 1.35 !important;
            padding: 14px 16px !important;
            letter-spacing: 0 !important;
        }
        #adminJobsTable td {
            color: #eef4fb !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            line-height: 1.45 !important;
            padding: 13px 16px !important;
            letter-spacing: 0 !important;
        }
        #adminJobsTable .job-status {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif !important;
            font-size: 14px !important;
            font-weight: 800 !important;
        }
        #adminJobsTable .meaning-column { font-weight: 700; }
        #adminJobsTable .admin-actions-column { min-width: 190px; }
        .admin-job-actions {
            display: grid;
            grid-template-columns: repeat(2, minmax(74px, 1fr));
            gap: 7px;
            align-items: stretch;
            width: 100%;
        }
        .admin-job-actions .inline-form {
            display: contents !important;
            margin: 0 !important;
        }
        .admin-job-actions .btn,
        .admin-job-actions button {
            display: inline-flex !important;
            align-items: center;
            justify-content: center;
            width: 100%;
            min-height: 40px;
            padding: 8px 10px;
            text-align: center;
            white-space: nowrap;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif !important;
            font-size: 15px !important;
            font-weight: 700 !important;
            line-height: 1.2 !important;
            box-sizing: border-box;
            margin: 0;
            appearance: none;
        }

        @media (max-width: 1180px) {
            #adminJobsTable th,
            #adminJobsTable td {
                padding-left: 8px !important;
                padding-right: 8px !important;
                font-size: 13px !important;
            }
            .admin-job-actions {
                grid-template-columns: 1fr;
                gap: 6px;
            }
            .admin-job-actions .btn,
            .admin-job-actions button {
                min-height: 34px;
                padding: 7px 8px;
                font-size: 12px;
            }
        }

        @media (max-width: 900px) {
            #adminJobForm .admin-form-row,
            #adminJobForm .admin-form-row.three-col {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="app-auth-bg dashboard-shell table-page">
<div class="navbar">
    <div class="navbar-left">
        <h2 class="dashboard-title"><span class="dashboard-icon">&#9638;</span><span>Admin Dashboard</span></h2>
        <a class="nav-link" href="admin_home.jsp"><span class="nav-link-icon">&#8962;</span>Home</a>
        <a class="nav-link" href="manage_students.jsp"><span class="nav-link-icon">&#9786;</span>Manage Application</a>
        <a class="nav-link active" href="manage_jobs.jsp"><span class="nav-link-icon">&#9638;</span>Manage Jobs</a>
    </div>
    <div class="navbar-right">
        <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="return confirm('Are you sure you want to logout?');">
            <button type="submit" class="logout-btn">Logout</button>
        </form>
    </div>
</div>

<% if (false) { %>
<div class="container detail-surface">
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
    <div class="admin-job-toolbar">
        <div class="admin-job-search">
            <input id="adminJobSearch" type="text" placeholder="Search visible columns...">
            <button id="adminJobSearchBtn" class="search-btn" type="button">Search</button>
        </div>
        <span class="admin-job-sort-note">Default sorted by Deadline, earliest first.</span>
    </div>
    <div class="table-wrap">
        <table id="adminJobsTable">
            <colgroup>
                <col style="width: 11%;">
                <col style="width: 10%;">
                <col style="width: 11%;">
                <col style="width: 10%;">
                <col style="width: 7%;">
                <col style="width: 8%;">
                <col style="width: 8%;">
                <col style="width: 16%;">
                <col style="width: 19%;">
            </colgroup>
            <thead>
            <tr>
                <th>Course</th>
                <th>Title</th>
                <th>Creator</th>
                <th>Deadline</th>
                <th>Quota Left</th>
                <th class="status-column">Status</th>
                <th>Hall</th>
                <th>What This Means</th>
                <th class="admin-actions-column">Admin Actions</th>
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
            <tr class="admin-job-row">
                <td><%= job.getCourseName() %> (<%= job.getModuleCode() %>)</td>
                <td><%= job.getJobTitle() %></td>
                <td><%= job.getCreatorName() == null ? "-" : job.getCreatorName() %> / <%= job.getCreatorId() %></td>
                <td><%= job.getApplicationDeadline() %></td>
                <td><%= job.getNumberOfPositions() %></td>
                <td class="status-column">
                    <span class="job-status <%= "Open".equalsIgnoreCase(job.getStatus()) ? "job-status-open" : "job-status-closed" %>">
                        <%= job.getStatus() %>
                    </span>
                </td>
                <td><%= hallVisible ? "Visible" : "Removed" %></td>
                <td class="meaning-column"><%= ruleCheck %></td>
                <td class="admin-actions-column">
                    <div class="admin-job-actions">
                    <a class="btn btn-view" href="view_job.jsp?jobId=<%= job.getJobId() %>&from=manage_jobs.jsp">View</a>
                    <button type="button" class="btn btn-edit" onclick="openAdminEditModal('<%= job.getJobId() %>')">Edit</button>
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
                        <button class="btn btn-reopen" type="submit">Re-open</button>
                    </form>
                    <% } %>
                    <form class="inline-form" action="AdminJobServlet" method="post" onsubmit="return confirm('Delete this position?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
                        <button class="btn btn-danger" type="submit">Delete</button>
                    </form>
                    </div>
                </td>
            </tr>
            <% if (editJob != null && editJob.getJobId() != null && editJob.getJobId().equals(job.getJobId())) { %>
            <tr>
                <td colspan="9">
                    <div class="detail-surface admin-job-edit-panel">
                        <a class="detail-exit-arrow" href="manage_jobs.jsp" title="Back"></a>
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
            <tr id="adminJobNoResults" class="admin-job-no-results"><td colspan="9">No matching jobs found.</td></tr>
            </tbody>
        </table>
    </div>
</div>

<div id="adminJobModal" class="modal detail-modal">
    <div class="modal-content detail-surface">
        <span class="close" onclick="closeAdminModal()" title="Back"></span>
        <h3 id="adminModalTitle" style="color: #ffd166; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">Edit TA Vacancy</h3>

        <form id="adminJobForm" action="AdminJobServlet" method="post">
            <input type="hidden" name="action" id="admin_modalAction" value="edit">
            <input type="hidden" name="jobId" id="admin_modalJobId" value="">

            <div class="admin-form-row">
                <div class="form-group" style="flex: 1;"><label>Module Code *</label><input type="text" id="admin_moduleCode" name="moduleCode" required placeholder="e.g. CS101"></div>
                <div class="form-group" style="flex: 2;"><label>Course Name *</label><input type="text" id="admin_courseName" name="courseName" required placeholder="e.g. Intro to Programming"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group" style="flex: 1;"><label>Job Title *</label><input type="text" id="admin_jobTitle" name="jobTitle" required placeholder="e.g. Lab Assistant"></div>
                <div class="form-group" style="flex: 1;"><label>Activity Type</label>
                    <select id="admin_activityType" name="activityType">
                        <option value="Teaching Assistant">Teaching Assistant</option>
                        <option value="Invigilation">Invigilation (Exam)</option>
                        <option value="Grading">Grading</option>
                    </select>
                </div>
            </div>
            <div class="admin-form-row three-col">
                <div class="form-group" style="flex: 1;"><label>Positions Needed *</label><input type="number" id="admin_numberOfPositions" name="numberOfPositions" required min="0" value="1"></div>
                <div class="form-group" style="flex: 1;"><label>Application Deadline *</label><input type="date" id="admin_applicationDeadline" name="applicationDeadline" required lang="en"></div>
                <div class="form-group" style="flex: 1;"><label>Working Hours</label><input type="text" id="admin_workingHours" name="workingHours" placeholder="e.g. 10 hrs/week"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group" style="flex: 1;"><label>Semester</label><input type="text" id="admin_semester" name="semester" placeholder="e.g. Spring 2026"></div>
                <div class="form-group" style="flex: 1;"><label>Location / Mode</label>
                    <select id="admin_location" name="location">
                        <option value="Offline">Offline (On-campus)</option>
                        <option value="Online">Online (Remote)</option>
                        <option value="Hybrid">Hybrid</option>
                    </select>
                </div>
            </div>
            <div class="admin-form-row">
                <div class="form-group" style="flex: 1;"><label>Min CGPA Required</label><input type="number" step="0.01" min="0" max="10" id="admin_cgpaRequired" name="cgpaRequired" placeholder="e.g. 3.0"></div>
                <div class="form-group" style="flex: 1;"><label>Preferred Major</label><input type="text" id="admin_preferredMajor" name="preferredMajor" placeholder="e.g. Computer Science"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group" style="flex: 1;"><label>Contact Email</label><input type="email" id="admin_contactEmail" name="contactEmail" placeholder="email@university.edu"></div>
                <div class="form-group" style="flex: 1;"><label>Contact Phone</label><input type="text" id="admin_contactPhone" name="contactPhone" placeholder="Optional"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group full-width-field"><label>Required Skills</label><input type="text" id="admin_requiredSkills" name="requiredSkills" placeholder="e.g. Java, Python"></div>
            </div>
            <div class="admin-form-row">
                <div class="form-group full-width-field"><label>Job Responsibilities *</label><textarea id="admin_jobResponsibilities" name="jobResponsibilities" required rows="4" placeholder="Describe tasks..."></textarea></div>
            </div>
            <button type="submit" id="adminModalSubmitBtn" class="btn btn-primary" style="width: 100%;">Save Changes</button>
        </form>
    </div>
</div>

<script>
    var adminModal = document.getElementById("adminJobModal");
    var adminJobsData = {};
    <% if (jobs != null) {
        for (Job j : jobs) { %>
    adminJobsData["<%= jsValue(j.getJobId()) %>"] = {
        moduleCode: "<%= jsValue(j.getModuleCode()) %>",
        courseName: "<%= jsValue(j.getCourseName()) %>",
        jobTitle: "<%= jsValue(j.getJobTitle()) %>",
        activityType: "<%= jsValue(j.getActivityType() == null ? "Teaching Assistant" : j.getActivityType()) %>",
        numberOfPositions: "<%= j.getNumberOfPositions() %>",
        applicationDeadline: "<%= jsValue(j.getApplicationDeadline()) %>",
        workingHours: "<%= jsValue(j.getWorkingHours()) %>",
        semester: "<%= jsValue(j.getSemester()) %>",
        location: "<%= jsValue(j.getLocation() == null ? "Offline" : j.getLocation()) %>",
        cgpaRequired: "<%= j.getCgpaRequired() > 0 ? j.getCgpaRequired() : "" %>",
        preferredMajor: "<%= jsValue(j.getPreferredMajor()) %>",
        contactEmail: "<%= jsValue(j.getContactEmail()) %>",
        contactPhone: "<%= jsValue(j.getContactPhone()) %>",
        requiredSkills: "<%= jsValue(j.getRequiredSkills()) %>",
        jobResponsibilities: "<%= jsValue(j.getJobResponsibilities()) %>",
        postedDate: "<%= jsValue(j.getPostedDate()) %>"
    };
    <%  }
    } %>

    function adminTodayYmd() {
        var now = new Date();
        var year = now.getFullYear();
        var month = String(now.getMonth() + 1).padStart(2, "0");
        var day = String(now.getDate()).padStart(2, "0");
        return year + "-" + month + "-" + day;
    }

    function adminLaterDate(a, b) {
        if (!a) return b || "";
        if (!b) return a || "";
        return a > b ? a : b;
    }

    function setAdminDeadlineMin(postedDate) {
        var deadlineInput = document.getElementById("admin_applicationDeadline");
        var minDate = adminLaterDate(adminTodayYmd(), postedDate || "");
        deadlineInput.min = minDate;
        if (deadlineInput.value && deadlineInput.value < minDate) {
            deadlineInput.value = minDate;
        }
    }

    function openAdminEditModal(jobId) {
        var data = adminJobsData[jobId];
        if (!data) return;

        document.getElementById("admin_modalAction").value = "edit";
        document.getElementById("admin_modalJobId").value = jobId;
        document.getElementById("admin_moduleCode").value = data.moduleCode;
        document.getElementById("admin_courseName").value = data.courseName;
        document.getElementById("admin_jobTitle").value = data.jobTitle;
        document.getElementById("admin_activityType").value = data.activityType;
        document.getElementById("admin_numberOfPositions").value = data.numberOfPositions;
        document.getElementById("admin_applicationDeadline").value = data.applicationDeadline;
        document.getElementById("admin_workingHours").value = data.workingHours;
        document.getElementById("admin_semester").value = data.semester;
        document.getElementById("admin_location").value = data.location;
        document.getElementById("admin_cgpaRequired").value = data.cgpaRequired;
        document.getElementById("admin_preferredMajor").value = data.preferredMajor;
        document.getElementById("admin_contactEmail").value = data.contactEmail;
        document.getElementById("admin_contactPhone").value = data.contactPhone;
        document.getElementById("admin_requiredSkills").value = data.requiredSkills;
        document.getElementById("admin_jobResponsibilities").value = data.jobResponsibilities;
        setAdminDeadlineMin(data.postedDate);

        document.getElementById("adminModalTitle").innerText = "Edit TA Vacancy";
        document.getElementById("adminModalSubmitBtn").innerText = "Save Changes";
        adminModal.style.display = "block";
    }

    document.getElementById("adminJobForm").addEventListener("submit", function(event) {
        var deadlineInput = document.getElementById("admin_applicationDeadline");
        var minDate = deadlineInput.min || adminTodayYmd();
        if (deadlineInput.value && deadlineInput.value < minDate) {
            event.preventDefault();
            alert("The application deadline cannot be earlier than the posting date.");
        }
    });

    function closeAdminModal() {
        adminModal.style.display = "none";
    }

    window.addEventListener("click", function(event) {
        if (event.target === adminModal) {
            closeAdminModal();
        }
    });

    (function () {
        var searchInput = document.getElementById("adminJobSearch");
        var searchBtn = document.getElementById("adminJobSearchBtn");
        var rows = Array.prototype.slice.call(document.querySelectorAll("#adminJobsTable tbody tr.admin-job-row"));
        var emptyRow = document.getElementById("adminJobNoResults");

        function normalize(value) {
            return (value || "").toString().trim().toLowerCase();
        }

        function applyAdminJobSearch() {
            var query = normalize(searchInput ? searchInput.value : "");
            var visibleCount = 0;

            rows.forEach(function (row) {
                var text = normalize(row.textContent);
                var match = !query || text.indexOf(query) !== -1;
                row.style.display = match ? "" : "none";
                if (match) {
                    visibleCount += 1;
                }
            });

            if (emptyRow) {
                emptyRow.style.display = rows.length > 0 && visibleCount === 0 ? "table-row" : "none";
            }
        }

        if (searchBtn) {
            searchBtn.addEventListener("click", applyAdminJobSearch);
        }
        if (searchInput) {
            searchInput.addEventListener("input", applyAdminJobSearch);
            searchInput.addEventListener("keydown", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    applyAdminJobSearch();
                }
            });
        }
    })();
</script>
</body>
</html>
