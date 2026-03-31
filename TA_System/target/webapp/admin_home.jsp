<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("role") == null ||
        !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background: linear-gradient(to right, #141e30, #243b55);
            color: white;
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

        .logout-btn {
            background: #2a5298;
            color: white;
            border: none;
            padding: 10px 18px;
            border-radius: 6px;
            cursor: pointer;
        }

        .logout-btn:hover {
            background: #1e3c72;
        }

        .container {
            width: 80%;
            margin: 40px auto;
            background: rgba(255,255,255,0.08);
            padding: 30px;
            border-radius: 12px;
        }

        h3 {
            color: #f9ca24;
        }
    </style>
    <script>
        function confirmLogout(event) {
            if (!confirm("Are you sure you want to logout?")) {
                event.preventDefault();
            }
        }
    </script>
</head>
<body>
    <div class="navbar">
        <div class="navbar-left">
            <h2>Admin Dashboard</h2>
            <a href="admin_home.jsp">Home</a>
            <a href="manage_students.jsp">Manage Students</a>
            <a href="manage_mo.jsp">Manage MO</a>
            <a href="manage_jobs.jsp">Manage Jobs</a>
        </div>
        <div>
            <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="confirmLogout(event)">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

    <div class="container">
        <h3>Welcome, <%= session.getAttribute("user_name") %></h3>
        <p>This is the Admin Dashboard.</p>
        <p>You have successfully logged in as <strong>Admin</strong>.</p>
        <p>Email: <%= session.getAttribute("user_email") %></p>
        <p>ID: <%= session.getAttribute("user_id") %></p>
    </div>
</body>
</html>