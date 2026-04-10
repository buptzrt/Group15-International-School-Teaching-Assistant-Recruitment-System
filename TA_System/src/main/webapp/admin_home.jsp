<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.me.finaldesignproject.model.User" %>
<%@ page import="com.me.finaldesignproject.dao.UserDao" %>
<%
    if (session == null || session.getAttribute("role") == null ||
        !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String displayName = null;
    String displayEmail = null;
    String displayId = null;

    Object sessionUser = session.getAttribute("user");
    if (sessionUser instanceof User) {
        User u = (User) sessionUser;
        displayName = u.getFullName();
        displayEmail = u.getEmail();
        displayId = u.getEnrollmentNo();
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        Object v = session.getAttribute("user_name");
        if (v != null) displayName = String.valueOf(v);
    }
    if (displayEmail == null || displayEmail.trim().isEmpty()) {
        Object v = session.getAttribute("user_email");
        if (v != null) displayEmail = String.valueOf(v);
    }
    if (displayId == null || displayId.trim().isEmpty()) {
        Object v = session.getAttribute("user_id");
        if (v != null) displayId = String.valueOf(v);
    }

    if (displayId == null || displayId.trim().isEmpty()) {
        Object v = session.getAttribute("userId");
        if (v != null) displayId = String.valueOf(v);
    }
    if (displayEmail == null || displayEmail.trim().isEmpty()) {
        Object v = session.getAttribute("email");
        if (v != null) displayEmail = String.valueOf(v);
    }

    if ((displayName == null || displayName.trim().isEmpty()) && displayId != null && !displayId.trim().isEmpty()) {
        User dbUser = new UserDao().getUserByEnrollment(displayId);
        if (dbUser != null) {
            if (displayName == null || displayName.trim().isEmpty()) displayName = dbUser.getFullName();
            if (displayEmail == null || displayEmail.trim().isEmpty()) displayEmail = dbUser.getEmail();
        }
    }

    if (displayName == null || displayName.trim().isEmpty()) displayName = "-";
    if (displayEmail == null || displayEmail.trim().isEmpty()) displayEmail = "-";
    if (displayId == null || displayId.trim().isEmpty()) displayId = "-";
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
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: white;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: -1;
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
        <h3>Welcome, <%= displayName %></h3>
        <p>This is the Admin Dashboard.</p>
        <p>You have successfully logged in as <strong>Admin</strong>.</p>
        <p>Email: <%= displayEmail %></p>
        <p>ID: <%= displayId %></p>
    </div>
</body>
</html>
