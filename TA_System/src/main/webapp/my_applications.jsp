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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        body {
            margin: 0;
            padding: 36px 20px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: linear-gradient(135deg, #141e30, #243b55);
            color: #2c3e50;
        }

        .page-wrap {
            max-width: 1320px;
            margin: 0 auto;
        }

        h3 {
            margin: 0 0 22px;
            text-align: center;
            color: #ffdd57;
            font-size: 30px;
            font-weight: 700;
        }

        .table-container {
            background: rgba(58, 84, 118, 0.74);
            backdrop-filter: blur(12px);
            border-radius: 22px;
            padding: 26px;
            box-shadow: 0 16px 30px rgba(0, 0, 0, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.16);
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 980px;
            border-radius: 14px;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.02);
        }

        th, td {
            padding: 17px 18px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.10);
            color: #eef4fb;
            vertical-align: middle;
        }

        th {
            background: rgba(47, 118, 145, 0.72);
            color: #ffd166;
            font-weight: 700;
            font-size: 15px;
            letter-spacing: 0.02em;
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.06);
        }

        .info-primary {
            display: block;
            font-weight: 700;
            color: #eef4fb;
        }

        .info-secondary {
            display: block;
            margin-top: 4px;
            font-size: 13px;
            color: #dbe8f5;
        }

        .mono {
            font-family: "Consolas", "Courier New", monospace;
            letter-spacing: 0.02em;
        }

        .detail-btn {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 10px;
            background: linear-gradient(135deg, #2d93ff, #1b79f2);
            color: #fff !important;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: 0.25s ease;
        }

        .detail-btn:hover {
            background: linear-gradient(135deg, #3ba0ff, #1d7df8);
            transform: translateY(-1px);
            box-shadow: 0 10px 20px rgba(45, 147, 255, 0.28);
        }

        .status-tag {
            padding: 8px 16px;
            border-radius: 999px;
            font-size: 16px;
            font-weight: 700;
            color: #fff;
            display: inline-block;
            min-width: 110px;
            text-align: center;
        }

        .status-timeout { background: #95a5a6; }
        .status-pass { background: #2ecc71; }
        .status-reject { background: #e74c3c; }
        .status-pending { background: #f39c12; }

        th.status-column,
        td.status-column {
            text-align: center !important;
            vertical-align: middle !important;
            width: 220px;
            min-width: 220px;
        }

        th.status-column {
            display: table-cell !important;
            padding-left: 0 !important;
            padding-right: 0 !important;
            text-align: center !important;
        }

        .table-page thead th.status-column,
        .table-page table thead tr th.status-column,
        .page-wrap .table-container table thead th.status-column {
            text-align: center !important;
            padding-left: 0 !important;
            padding-right: 0 !important;
        }

        td.status-column {
            padding-left: 0 !important;
            padding-right: 0 !important;
            overflow: hidden;
        }

        .limit-warning {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 8px;
            font-size: 12px;
            line-height: 1.2;
            color: #ffffff;
            font-weight: 700;
            background: #d35400;
            border-radius: 999px;
            padding: 5px 10px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.24);
            white-space: normal;
            overflow-wrap: anywhere;
            max-width: calc(100% - 18px);
            box-sizing: border-box;
        }

        .no-data {
            text-align: center;
            color: #555;
            font-style: italic;
            padding: 24px;
        }
    </style>
</head>
<body class="app-auth-bg table-page role-table-page">
<div class="page-wrap panel">
    <h3>My Applications</h3>

    <div class="table-container">
        <table>
            <thead>
            <tr>
                <th>Course Information</th>
                <th>Job Information</th>
                <th>MO Creator</th>
                <th>Application Date</th>
                <th>Action</th>
                <th class="status-column">Status</th>
            </tr>
            </thead>
            <tbody>
            <%
                String userId = (String) session.getAttribute("userId");

                if (userId == null) {
            %>
            <tr><td colspan="6" class="no-data">You are not logged in. <a href="login.jsp" style="color:#1e90ff;">Login here</a>.</td></tr>
            <%
            } else {
                try {
                    ApplicationDao applicationDao = new ApplicationDao();
                    JobDao jobDao = new JobDao();
                    List<Job> allJobs = jobDao.getAllJobs();
                    Map<String, Job> jobLookup = new HashMap<>();
                    if (allJobs != null) {
                        for (Job j : allJobs) {
                            jobLookup.put(j.getJobId(), j);
                        }
                    }

                    // 馃専 1. 鏍稿績閫昏緫鍒囨崲锛氳幏鍙栧凡鐢宠鎵€鏈夊矖浣嶇殑鎬绘椂闀跨疮绉?(涓嶅垎鐘舵€?
                    int totalAppliedHours = applicationDao.getAppliedTotalHours(userId);

                    String appPath = ApplicationDao.getFilePath();
                    File file = new File(appPath);
                    boolean hasData = false;

                    if (file.exists()) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                        long nowTime = System.currentTimeMillis();

                        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                            String line;
                            while ((line = br.readLine()) != null) {
                                // 馃専 2. 鍖归厤閫昏緫浼樺寲
                                if (line.replace(" ", "").contains("\"studentId\":\"" + userId + "\"")) {
                                    hasData = true;

                                    String jobId = line.split("\"jobId\":\"")[1].split("\"")[0];
                                    String appDateStr = line.split("\"date\":\"")[1].split("\"")[0];

                                    String status = "Pending";
                                    if (line.contains("\"status\":\"")) {
                                        status = line.split("\"status\":\"")[1].split("\"")[0];
                                    }

                                    boolean isActuallyTimeout = false;
                                    try {
                                        Date applyDate = sdf.parse(appDateStr);
                                        // 7澶╄秴鏃堕€昏緫
                                        Calendar untreatedDeadline = Calendar.getInstance();
                                        untreatedDeadline.add(Calendar.MONTH, -4);
                                        if ("Pending".equalsIgnoreCase(status) && applyDate.before(untreatedDeadline.getTime())) {
                                            isActuallyTimeout = true;
                                        }
                                    } catch (Exception dateEx) { }

                                    Job jobDetail = jobLookup.get(jobId);
                                    if (jobDetail != null) {
                                        String courseName = jobDetail.getCourseName() == null ? "Unknown Course" : jobDetail.getCourseName();
                                        String moduleCode = jobDetail.getModuleCode() == null ? "-" : jobDetail.getModuleCode();
                                        String jobTitle = jobDetail.getJobTitle() == null ? "Unknown Job" : jobDetail.getJobTitle();
                                        String activityType = jobDetail.getActivityType() == null ? "-" : jobDetail.getActivityType();
                                        String creatorName = jobDetail.getCreatorName() == null || jobDetail.getCreatorName().trim().isEmpty() ? "Unknown" : jobDetail.getCreatorName();

                                        // 馃専 3. 鍒ゅ畾锛氬彧瑕佹€荤敵璇锋椂闀?>= 20h锛屼笖璇ユ潯鐢宠涓嶆槸鈥滃凡閫氳繃鈥濇垨鈥滃凡鎷掔粷鈥濓紝灏辨樉绀鸿鍛婏紙鍖呭惈瓒呮椂宀楋級
                                        boolean showHoursWarning = (totalAppliedHours >= 20) &&
                                                !("Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status) || "Reject".equalsIgnoreCase(status));
            %>
            <tr>
                <td>
                    <span class="info-primary"><%= courseName %></span>
                    <span class="info-secondary mono">Module Code: <%= moduleCode %></span>
                </td>
                <td>
                    <span class="info-primary"><%= jobTitle %></span>
                    <span class="info-secondary">Type: <%= activityType %></span>
                </td>
                <td>
                    <span class="info-primary"><%= creatorName %></span>
                </td>
                <td>
                    <span class="info-primary mono"><%= appDateStr %></span>
                </td>
                <td>
                    <a href="view_job.jsp?jobId=<%= jobDetail.getJobId() %>&from=my_applications.jsp" class="detail-btn">Detail</a>
                </td>
                <td class="status-column">
                    <% if ("Pass".equalsIgnoreCase(status) || "Accepted".equalsIgnoreCase(status)) { %>
                    <span class="application-status status-tag status-pass">Accepted</span>
                    <% } else if ("Reject".equalsIgnoreCase(status)) { %>
                    <span class="application-status status-tag status-reject">Rejected</span>
                    <% } else if (isActuallyTimeout) { %>
                    <span class="status-tag status-timeout">Untreated</span>
                    <%-- 馃専 瓒呮椂宀椾綅鐜板湪涔熶細姝ｇ‘瑙﹀彂鏃堕暱闄愬埗鎻愰啋 --%>
                    <% if (showHoursWarning) { %><br><span class="limit-warning">Workload limit reached (<%= totalAppliedHours %>h)</span><% } %>
                    <% } else { %>
                    <span class="application-status status-tag status-pending">Pending</span>
                    <% if (showHoursWarning) { %><br><span class="limit-warning">Workload limit reached (<%= totalAppliedHours %>h)</span><% } %>
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
            <tr><td colspan="6" class="no-data">No applications found.</td></tr>
            <%
                }
            } catch (Exception e) {
            %>
            <tr><td colspan="6" class="no-data" style="color:red;">Error loading data: <%= e.getMessage() %></td></tr>
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
