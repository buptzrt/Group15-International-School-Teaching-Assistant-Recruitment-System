<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.dao.ApplicationDao" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Applications</title>
    <style>
        /* 保持深色渐变背景 */
        body {
            font-family: 'Poppins', 'Segoe UI', sans-serif;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #2c3e50;
            padding: 40px;
            animation: fadeInBody 0.7s ease;
        }

        h3 { text-align: center; color: #ffdd57; margin-bottom: 25px; font-size: 28px; }

        .table-container {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(12px);
            border-radius: 18px;
            padding: 25px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow-x: auto;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }

        th, td {
            padding: 14px 18px;
            text-align: left;
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            color: #333;
        }

        th {
            background-color: rgba(0, 0, 0, 0.04);
            color: #2c3e50;
            font-weight: 700;
        }

        .detail-btn {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 8px;
            background: #1e90ff;
            color: #fff !important;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: 0.3s;
        }

        .detail-btn:hover {
            background: #0072ff;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(30, 144, 255, 0.3);
        }

        .status-tag {
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            color: #fff;
            display: inline-block;
            min-width: 80px;
            text-align: center;
        }
        .status-timeout { background: #95a5a6; }
        .status-pass { background: #2ecc71; }
        .status-reject { background: #e74c3c; }
        .status-pending { background: #f39c12; }

        /* 🌟 新增：工时超限预警样式 */
        .limit-warning {
            display: block;
            margin-top: 5px;
            font-size: 10px;
            color: #d35400;
            font-weight: bold;
            background: rgba(255, 230, 0, 0.3);
            border-radius: 4px;
            padding: 2px 4px;
        }

        .no-data { text-align: center; color: #555; font-style: italic; padding: 20px; }

        @keyframes fadeInBody { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>

<h3>My Applications</h3>

<div class="table-container">
    <table>
        <thead>
        <tr>
            <th>Course</th>
            <th>Job Title & Type</th>
            <th>Application Date</th>
            <th>Action</th>
            <th style="text-align: center;">Status</th>
        </tr>
        </thead>
        <tbody>
        <%
            String userId = (String) session.getAttribute("userId");

            if (userId == null) {
        %>
        <tr><td colspan='5' class="no-data">You are not logged in. <a href='login.jsp' style="color:#1e90ff;">Login here</a>.</td></tr>
        <%
        } else {
            try {
                ApplicationDao applicationDao = new ApplicationDao();
                JobDao jobDao = new JobDao();
                List<Job> allJobs = jobDao.getAllJobs();
                Map<String, Job> jobLookup = new HashMap<>();
                if(allJobs != null) {
                    for (Job j : allJobs) { jobLookup.put(j.getJobId(), j); }
                }

                // 🌟 1. 获取当前学生已录用的总时长 (Accepted)
                int totalAcceptedHours = applicationDao.getTotalWorkingHours(userId, "Accepted");

                String appPath = ApplicationDao.getFilePath();
                File file = new File(appPath);
                boolean hasData = false;

                if (file.exists()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                    long nowTime = new Date().getTime();

                    try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            if (line.contains("\"studentId\":\"" + userId + "\"")) {
                                hasData = true;

                                String jobId = line.split("\"jobId\":\"")[1].split("\"")[0];
                                String appDateStr = line.split("\"date\":\"")[1].split("\"")[0];

                                String status = "Pending";
                                if(line.contains("\"status\":\"")) {
                                    status = line.split("\"status\":\"")[1].split("\"")[0];
                                }

                                try {
                                    Date applyDate = sdf.parse(appDateStr);
                                    if ("Pending".equalsIgnoreCase(status) && (nowTime - applyDate.getTime() > 604800000L)) {
                                        status = "Timeout";
                                    }
                                } catch(Exception dateEx) { }

                                Job jobDetail = jobLookup.get(jobId);
                                if (jobDetail != null) {
                                    String courseInfo = jobDetail.getCourseName() + " (" + jobDetail.getModuleCode() + ")";

                                    // 🌟 2. 解析该岗位工时，并计算如果通过是否会超限
                                    int jobHrs = 0;
                                    try {
                                        String hStr = jobDetail.getWorkingHours() != null ? jobDetail.getWorkingHours().toLowerCase().replace("h","").trim() : "0";
                                        jobHrs = Integer.parseInt(hStr);
                                    } catch(Exception e) { jobHrs = 0; }

                                    boolean willExceed = "Pending".equalsIgnoreCase(status) && (totalAcceptedHours + jobHrs > 20);
        %>
        <tr>
            <td><%= courseInfo %></td>
            <td><%= jobDetail.getJobTitle() %> [<%= jobDetail.getActivityType() %>]</td>
            <td><%= appDateStr %></td>
            <td>
                <a href="view_job.jsp?jobId=<%= jobDetail.getJobId() %>&from=my_applications.jsp" class="detail-btn">Detail</a>
            </td>
            <td style="text-align: center;">
                <% if("Pass".equalsIgnoreCase(status) || "Accepted".equalsIgnoreCase(status)) { %>
                <span class="status-tag status-pass">Accepted</span>
                <% } else if("Reject".equalsIgnoreCase(status)) { %>
                <span class="status-tag status-reject">Rejected</span>
                <% } else if("Timeout".equalsIgnoreCase(status)) { %>
                <span class="status-tag status-timeout">Untreated</span>
                <% } else { %>
                <span class="status-tag status-pending">Pending</span>
                <%-- 🌟 3. 如果通过该岗会导致超 20h，显示预警 --%>
                <% if(willExceed) { %>
                <span class="limit-warning">⚠️ Limit Warning!</span>
                <% } %>
                <% } %>
            </td>
        </tr>
        <%
                            }
                        }
                    }
                }
            }

            if (!hasData) {
        %>
        <tr><td colspan='5' class="no-data">No applications found.</td></tr>
        <%
            }
        } catch (Exception e) {
        %>
        <tr><td colspan='5' class="no-data" style="color:red;">Error: <%= e.getMessage() %></td></tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>