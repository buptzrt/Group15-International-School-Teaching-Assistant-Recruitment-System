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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
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
<body class="app-auth-bg dashboard-shell admin-home-page">
    <div class="navbar">
        <div class="navbar-left">
            <h2 class="dashboard-title"><span class="dashboard-icon">&#9638;</span><span>Admin Dashboard</span></h2>
            <a class="nav-link active" href="admin_home.jsp"><span class="nav-link-icon">&#8962;</span>Home</a>
            <a class="nav-link" href="manage_students.jsp"><span class="nav-link-icon">&#9786;</span>Manage Application</a>
            <a class="nav-link" href="manage_jobs.jsp"><span class="nav-link-icon">&#9638;</span>Manage Jobs</a>
        </div>
        <div>
            <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="confirmLogout(event)">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

    <div class="container home-panel">
        <span class="home-kicker">Admin Workspace</span>
        <div class="home-heading-row">
            <h3>Welcome, <%= displayName %></h3>
        </div>
        <div class="home-meta">
            <span>Role: Admin</span>
            <span>Email: <%= displayEmail %></span>
            <span>ID: <%= displayId %></span>
        </div>
        <p class="home-lead">
            Use this home page as a quick control center for keeping applications, job visibility,
            and recruitment rules in order. Start with the area that needs review today.
        </p>

        <div class="home-grid">
            <div class="home-card">
                <h4>Review Applications</h4>
                <p>Open Manage Application to check student submissions, review status changes, and handle admin overrides.</p>
            </div>
            <div class="home-card">
                <h4>Monitor Jobs</h4>
                <p>Use Manage Jobs to confirm which vacancies are visible, closed, expired, or need admin attention.</p>
            </div>
            <div class="home-card">
                <h4>Keep Records Clear</h4>
                <p>Use the dashboard to keep each recruitment step traceable before module organizers make final decisions.</p>
            </div>
        </div>

    </div>
</body>
</html>
