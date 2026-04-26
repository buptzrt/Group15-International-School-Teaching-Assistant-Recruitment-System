<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.*, java.io.*, com.me.finaldesignproject.dao.*, com.me.finaldesignproject.model.*" %>

<%

    // 1. Initialize DAOs

    ApplicationDao applicationDao = new ApplicationDao();

    UserDao userDao = new UserDao();

    JobDao jobDao = new JobDao();



// 2. Admin Display Name

    String displayName = "-";

    Object sessionUser = session.getAttribute("user");

    if (sessionUser instanceof User) {

        displayName = ((User) sessionUser).getFullName();

    }



// 🌟 初始化统计变量

    int totalCount = 0;

    int acceptedCount = 0;

    int rejectedCount = 0;

    int pendingCount = 0;



// 3. 读取所有申请并封装成对象列表，同时进行统计

    List<Map<String, Object>> sortedAppList = new ArrayList<>();

    File file = new File(ApplicationDao.getFilePath());

    if (file.exists()) {

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {

            String line;

            while ((line = br.readLine()) != null) {

                if (line.trim().startsWith("{")) {

                    try {

                        String sId = line.split("\"studentId\":\"")[1].split("\"")[0];

                        String jId = line.split("\"jobId\":\"")[1].split("\"")[0];

                        String st = line.split("\"status\":\"")[1].split("\"")[0];

// 🌟 读取 JSON 中的 ignoreOvertime 标志

                        String ig = line.contains("\"ignoreOvertime\":\"true\"") ? "true" : "false";



// 🌟 实时统计逻辑

                        totalCount++;

                        if ("Accepted".equalsIgnoreCase(st)) {

                            acceptedCount++;

                        } else if ("Rejected".equalsIgnoreCase(st) || "Reject".equalsIgnoreCase(st)) {

                            rejectedCount++;

                        } else if ("Pending".equalsIgnoreCase(st)) {

                            pendingCount++;

                        }



// 获取该学生当前的累计已通过时长

                        int totalAcceptedHours = applicationDao.getTotalWorkingHours(sId, "Accepted");



                        Map<String, Object> appData = new HashMap<>();

                        appData.put("studentId", sId);

                        appData.put("jobId", jId);

                        appData.put("status", st);

                        appData.put("accumulated", totalAcceptedHours);

                        appData.put("ignore", ig); // 存入列表供前端使用



                        sortedAppList.add(appData);

                    } catch (Exception e) { continue; }

                }

            }

        } catch (Exception e) { e.printStackTrace(); }

    }



// 4. 执行排序（根据 accumulated 字段降序排列）

    Collections.sort(sortedAppList, new Comparator<Map<String, Object>>() {

        @Override

        public int compare(Map<String, Object> o1, Map<String, Object> o2) {

            Integer h1 = (Integer) o1.get("accumulated");

            Integer h2 = (Integer) o2.get("accumulated");

            return h2.compareTo(h1);

        }

    });

%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>Manage Students - Admin Dashboard</title>

    <style>

        body {

            font-family: Arial, sans-serif; margin: 0;

            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");

            background-size: cover; background-position: center; background-repeat: no-repeat;

            background-attachment: fixed; color: white; min-height: 100vh; position: relative;

        }

        body::before {

            content: ''; position: fixed; top: 0; left: 0; width: 100%; height: 100%;

            background-color: rgba(18, 35, 61, 0.78); z-index: -1;

        }

        .navbar {

            display: flex; justify-content: space-between; align-items: center;

            background: rgba(44, 62, 80, 0.95); padding: 15px 30px;

        }

        .navbar-left { display: flex; align-items: center; gap: 20px; }

        .navbar-left h2 { margin: 0; color: #f9ca24; }

        .navbar a { color: white; text-decoration: none; padding: 8px 14px; border-radius: 6px; }

        .navbar a:hover { background-color: #00b894; }

        .logout-btn { background: #2a5298; color: white; border: none; padding: 10px 18px; border-radius: 6px; cursor: pointer; }



        .container { width: 98%; margin: 30px auto; background: rgba(255, 255, 255, 0.1); padding: 25px; border-radius: 12px; backdrop-filter: blur(5px); }

        h3 { color: #f9ca24; margin-top: 0; }



        /* 统计面板样式 */

        .stats-container {

            display: grid;

            grid-template-columns: repeat(4, 1fr);

            gap: 20px;

            margin-bottom: 30px;

        }

        .stat-card {

            background: rgba(0, 0, 0, 0.4);

            padding: 15px;

            border-radius: 10px;

            text-align: center;

            border: 1px solid rgba(255, 255, 255, 0.1);

        }

        .stat-card .label { font-size: 14px; color: #ced4da; margin-bottom: 8px; }

        .stat-card .number { font-size: 24px; font-weight: bold; color: #f9ca24; }



        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: rgba(0, 0, 0, 0.3); color: white; font-size: 14px; }

        th, td { padding: 12px 8px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }

        th { background-color: rgba(44, 62, 80, 0.8); color: #f9ca24; white-space: nowrap; }



        .status-pending { color: #f9ca24; font-weight: bold; }

        .status-accepted { color: #2ecc71; font-weight: bold; }

        .status-rejected { color: #e74c3c; font-weight: bold; }

        .status-reject { color: #e74c3c; font-weight: bold; }



        .overlimit { color: #ff4757; font-weight: bold; }

        .btn-action { padding: 6px 10px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; transition: 0.3s; }

        .btn-approve { background: #00b894; color: white; }

        .btn-reject { background: #e17055; color: white; margin-left: 5px; }

        .btn-withdraw { background: #95a5a6; color: white; margin-left: 5px; }

        .btn-withdraw:hover { background: #7f8c8d; }



        .warning-text { color: #ff4757; font-size: 0.8em; display: block; margin-top: 4px; }

    </style>

    <script>

        // 🌟 增加 origIgnore 参数，确保 AD 操作不破坏 MO 的勾选记忆

        function handleAction(event, btn, studentId, jobId, status, origIgnore) {

            const actionText = status === 'Pending' ? 'Withdraw' : 'set status to ' + status;



            if (confirm("AD Decision: Are you sure to " + actionText + "?")) {

                var contextPath = "<%= request.getContextPath() %>";

// 🌟 核心：AD 操作统一发送 force=true 来无视 20h 限制，

// 🌟 但参数 force 依然承载着 ignoreOvertime 的值。

// 🌟 如果 origIgnore 本来就是 true，则传 true；如果不是，则传 true (AD 强制)。

// 🌟 按照你的逻辑：AD 撤回时需保留 MO 的勾选。



                let forceParam = "true"; // AD 默认拥有最高权限

                if (status === 'Pending') {

// 如果是撤回，必须保留 JSON 里原来的 ignoreOvertime 状态

                    forceParam = origIgnore;

                }



                window.location.href = contextPath + "/UpdateApplicationServlet?studentId=" + studentId + "&jobId=" + jobId + "&status=" + status + "&force=" + forceParam;

            }

        }

    </script>

</head>

<body>

<div class="navbar">

    <div class="navbar-left">

        <h2>Management Dashboard</h2>

        <a href="admin_home.jsp">Home</a>

        <a href="manage_students.jsp" style="background-color: #00b894;">Manage Students</a>

        <a href="manage_mo.jsp">Manage MO</a>

        <a href="manage_jobs.jsp">Manage Jobs</a>

    </div>

    <div>

        <form action="LogoutServlet" method="get" style="margin:0;">

            <button type="submit" class="logout-btn">Logout</button>

        </form>

    </div>

</div>



<div class="container">

    <h3>Statistics</h3>

    <div class="stats-container">

        <div class="stat-card">

            <div class="label">Total Applications</div>

            <div class="number"><%= totalCount %></div>

        </div>

        <div class="stat-card">

            <div class="label">Accepted</div>

            <div class="number" style="color: #2ecc71;"><%= acceptedCount %></div>

        </div>

        <div class="stat-card">

            <div class="label">Rejected</div>

            <div class="number" style="color: #e74c3c;"><%= rejectedCount %></div>

        </div>

        <div class="stat-card">

            <div class="label">Pending</div>

            <div class="number" style="color: #f9ca24;"><%= pendingCount %></div>

        </div>

    </div>



    <h3>Student Applications Management (AD Override Mode)</h3>

    <p>Logged in as: <strong><%= displayName %></strong></p>



    <table>

        <thead>

        <tr>

            <th>Student Name</th>

            <th>ID</th>

            <th>Course (Module Code)</th> <th>Job Position</th>

            <th>MO Name</th> <th>Hrs</th>

            <th>Status</th>

            <th>Accumulated</th>

            <th>Actions</th>

        </tr>

        </thead>

        <tbody>

        <%

            List<Job> allJobs = jobDao.getAllJobs();



            for (Map<String, Object> app : sortedAppList) {

                String sId = (String) app.get("studentId");

                String jId = (String) app.get("jobId");

                String st = (String) app.get("status");

                String ignoreFlag = (String) app.get("ignore"); // 获取 JSON 中的 ignoreOvertime 标志

                int totalAcceptedHours = (Integer) app.get("accumulated");



                User student = userDao.getUserByEnrollment(sId);

                String studentName = (student != null) ? student.getFullName() : "Unknown";



                Job job = null;

                for (Job j : allJobs) {

                    if (j.getJobId() != null && j.getJobId().equals(jId)) {

                        job = j;

                        break;

                    }

                }



                String jobTitle = (job != null) ? job.getJobTitle() : "N/A";

                String courseInfo = (job != null) ? job.getCourseName() + " (" + job.getModuleCode() + ")" : "N/A";

                String moName = (job != null && job.getCreatorName() != null) ? job.getCreatorName() : "N/A";



                int currentJobHrs = 0;

                String hoursStr = (job != null) ? job.getWorkingHours() : "0";

                try { currentJobHrs = Integer.parseInt(hoursStr.trim().replaceAll("[^0-9]", "")); } catch (Exception e) { currentJobHrs = 0; }



                boolean willBeOverLimit = (totalAcceptedHours + currentJobHrs) > 20;

        %>

        <tr>

            <td><%= studentName %></td>

            <td><%= sId %></td>

            <td><%= courseInfo %></td> <td><%= jobTitle %></td>

            <td><%= moName %></td> <td><%= hoursStr %>h</td>

            <td class="status-<%= st.toLowerCase() %>"><%= st %></td>

            <td class="<%= (totalAcceptedHours >= 20 || (st.equals("Pending") && willBeOverLimit)) ? "overlimit" : "" %>">

                <strong><%= totalAcceptedHours %>h</strong> / 20h

                <% if ("Pending".equalsIgnoreCase(st) && willBeOverLimit) { %>

                <span class="warning-text">Will exceed 20h limit!</span>

                <% } %>

            </td>

            <td>

                <%-- AD 按钮：全部移除 disabled 限制，并传递原始 ignoreFlag --%>

                <button type="button" class="btn-action btn-approve"

                        onclick="handleAction(event, this, '<%= sId %>', '<%= jId %>', 'Accepted', '<%= ignoreFlag %>')">Approve</button>



                <button type="button" class="btn-action btn-reject"

                        onclick="handleAction(event, this, '<%= sId %>', '<%= jId %>', 'Rejected', '<%= ignoreFlag %>')">Reject</button>



                <button type="button" class="btn-action btn-withdraw"

                        onclick="handleAction(event, this, '<%= sId %>', '<%= jId %>', 'Pending', '<%= ignoreFlag %>')">Withdraw</button>

            </td>

        </tr>

        <% } %>

        </tbody>

    </table>

</div>

</body>

</html>