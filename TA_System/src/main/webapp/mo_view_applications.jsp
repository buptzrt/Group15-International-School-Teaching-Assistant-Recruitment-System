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
        /* 🌟 滚动条美化 🌟 */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.25); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.45); }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #f0f0f0; margin: 0; padding: 30px 20px;
            animation: fadeInBody 0.7s ease;
        }

        .card {
            max-width: 1400px; margin: 0 auto;
            background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(8px);
            border-radius: 14px; padding: 25px; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
            animation: fadeInUp 0.8s ease;
        }

        h2 { text-align: center; color: #f9ca24; margin-top: 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        th, td { border: 1px solid rgba(255, 255, 255, 0.18); padding: 12px; text-align: left; }
        th { background: rgba(0, 188, 212, 0.24); color: #f9ca24; font-weight: 600; }
        tr:hover td { background-color: rgba(255, 255, 255, 0.06); }

        /* 状态与按钮样式 */
        .status-tag { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
        .status-pending { color: #f9ca24; border: 1px solid #f9ca24; }
        .status-pass { color: #2ecc71; border: 1px solid #2ecc71; }
        .status-reject { color: #e74c3c; border: 1px solid #e74c3c; }
        .status-timeout { color: #95a5a6; border: 1px solid #95a5a6; }

        .action-btn {
            display: inline-block; padding: 6px 12px; border-radius: 6px;
            text-decoration: none; font-size: 12px; font-weight: 600; color: #fff; margin-right: 5px;
            transition: 0.3s; cursor: pointer; border: none;
        }
        .btn-pass { background: #2ecc71; }
        .btn-reject { background: #e74c3c; }

        /* 🌟 变灰禁用状态 🌟 */
        .btn-disabled {
            background: #555 !important;
            color: #aaa !important;
            cursor: not-allowed !important;
            opacity: 0.6;
            pointer-events: none;
        }

        .overlimit-text { color: #ff4757; font-weight: bold; display: block; font-size: 11px; }
        .resume-link { color: #7ed6ff; text-decoration: underline; }
        .pos-count { font-size: 12px; color: #f9ca24; display: block; }

        @keyframes fadeInBody { from { opacity: 0; } to { opacity: 1; } }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>

    <script>
        function handleAction(btn, studentId, jobId, status, isOverLimit) {
            // 🌟 核心拦截逻辑 🌟
            if (status === 'Accepted' && isOverLimit) {
                alert("Action Denied: This student's total workload will exceed 20 hours limit!");

                // 原地变灰并禁用
                btn.disabled = true;
                btn.classList.add("btn-disabled");
                btn.innerText = "Denied";

                return; // 🛑 停止执行，绝对不跳转
            }

            if (confirm("Are you sure to set status to " + status + "?")) {
                var contextPath = "<%= request.getContextPath() %>";
                window.location.href = contextPath + "/UpdateApplicationServlet?studentId=" + studentId + "&jobId=" + jobId + "&status=" + status;
            }
        }
    </script>
</head>
<body>
<div class="card">
    <h2>Student Applications Management</h2>

    <table>
        <thead>
        <tr>
            <th>Course & Job</th>
            <th>Student Name</th>
            <th>Student ID</th>
            <th>Apply Date</th>
            <th>Accumulated</th>
            <th>Status</th>
            <th>Operation</th>
        </tr>
        </thead>
        <tbody>
        <%
            boolean anyApplicationsForMe = false;
            try {
                JobDao jobDao = new JobDao();
                ApplicationDao appDao = new ApplicationDao();
                UserDao userDao = new UserDao();

                Map<String, Job> jobMap = new HashMap<>();
                for(Job j : jobDao.getAllJobs()) { jobMap.put(j.getJobId(), j); }

                Map<String, String> userNameMap = new HashMap<>();
                for(User u : userDao.getAllUsers()) {
                    if(u.getEnrollmentNo() != null) userNameMap.put(u.getEnrollmentNo(), u.getFullName());
                }

                String appPath = ApplicationDao.getFilePath();
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

                            if (job != null && currentUserId != null && currentUserId.equals(job.getCreatorId())) {
                                anyApplicationsForMe = true;
                                String dStr = line.split("\"date\":\"")[1].split("\"")[0];
                                String status = line.contains("\"status\":\"") ? line.split("\"status\":\"")[1].split("\"")[0] : "Pending";

                                // 获取学生已录取的总时长
                                int totalAcceptedHours = appDao.getTotalWorkingHours(sId, "Accepted");
                                int currentJobHrs = 0;
                                try { currentJobHrs = Integer.parseInt(job.getWorkingHours().trim().replace("h","")); } catch(Exception e){}

                                boolean willExceed = (totalAcceptedHours + currentJobHrs) > 20;

                                // 超时逻辑
                                boolean isTimeout = false;
                                try {
                                    Date applyDate = sdf.parse(dStr);
                                    if ("Pending".equalsIgnoreCase(status) && (nowTime - applyDate.getTime() > 604800000L)) isTimeout = true;
                                } catch(Exception e) {}
        %>
        <tr>
            <td>
                <strong><%= job.getCourseName() %></strong><br>
                <%= job.getJobTitle() %> <span class="pos-count">(Rem: <%= job.getNumberOfPositions() %>)</span>
            </td>
            <td><strong><%= userNameMap.getOrDefault(sId, "Unknown") %></strong></td>
            <td><%= sId %></td>
            <td><%= dStr %></td>
            <td>
                <span class="<%= (totalAcceptedHours >= 20 || (willExceed && "Pending".equalsIgnoreCase(status))) ? "overlimit-text" : "" %>">
                    <%= totalAcceptedHours %>h / 20h
                </span>
                <% if(willExceed && "Pending".equalsIgnoreCase(status)) { %>
                <span class="overlimit-text">Will exceed!</span>
                <% } %>
            </td>
            <td>
                <% if(isTimeout) { %>
                <span class="status-tag status-timeout">Untreated</span>
                <% } else { %>
                <span class="status-tag status-<%= status.toLowerCase() %>"><%= status %></span>
                <% } %>
            </td>
            <td>
                <% if(!isTimeout && "Pending".equalsIgnoreCase(status)) { %>
                <button type="button"
                        class="action-btn btn-pass <%= willExceed ? "btn-disabled" : "" %>"
                        onclick="handleAction(this, '<%= sId %>', '<%= jId %>', 'Accepted', <%= willExceed %>)">
                    Accepted
                </button>
                <button type="button" class="action-btn btn-reject"
                        onclick="handleAction(this, '<%= sId %>', '<%= jId %>', 'Reject', false)">
                    Reject
                </button>
                <% } else { %>
                <span class="status-tag status-timeout">Locked</span>
                <% } %>
            </td>
        </tr>
        <%
                            }
                        }
                    }
                }
                if (!anyApplicationsForMe) {
                    out.println("<tr><td colspan='7' class='error'>No applications found.</td></tr>");
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='7' class='error'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>