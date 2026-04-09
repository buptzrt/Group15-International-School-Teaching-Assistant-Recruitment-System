<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="com.me.finaldesignproject.model.User" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.dao.UserDao" %>
<%@ page import="com.me.finaldesignproject.dao.ApplicationDao" %>
<%
    // 权限校验
    String currentUserId = (String) session.getAttribute("userId");
    if (session == null || currentUserId == null) {
        response.sendRedirect("mo_login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Applications Management</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #f0f0f0; margin: 0; padding: 30px 20px;
            animation: fadeInBody 0.7s ease;
        }

        .card {
            max-width: 1350px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(8px);
            border-radius: 14px;
            padding: 25px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
            overflow-x: auto;
            animation: fadeInUp 0.8s ease;
        }

        h2 { text-align: center; color: #f9ca24; margin-top: 0; }

        table { width: 100%; border-collapse: collapse; margin-top: 12px; }

        th, td {
            border: 1px solid rgba(255, 255, 255, 0.18);
            padding: 12px; text-align: left; transition: background-color 0.25s ease;
        }

        th { background: rgba(0, 188, 212, 0.24); color: #f9ca24; font-weight: 600; }

        tr:hover td { background-color: rgba(255, 255, 255, 0.06); }

        .status-tag { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
        .status-pending { color: #f9ca24; border: 1px solid #f9ca24; }
        .status-pass { color: #2ecc71; border: 1px solid #2ecc71; }
        .status-reject { color: #e74c3c; border: 1px solid #e74c3c; }
        .status-timeout { color: #95a5a6; border: 1px solid #95a5a6; }

        .action-btn {
            display: inline-block; padding: 6px 12px; border-radius: 6px;
            text-decoration: none; font-size: 12px; font-weight: 600; color: #fff; margin-right: 5px;
            transition: 0.3s;
        }
        .btn-pass { background: #2ecc71; }
        .btn-pass:hover { background: #27ae60; transform: translateY(-1px); }
        .btn-reject { background: #e74c3c; }
        .btn-reject:hover { background: #c0392b; transform: translateY(-1px); }
        .btn-disabled { background: #555; cursor: not-allowed; opacity: 0.5; pointer-events: none; }

        .resume-link { color: #7ed6ff; text-decoration: underline; font-weight: 500; }
        .resume-link:hover { color: #fff; }

        .error { color: #ff8f8f; text-align: center; font-weight: 600; }
        .pos-count { font-size: 12px; color: #f9ca24; display: block; margin-top: 4px; }

        @keyframes fadeInBody { from { opacity: 0; } to { opacity: 1; } }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
<div class="card">
    <h2>Student Applications Management</h2>

    <table>
        <thead>
        <tr>
            <th>Course</th>
            <th>Job Title</th>
            <th>Student Name</th>
            <th>Student ID</th>
            <th>Apply Date</th>
            <th>Resume</th>
            <th>Status</th>
            <th>Operation</th>
        </tr>
        </thead>
        <tbody>
        <%
            boolean anyApplicationsForMe = false; // 用于判断当前MO是否有属于自己的申请
            try {
                // 1. 获取最新的 Job 数据
                JobDao jobDao = new JobDao();
                Map<String, Job> jobMap = new HashMap<>();
                for(Job j : jobDao.getAllJobs()) { jobMap.put(j.getJobId(), j); }

                // 2. 获取用户映射
                UserDao userDao = new UserDao();
                Map<String, String> userNameMap = new HashMap<>();
                for(User u : userDao.getAllUsers()) {
                    if(u.getEnrollmentNo() != null) {
                        userNameMap.put(u.getEnrollmentNo(), u.getFullName());
                    }
                }

                String appPath = "C:\\Users\\31008\\Desktop\\Group15_TA_SYSTEM-sirongQi-TA-0203 (1)\\Group15_TA_SYSTEM-sirongQi-TA-0203\\TA_System\\src\\main\\resources\\applications.json";
                File file = new File(appPath);

                if (file.exists()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                    long nowTime = new Date().getTime();

                    try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            String sId = line.split("\"studentId\":\"")[1].split("\"")[0];
                            String jId = line.split("\"jobId\":\"")[1].split("\"")[0];

                            Job job = jobMap.get(jId);

                            // ✅ 关键修改：过滤逻辑
                            // 只有当职位存在，且该职位的 creatorId 与当前登录 MO 的 userId 相同时才显示
                            if (job != null && currentUserId != null && currentUserId.equals(job.getCreatorId())) {
                                anyApplicationsForMe = true;

                                String dStr = line.split("\"date\":\"")[1].split("\"")[0];
                                String status = line.contains("\"status\":\"") ? line.split("\"status\":\"")[1].split("\"")[0] : "Pending";
                                String studentName = userNameMap.getOrDefault(sId, "Unknown");

                                // 超时逻辑
                                boolean isTimeout = false;
                                try {
                                    Date applyDate = sdf.parse(dStr);
                                    if ("Pending".equalsIgnoreCase(status) && (nowTime - applyDate.getTime() > 604800000L)) {
                                        isTimeout = true;
                                    }
                                } catch(Exception e) {}

                                boolean noPositionsLeft = job.getNumberOfPositions() <= 0;
        %>
        <tr>
            <td><%= job.getCourseName() %></td>
            <td>
                <%= job.getJobTitle() %>
                <span class="pos-count">(Remaining: <%= job.getNumberOfPositions() %>)</span>
            </td>
            <td><strong><%= studentName %></strong></td>
            <td><%= sId %></td>
            <td><%= dStr %></td>
            <td>
                <a href="StudentProfileServlet?userId=<%= sId %>" class="resume-link" target="_blank">View Profile</a>
            </td>
            <td>
                <% if(isTimeout) { %>
                <span class="status-tag status-timeout">Untreated</span>
                <% } else if("Pass".equalsIgnoreCase(status) || "Accepted".equalsIgnoreCase(status)) { %>
                <span class="status-tag status-pass">Accepted</span>
                <% } else if("Reject".equalsIgnoreCase(status)) { %>
                <span class="status-tag status-reject">Rejected</span>
                <% } else { %>
                <span class="status-tag status-pending">Pending</span>
                <% } %>
            </td>
            <td>
                <% if(!isTimeout && "Pending".equalsIgnoreCase(status)) { %>
                <% if(noPositionsLeft) { %>
                <span class="action-btn btn-disabled" title="No positions left">Full</span>
                <% } else { %>
                <a href="UpdateApplicationServlet?studentId=<%= sId %>&jobId=<%= jId %>&status=Accepted" class="action-btn btn-pass">Accepted</a>
                <% } %>
                <a href="UpdateApplicationServlet?studentId=<%= sId %>&jobId=<%= jId %>&status=Reject" class="action-btn btn-reject">Reject</a>
                <% } else { %>
                <span class="action-btn btn-disabled">Locked</span>
                <% } %>
            </td>
        </tr>
        <%
                            } // End filter if
                        } // End while
                    }
                }

                if (!anyApplicationsForMe) {
                    out.println("<tr><td colspan='8' class='error'>No applications found for your posted jobs.</td></tr>");
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='8' class='error'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>
