<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
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
<%!
    private LocalDate parseDeadline(String deadline) {
        if (deadline == null || deadline.trim().isEmpty()) {
            return LocalDate.MAX;
        }
        try {
            return LocalDate.parse(deadline.trim());
        } catch (Exception e) {
            return LocalDate.MAX;
        }
    }

    private String buildJobLabel(Job job) {
        if (job == null) {
            return "Unknown Job";
        }
        String courseName = job.getCourseName() == null ? "Unknown Course" : job.getCourseName();
        String jobTitle = job.getJobTitle() == null ? "Unknown Job" : job.getJobTitle();
        return courseName + " - " + jobTitle;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Applications Management</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
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
        .applications-table-wrap {
            margin-top: 26px;
            overflow-x: auto;
            border: 1px solid rgba(255, 255, 255, 0.24);
            border-radius: 14px;
            background: rgba(13, 31, 50, 0.26);
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08), 0 18px 34px rgba(0, 0, 0, 0.18);
        }

        table {
            width: 100%;
            min-width: 1180px;
            border-collapse: separate;
            border-spacing: 0;
            margin: 0;
            background: rgba(255, 255, 255, 0.03);
        }

        th, td {
            border-right: 1px solid rgba(255, 255, 255, 0.18);
            border-bottom: 1px solid rgba(255, 255, 255, 0.18);
            padding: 14px 16px;
            text-align: left;
        }

        th:last-child,
        td:last-child {
            border-right: none;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        th {
            background: rgba(42, 123, 151, 0.76);
            color: #ffd166;
            font-weight: 700;
            font-size: 16px;
        }

        td {
            background: rgba(78, 104, 137, 0.46);
        }

        tbody tr:nth-child(even) td {
            background: rgba(61, 86, 119, 0.48);
        }

        tr:hover td { background-color: rgba(86, 118, 154, 0.66); }

        .course-job-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            position: relative;
        }

        .header-filter-trigger {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 20px;
            height: 20px;
            border: 1px solid rgba(249, 202, 36, 0.45);
            border-radius: 4px;
            background: rgba(20, 30, 48, 0.35);
            color: #f9ca24;
            font-size: 10px;
            cursor: pointer;
            padding: 0;
        }

        .header-filter-popup {
            display: none;
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            min-width: 320px;
            max-width: 420px;
            max-height: 280px;
            overflow-y: auto;
            padding: 10px;
            border-radius: 10px;
            background: #1b2a3d;
            border: 1px solid rgba(255, 255, 255, 0.16);
            box-shadow: 0 14px 28px rgba(0, 0, 0, 0.35);
            z-index: 20;
        }

        .header-filter-popup.open {
            display: block;
        }

        .header-filter-popup form {
            margin: 0;
        }

        .header-filter-option {
            width: 100%;
            text-align: left;
            padding: 8px 10px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.05);
            color: #f0f0f0;
            cursor: pointer;
            margin-bottom: 6px;
            font-size: 13px;
            white-space: normal;
            word-break: break-word;
            line-height: 1.35;
        }

        .header-filter-option.active {
            border-color: rgba(249, 202, 36, 0.6);
            background: rgba(249, 202, 36, 0.14);
            color: #ffd166;
        }

        .job-group-start td {
            border-top: 2px solid rgba(249, 202, 36, 0.45);
        }

        /* 🌟 操作列布局：确保按钮并排 🌟 */
        .operation-cell {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: nowrap;
            min-width: 190px;
        }

        /* 状态与按钮样式 */
        .status-tag { padding: 6px 14px; border-radius: 999px; font-size: 14px; font-weight: 800; line-height: 1.15; min-width: 96px; text-align: center; }
        .status-pending { color: #f9ca24; border: 1px solid #f9ca24; }
        .status-pass { color: #2ecc71; border: 1px solid #2ecc71; }
        .status-reject { color: #e74c3c; border: 1px solid #e74c3c; }
        .status-timeout { color: #95a5a6; border: 1px solid #95a5a6; }

        .action-btn {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 82px; min-height: 56px; padding: 8px 14px; border-radius: 6px;
            text-decoration: none; font-size: 13px; font-weight: 700; color: #fff; border: none;
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
            color: #f4f7fb;
            font-size: 16px;
            font-style: italic;
            font-weight: 800;
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
            position: relative;
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
                var innerDoc = frame.contentWindow.document;
                var innerBody = innerDoc.body;
                innerDoc.documentElement.style.background = "transparent";
                innerBody.style.setProperty("background", "transparent", "important");
                innerBody.style.setProperty("background-image", "none", "important");
                innerBody.classList.add("embedded-profile-frame");
                var style = innerDoc.createElement("style");
                style.textContent =
                    "html,html body{width:100%!important;height:100%!important;min-height:100%!important;margin:0!important;padding:0!important;background:transparent!important;background-color:transparent!important;background-image:none!important;background-attachment:initial!important;overflow:hidden!important;}" +
                    "html::before,html::after,html body::before,html body::after,body.app-auth-bg::before,body.app-auth-bg::after{display:none!important;content:none!important;background:none!important;background-color:transparent!important;background-image:none!important;}" +
                    "body.app-auth-bg,body.app-auth-bg.table-page,body.app-auth-bg.table-page.role-table-page,body.app-auth-bg.table-page.role-table-page.profile-page,body.app-auth-bg.table-page:not(.dashboard-shell){background:transparent!important;background-color:transparent!important;background-image:none!important;background-attachment:initial!important;box-shadow:none!important;}" +
                    "body.app-auth-bg.detail-display-page,body.view-profile-page.detail-display-page{display:block!important;min-height:100%!important;height:100%!important;padding:0!important;overflow:hidden!important;}" +
                    ".profile-container.detail-surface,.role-table-page .profile-container.detail-surface,.view-profile-page .profile-container{display:block!important;width:100%!important;max-width:none!important;min-height:100%!important;height:100%!important;max-height:none!important;margin:0!important;padding:0!important;overflow:auto!important;border:0!important;border-radius:0!important;box-shadow:none!important;background:transparent!important;background-color:transparent!important;background-image:none!important;backdrop-filter:none!important;}" +
                    ".profile-container .detail-back-row{margin:0!important;padding:24px 28px 0!important;background:transparent!important;}" +
                    ".profile-container .header{margin:0!important;padding:22px 28px 24px!important;background:transparent!important;}" +
                    ".profile-container .card{width:100%!important;min-height:calc(100% - 120px)!important;margin:0!important;padding:0 28px 28px!important;background:transparent!important;background-color:transparent!important;background-image:none!important;border:0!important;border-radius:0!important;box-shadow:none!important;backdrop-filter:none!important;}" +
                    ".profile-container .detail-item,.profile-container .description,.profile-container .pill{background:rgba(255,255,255,0.055)!important;background-image:none!important;}" +
                    ".profile-container .header{margin-bottom:24px!important;}" +
                    ".profile-container .detail-grid{grid-template-columns:repeat(2,minmax(240px,1fr))!important;}";
                innerDoc.head.appendChild(style);
                var editBtn = innerDoc.querySelector('.cta');
                if(editBtn) editBtn.style.display = 'none';
                var container = innerDoc.querySelector('.profile-container');
                if(container) {
                    container.style.margin = "0";
                    container.style.boxShadow = "none";
                    container.style.background = "transparent";
                }
            } catch (e) {
                console.log("Frame ready check...");
            }
        }

        function applyJobFilter(select) {
            select.form.submit();
        }

        function toggleJobFilter(event) {
            event.stopPropagation();
            var popup = document.getElementById("jobHeaderFilter");
            if (popup) {
                popup.classList.toggle("open");
            }
        }
    </script>
</head>
<body class="app-auth-bg table-page role-table-page">
<div class="card">
    <h2>Student Applications Management</h2>

    <%
        String selectedJobId = request.getParameter("jobFilter");
        if (selectedJobId == null) {
            selectedJobId = "";
        }
    %>

    <div class="applications-table-wrap">
    <table>
        <thead>
        <tr>
            <th>
                <div class="course-job-header">
                    <span>Course & Job</span>
                    <button type="button" class="header-filter-trigger" onclick="toggleJobFilter(event)">▼</button>
                    <div id="jobHeaderFilter" class="header-filter-popup">
                        <%
                            Set<String> filterJobIds = new LinkedHashSet<>();
                            Map<String, String> filterJobLabels = new HashMap<>();
                            try {
                                JobDao filterJobDao = new JobDao();
                                for (Job job : filterJobDao.getAllJobs()) {
                                    if (job != null && currentUserId.equals(job.getCreatorId())) {
                                        filterJobIds.add(job.getJobId());
                                        filterJobLabels.put(job.getJobId(), buildJobLabel(job));
                                    }
                                }
                            } catch (Exception ignored) {}
                        %>
                        <form method="get">
                            <button type="submit" class="header-filter-option <%= selectedJobId.isEmpty() ? "active" : "" %>">All jobs</button>
                        </form>
                        <%
                            for (String jobIdOption : filterJobIds) {
                        %>
                        <form method="get">
                            <input type="hidden" name="jobFilter" value="<%= jobIdOption %>">
                            <button type="submit" class="header-filter-option <%= jobIdOption.equals(selectedJobId) ? "active" : "" %>"><%= filterJobLabels.get(jobIdOption) %></button>
                        </form>
                        <%
                            }
                        %>
                    </div>
                </div>
            </th>
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
                    List<Map<String, Object>> rows = new ArrayList<>();
                    try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"))) {
                        String line;
                        while ((line = br.readLine()) != null) {
                            if (line == null || !line.contains("\"studentId\":\"") || !line.contains("\"jobId\":\"") || !line.contains("\"date\":\"")) {
                                continue;
                            }
                            String sId = line.split("\"studentId\":\"")[1].split("\"")[0];
                            String jId = line.split("\"jobId\":\"")[1].split("\"")[0];
                            Job job = jobMap.get(jId);
                            if (job != null && currentUserId != null && currentUserId.equals(job.getCreatorId())
                                    && (selectedJobId.isEmpty() || selectedJobId.equals(jId))) {
                                String dStr = line.split("\"date\":\"")[1].split("\"")[0];
                                String status = line.contains("\"status\":\"") ? line.split("\"status\":\"")[1].split("\"")[0] : "Pending";

                                boolean isPermanentlyIgnored = line.contains("\"ignoreOvertime\":\"true\"");

                                int totalAcceptedHours = appDao.getTotalWorkingHours(sId, "Accepted");
                                int currentJobHrs = 0;
                                try { currentJobHrs = Integer.parseInt(job.getWorkingHours().trim().replace("h","")); } catch(Exception e){}
                                boolean willExceed = (totalAcceptedHours + currentJobHrs) > 20;

                                boolean isTimeout = false;
                                Date applyDate = null;
                                try {
                                    applyDate = sdf.parse(dStr);
                                    Calendar untreatedDeadline = Calendar.getInstance();
                                    untreatedDeadline.add(Calendar.MONTH, -4);
                                    if ("Pending".equalsIgnoreCase(status) && applyDate.before(untreatedDeadline.getTime())) isTimeout = true;
                                } catch(Exception e) {}

                                Map<String, Object> row = new HashMap<>();
                                row.put("studentId", sId);
                                row.put("jobId", jId);
                                row.put("job", job);
                                row.put("applyDateText", dStr);
                                row.put("applyDate", applyDate);
                                row.put("status", status);
                                row.put("isPermanentlyIgnored", isPermanentlyIgnored);
                                row.put("totalAcceptedHours", totalAcceptedHours);
                                row.put("willExceed", willExceed);
                                row.put("isTimeout", isTimeout);
                                row.put("jobDeadline", parseDeadline(job.getApplicationDeadline()));
                                row.put("jobLabel", buildJobLabel(job));
                                rows.add(row);
                            }
                        }
                    }

                    rows.sort(new Comparator<Map<String, Object>>() {
                        @Override
                        public int compare(Map<String, Object> a, Map<String, Object> b) {
                            int deadlineCompare = ((LocalDate) a.get("jobDeadline")).compareTo((LocalDate) b.get("jobDeadline"));
                            if (deadlineCompare != 0) {
                                return deadlineCompare;
                            }

                            int jobCompare = String.valueOf(a.get("jobLabel")).compareToIgnoreCase(String.valueOf(b.get("jobLabel")));
                            if (jobCompare != 0) {
                                return jobCompare;
                            }

                            Date dateA = (Date) a.get("applyDate");
                            Date dateB = (Date) b.get("applyDate");
                            if (dateA == null && dateB == null) {
                                return 0;
                            }
                            if (dateA == null) {
                                return 1;
                            }
                            if (dateB == null) {
                                return -1;
                            }
                            return dateA.compareTo(dateB);
                        }
                    });

                    String previousJobId = null;
                    for (Map<String, Object> row : rows) {
                        anyApplicationsForMe = true;
                        String sId = (String) row.get("studentId");
                        String jId = (String) row.get("jobId");
                        Job job = (Job) row.get("job");
                        String dStr = (String) row.get("applyDateText");
                        String status = (String) row.get("status");
                        boolean isPermanentlyIgnored = (Boolean) row.get("isPermanentlyIgnored");
                        int totalAcceptedHours = (Integer) row.get("totalAcceptedHours");
                        boolean willExceed = (Boolean) row.get("willExceed");
                        boolean isTimeout = (Boolean) row.get("isTimeout");
        %>
        <tr class="<%= !jId.equals(previousJobId) ? "job-group-start" : "" %>">
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
                <span class="application-status status-tag status-timeout">Untreated</span>
                <% } else { %>
                <span class="application-status status-tag status-<%= status.toLowerCase() %>"><%= status %></span>
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
                        previousJobId = jId;
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
</div>

<div id="profileModal" class="modal detail-modal profile-modal">
    <div class="modal-content detail-surface">
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
        var filterPopup = document.getElementById("jobHeaderFilter");
        if (filterPopup && !filterPopup.contains(event.target) && !event.target.classList.contains("header-filter-trigger")) {
            filterPopup.classList.remove("open");
        }
    }
</script>

</body>
</html>
