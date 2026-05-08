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
        body {
            margin: 0;
            padding: 36px 20px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: linear-gradient(135deg, #141e30, #243b55);
            color: #2c3e50;
        }

        .page-wrap {
            max-width: 1180px;
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
            background: rgba(255, 255, 255, 0.78);
            backdrop-filter: blur(12px);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 18px 36px rgba(0, 0, 0, 0.18);
            border: 1px solid rgba(255, 255, 255, 0.3);
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 980px;
        }

        th, td {
            padding: 15px 16px;
            text-align: left;
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            color: #2d3436;
            vertical-align: middle;
        }

        th {
            background: rgba(0, 0, 0, 0.05);
            color: #1f2d3d;
            font-weight: 700;
            font-size: 14px;
            letter-spacing: 0.02em;
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.35);
        }

        .info-primary {
            display: block;
            font-weight: 700;
            color: #22313f;
        }

        .info-secondary {
            display: block;
            margin-top: 4px;
            font-size: 13px;
            color: #66707a;
        }

        .mono {
            font-family: "Consolas", "Courier New", monospace;
            letter-spacing: 0.02em;
        }

        .detail-btn {
            display: inline-block;
            padding: 7px 16px;
            border-radius: 10px;
            background: #1e90ff;
            color: #fff !important;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: 0.25s ease;
        }

        .detail-btn:hover {
            background: #0072ff;
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(30, 144, 255, 0.25);
        }

        .status-tag {
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
            color: #fff;
            display: inline-block;
            min-width: 84px;
            text-align: center;
        }

        .status-timeout { background: #95a5a6; }
        .status-pass { background: #2ecc71; }
        .status-reject { background: #e74c3c; }
        .status-pending { background: #f39c12; }

        .limit-warning {
            display: inline-block;
            margin-top: 8px;
            font-size: 11px;
            color: #ffffff;
            font-weight: 700;
            background: #d35400;
            border-radius: 999px;
            padding: 4px 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            white-space: nowrap;
        }

        .no-data {
            text-align: center;
            color: #555;
            font-style: italic;
            padding: 24px;
        }
    </style>
</head>
<body>
<div class="page-wrap">
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
                <th style="text-align: center;">Status</th>
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

                    // 🌟 1. 核心逻辑切换：获取已申请所有岗位的总时长累积 (不分状态)
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
                                // 🌟 2. 匹配逻辑优化
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
                                        // 7天超时逻辑
                                        if ("Pending".equalsIgnoreCase(status) && (nowTime - applyDate.getTime() > 604800000L)) {
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

                                        // 🌟 3. 判定：只要总申请时长 >= 20h，且该条申请不是“已通过”或“已拒绝”，就显示警告（包含超时岗）
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
                <td style="text-align: center;">
                    <% if ("Pass".equalsIgnoreCase(status) || "Accepted".equalsIgnoreCase(status)) { %>
                    <span class="status-tag status-pass">Accepted</span>
                    <% } else if ("Reject".equalsIgnoreCase(status)) { %>
                    <span class="status-tag status-reject">Rejected</span>
                    <% } else if (isActuallyTimeout) { %>
                    <span class="status-tag status-timeout">Untreated</span>
                    <%-- 🌟 超时岗位现在也会正确触发时长限制提醒 --%>
                    <% if (showHoursWarning) { %><br><span class="limit-warning">Workload limit reached (<%= totalAppliedHours %>h)</span><% } %>
                    <% } else { %>
                    <span class="status-tag status-pending">Pending</span>
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