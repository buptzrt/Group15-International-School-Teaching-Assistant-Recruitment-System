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

        /* 🌟 操作列布局：确保按钮并排 🌟 */
        .operation-cell {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* 状态与按钮样式 */
        .status-tag { padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600; }
        .status-pending { color: #f9ca24; border: 1px solid #f9ca24; }
        .status-pass { color: #2ecc71; border: 1px solid #2ecc71; }
        .status-reject { color: #e74c3c; border: 1px solid #e74c3c; }
        .status-timeout { color: #95a5a6; border: 1px solid #95a5a6; }

        .action-btn {
            display: inline-block; padding: 6px 12px; border-radius: 6px;
            text-decoration: none; font-size: 12px; font-weight: 600; color: #fff; border: none;
            transition: 0.3s; cursor: pointer; white-space: nowrap;
        }
        .btn-pass { background: #2ecc71; }
        .btn-reject { background: #e74c3c; }

        .btn-disabled {
            background: #555 !important;
            color: #aaa !important;
            cursor: not-allowed !important;
            opacity: 0.6;
            pointer-events: none;
        }

        .processed-text {
            color: #aaa;
            font-size: 12px;
            font-style: italic;
        }

        .overlimit-text { color: #ff4757; font-weight: bold; display: block; font-size: 11px; }
        .resume-link { color: #7ed6ff; text-decoration: underline; background: none; border: none; cursor: pointer; padding: 0; font-family: inherit; font-size: inherit; }
        .pos-count { font-size: 12px; color: #f9ca24; display: block; }

        .ignore-timeout-container {
            display: inline-flex;
            align-items: center;
            margin-top: 4px;
            gap: 6px;
        }
        .ignore-timeout-checkbox {
            cursor: pointer;
            width: 13px;
            height: 13px;
            margin: 0;
            order: 2;
        }
        .ignore-timeout-text {
            font-size: 9px;
            color: #aaa;
            white-space: nowrap;
            order: 1;
        }

        .modal {
            display: none; position: fixed; z-index: 1000; left: 0; top: 0;
            width: 100%; height: 100%; background-color: rgba(0,0,0,0.7); backdrop-filter: blur(5px);
        }
        .modal-content {
            background-color: transparent;
            margin: 40px auto; padding: 0; border: none;
            width: 85%; max-width: 950px; height: 90vh; position: relative;
            box-shadow: none;
        }

        .close {
            position: absolute;
            left: -20px;
            top: -20px;
            width: 40px;
            height: 40px;
            cursor: pointer;
            z-index: 1001;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.3s ease;
        }

        .close::before {
            content: '';
            width: 14px;
            height: 14px;
            border-left: 2px solid #ffffff;
            border-bottom: 2px solid #ffffff;
            transform: rotate(45deg);
            transition: border-color 0.3s ease;
        }

        .close:hover {
            transform: translateX(-5px);
        }
        .close:hover::before {
            border-color: #f9ca24;
        }

        #profileFrame {
            width: 100%;
            height: 100%;
            border: none;
            background: transparent;
        }

        @keyframes fadeInBody { from { opacity: 0; } to { opacity: 1; } }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
    </style>

    <script>
        function toggleLock(checkbox, studentId, jobId, currentStatus) {
            const tr = checkbox.closest('tr');
            const acceptBtn = tr.querySelector('.btn-pass');
            const isChecked = checkbox.checked;

            if (isChecked) {
                if(acceptBtn) {
                    acceptBtn.classList.remove('btn-disabled');
                    acceptBtn.style.pointerEvents = 'auto';
                    acceptBtn.style.opacity = '1';
                }
            } else {
                if(acceptBtn) {
                    acceptBtn.classList.add('btn-disabled');
                    acceptBtn.style.pointerEvents = 'none';
                    acceptBtn.style.opacity = '0.6';
                }
            }

            // 🌟 核心即时同步：勾选后立即异步同步到 JSON，不改变 status 🌟
            var contextPath = "<%= request.getContextPath() %>";
            fetch(contextPath + "/UpdateApplicationServlet?studentId=" + studentId + "&jobId=" + jobId + "&status=" + currentStatus + "&ignoreOvertime=" + isChecked)
                .then(res => console.log("Memory Synced"))
                .catch(err => console.error("Sync Error"));
        }

        function handleAction(btn, studentId, jobId, status) {
            if (btn.classList.contains('btn-disabled') || btn.style.pointerEvents === 'none') {
                return;
            }

            if (confirm("Are you sure to set status to " + status + "?")) {
                // 立即禁用按钮防止重复点击
                btn.classList.add('btn-disabled');
                btn.innerText = "Processing...";

                const tr = btn.closest('tr');
                const checkbox = tr.querySelector('.ignore-timeout-checkbox');
                const ignoreValue = (checkbox && checkbox.checked) ? "true" : "false";

                var contextPath = "<%= request.getContextPath() %>";
                window.location.href = contextPath + "/UpdateApplicationServlet?studentId=" + studentId + "&jobId=" + jobId + "&status=" + status + "&ignoreOvertime=" + ignoreValue;
            }
        }

        function showProfile(studentId) {
            var modal = document.getElementById("profileModal");
            var frame = document.getElementById("profileFrame");
            var contextPath = "<%= request.getContextPath() %>";
            frame.src = contextPath + "/StudentProfileServlet?studentId=" + studentId;
            modal.style.display = "block";
        }

        function closeModal() {
            var modal = document.getElementById("profileModal");
            var frame = document.getElementById("profileFrame");
            modal.style.display = "none";
            frame.src = "";
        }

        function onFrameLoad() {
            var frame = document.getElementById("profileFrame");
            try {
                var innerBody = frame.contentWindow.document.body;
                innerBody.style.background = "transparent";
                var backBtn = frame.contentWindow.document.querySelector('.back-btn');
                var editBtn = frame.contentWindow.document.querySelector('.cta');
                if(backBtn) backBtn.style.display = 'none';
                if(editBtn) editBtn.style.display = 'none';
                var container = frame.contentWindow.document.querySelector('.profile-container');
                if(container) {
                    container.style.marginTop = "0";
                    container.style.boxShadow = "0 8px 32px rgba(0,0,0,0.4)";
                }
            } catch (e) {
                console.log("Frame ready check...");
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
            <th>Resume</th> <th>Student ID</th>
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

                                // 🌟 核心：从 JSON 中获取持久化的勾选标志 🌟
                                boolean isPermanentlyIgnored = line.contains("\"ignoreOvertime\":\"true\"");

                                int totalAcceptedHours = appDao.getTotalWorkingHours(sId, "Accepted");
                                int currentJobHrs = 0;
                                try { currentJobHrs = Integer.parseInt(job.getWorkingHours().trim().replace("h","")); } catch(Exception e){}
                                boolean willExceed = (totalAcceptedHours + currentJobHrs) > 20;

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
            <td>
                <button type="button" class="resume-link" onclick="showProfile('<%= sId %>')">View Profile</button>
            </td>
            <td><%= sId %></td>
            <td><%= dStr %></td>
            <td>
                <span class="<%= (totalAcceptedHours >= 20 || (willExceed && "Pending".equalsIgnoreCase(status))) ? "overlimit-text" : "" %>">
                    <%= totalAcceptedHours %>h / 20h
                </span>
                <%-- 🌟 修改：只要 JSON 记忆中是 true，或者当前超标，就渲染复选框，确保打钩状态能保留 🌟 --%>
                <% if((willExceed || isPermanentlyIgnored) && "Pending".equalsIgnoreCase(status)) { %>
                <span class="overlimit-text">Will exceed!</span>
                <div class="ignore-timeout-container">
                    <span class="ignore-timeout-text">Ignore Overtime</span>
                    <input type="checkbox" class="ignore-timeout-checkbox"
                           onclick="toggleLock(this, '<%= sId %>', '<%= jId %>', '<%= status %>')" <%= isPermanentlyIgnored ? "checked" : "" %>>
                </div>
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
                <div class="operation-cell">
                    <%-- 🌟 修改核心：只有 Pending 状态显示按钮。如果 JSON 记忆已忽略，则直接移除变灰样式 🌟 --%>
                    <% if(!isTimeout && "Pending".equalsIgnoreCase(status)) { %>
                    <button type="button"
                            class="action-btn btn-pass <%= (willExceed && !isPermanentlyIgnored) ? "btn-disabled" : "" %>"
                            style="<%= (willExceed && !isPermanentlyIgnored) ? "pointer-events: none; opacity: 0.6;" : "pointer-events: auto; opacity: 1;" %>"
                            onclick="handleAction(this, '<%= sId %>', '<%= jId %>', 'Accepted')">
                        Accepted
                    </button>
                    <button type="button" class="action-btn btn-reject"
                            onclick="handleAction(this, '<%= sId %>', '<%= jId %>', 'Reject')">
                        Reject
                    </button>
                    <% } else { %>
                    <span class="processed-text">Processed</span>
                    <% } %>
                </div>
            </td>
        </tr>
        <%
                            }
                        }
                    }
                }
                if (!anyApplicationsForMe) {
                    out.println("<tr><td colspan='8' class='no-data'>No applications found.</td></tr>");
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='8' class='error'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>

<div id="profileModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()"></span>
        <iframe id="profileFrame" src="" allowtransparency="true" onload="onFrameLoad()"></iframe>
    </div>
</div>

<script>
    window.onclick = function(event) {
        var modal = document.getElementById("profileModal");
        if (event.target == modal) {
            closeModal();
        }
    }
</script>

</body>
</html>