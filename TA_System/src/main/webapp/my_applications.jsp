<%@ page import="java.sql.*, jakarta.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Applications</title>
    <style>
        /* 保持你原本的 body 和动画样式不变 */
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #f5f5f5;
            padding: 40px;
            animation: fadeInBody 0.7s ease;
        }
        h3 { text-align: center; color: #ffdd57; margin-bottom: 25px; }
        .table-container {
            background: rgba(255, 255, 255, 0.07);
            backdrop-filter: blur(6px);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.3);
            overflow-x: auto;
        }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 14px 18px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
        th { background-color: rgba(255, 255, 255, 0.1); color: #ffdd57; }

        /* 新增 Detail 按钮样式 */
        .detail-btn {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 6px;
            background: #1e90ff;
            color: #fff !important;
            text-decoration: none;
            font-size: 13px;
        }
        .detail-btn:hover { background: #0072ff; text-decoration: none; }
    </style>
</head>
<body>

<h3>My Applications</h3>

<div class="table-container">
    <table>
        <tr>
            <th>Course</th>
            <th>Job Title & Type</th>
            <th>Application Date</th>
            <th>Action</th>
        </tr>
        <%
            // 获取当前登录学生的 ID (假设存放在 session 中)
            String userId = (String) session.getAttribute("userId");

            if (userId == null) {
        %>
        <tr><td colspan='4' class="error-msg">You are not logged in. Please <a href='login.jsp'>login</a>.</td></tr>
        <%
        } else {
            try {
                // 数据库连接 (请根据你实际的 db 配置修改)
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/design_engineering_portal", "root", "root");

                // 修改查询语句，展示 Course, Title & Type
                String query = "SELECT j.job_id, j.course_name, j.module_code, j.job_title, j.activity_type, a.application_date " +
                        "FROM applications a " +
                        "JOIN jobs j ON a.job_id = j.job_id " + // 假设你的关联表是 jobs
                        "WHERE a.student_id = ?";

                PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setString(1, userId);
                ResultSet rs = stmt.executeQuery();

                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
                    String courseInfo = rs.getString("course_name") + " (" + rs.getString("module_code") + ")";
                    String jobInfo = rs.getString("job_title") + " [" + rs.getString("activity_type") + "]";
        %>
        <tr>
            <td><%= courseInfo %></td>
            <td><%= jobInfo %></td>
            <td><%= rs.getTimestamp("application_date") %></td>
            <td>
                <a href="view_job.jsp?jobId=<%= rs.getString("job_id") %>&from=my_applications.jsp" class="detail-btn">Detail</a>
            </td>
        </tr>
        <%
            }
            if (!hasData) {
        %>
        <tr><td colspan='4' class="no-data" style="text-align:center; padding:20px;">No applications found.</td></tr>
        <%
            }
            rs.close(); stmt.close(); conn.close();
        } catch (Exception e) {
        %>
        <tr><td colspan='4' class="error-msg">Error: <%= e.getMessage() %></td></tr>
        <%
                }
            }
        %>
    </table>
</div>
</body>
</html>