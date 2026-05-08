<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.me.finaldesignproject.model.User" %>
<%
    if (session == null || session.getAttribute("role") == null ||
        !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String displayName = null;
    Object sessionUser = session.getAttribute("user");
    if (sessionUser instanceof User) {
        displayName = ((User) sessionUser).getFullName();
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        Object nameAttr = session.getAttribute("user_name");
        if (nameAttr != null) {
            displayName = String.valueOf(nameAttr);
        }
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        Object emailAttr = session.getAttribute("email");
        if (emailAttr != null) {
            displayName = String.valueOf(emailAttr);
        }
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        Object idAttr = session.getAttribute("userId");
        if (idAttr != null) {
            displayName = String.valueOf(idAttr);
        }
    }

    if (displayName == null || displayName.trim().isEmpty()) {
        displayName = "MO";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MO Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        #contentFrame {
            width: 100%;
            height: calc(100vh - 80px);
            border: none;
            display: block;
            background-color: transparent;
        }

        body {
            margin: 0;
            padding: 36px 18px;
            font-family: Georgia, "Times New Roman", serif;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #f4f7fb;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: -1;
        }

        .page-container {
            max-width: 1120px;
            margin: 0 auto;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 22px;
            padding: 20px 24px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 18px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
            backdrop-filter: blur(10px);
        }

        .navbar-left, .navbar-right {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 12px;
        }

        .navbar-left h2 {
            margin: 0;
            font-size: 28px;
            color: #ffd166;
            font-weight: 700;
        }

        .navbar a {
            color: #f4f7fb;
            text-decoration: none;
            font-size: 15px;
            padding: 10px 18px;
            border-radius: 999px;
            border: 1px solid rgba(255, 255, 255, 0.18);
            background: rgba(255, 255, 255, 0.05);
            transition: all 0.25s ease;
        }

        .navbar a:hover {
            background: rgba(255, 255, 255, 0.14);
            transform: translateY(-1px);
        }

        .logout-btn {
            background: #18b394;
            color: #fff;
            border: none;
            font-size: 15px;
            padding: 11px 22px;
            border-radius: 999px;
            cursor: pointer;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .logout-btn:hover {
            transform: translateY(-1px) scale(1.02);
            box-shadow: 0 12px 22px rgba(0, 0, 0, 0.18);
        }

        .welcome-card {
            margin-bottom: 22px;
            padding: 34px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.16);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
        }

        .welcome-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            background: rgba(255, 209, 102, 0.12);
            border: 1px solid rgba(255, 209, 102, 0.28);
            color: #ffe29a;
            font-size: 13px;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .welcome-card h3 {
            margin: 18px 0 12px;
            color: #ffd166;
            font-size: 34px;
            line-height: 1.2;
        }

        .welcome-lead {
            max-width: 760px;
            margin: 0;
            font-size: 16px;
            line-height: 1.85;
            color: #e2e8f0;
        }

        .welcome-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 18px;
            margin-top: 28px;
        }

        .info-block {
            padding: 22px;
            border-radius: 16px;
            background: rgba(9, 18, 33, 0.28);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .info-block h4 {
            margin: 0 0 10px;
            color: #f8d57d;
            font-size: 19px;
        }

        .info-block p {
            margin: 0;
            font-size: 15px;
            line-height: 1.8;
            color: #dbe5f3;
        }

        .feature-list {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
            margin-top: 28px;
        }

        .feature-item {
            padding: 22px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.12);
            transition: transform 0.25s ease, background 0.25s ease;
        }

        .feature-item:hover {
            transform: translateY(-3px);
            background: rgba(255, 255, 255, 0.1);
        }

        .feature-item h5 {
            margin: 0 0 10px;
            font-size: 18px;
            color: #f7c95f;
        }

        .feature-item p {
            margin: 0;
            font-size: 15px;
            line-height: 1.75;
            color: #d9e3f1;
        }

        .quick-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 28px;
        }

        .quick-action {
            color: #f4f7fb;
            text-decoration: none;
            font-size: 14px;
            padding: 11px 18px;
            border-radius: 999px;
            border: 1px solid rgba(255, 255, 255, 0.16);
            background: rgba(255, 255, 255, 0.08);
            transition: all 0.25s ease;
        }

        .quick-action:hover {
            background: rgba(24, 179, 148, 0.2);
            border-color: rgba(24, 179, 148, 0.45);
            transform: translateY(-1px);
        }

        .content {
            height: calc(100vh - 260px);
            padding-bottom: 20px;
        }

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.04);
            box-shadow: 0 18px 32px rgba(0, 0, 0, 0.16);
        }

        .hidden {
            display: none;
        }

        @media (max-width: 760px) {
            .navbar {
                padding: 18px 16px;
            }

            .welcome-card {
                padding: 24px 20px;
            }

            .welcome-card h3 {
                font-size: 28px;
            }

            .welcome-grid,
            .feature-list {
                grid-template-columns: 1fr;
            }

            .content {
                height: auto;
            }
        }
    </style>
    <script>
        function setActiveNav(target) {
            document.querySelectorAll(".nav-link").forEach(function(link) {
                link.classList.remove("active");
            });
            if (target) {
                target.classList.add("active");
            }
        }

        function showDashboard(event) {
            if (event) {
                event.preventDefault();
                setActiveNav(event.currentTarget);
            }
            document.getElementById("welcomeCard").classList.remove("hidden");
            document.getElementById("content").classList.add("hidden");
            document.getElementById("contentFrame").src = "about:blank";
        }

        function openSection(page, event) {
            if (event) {
                event.preventDefault();
                setActiveNav(event.currentTarget);
            }
            document.getElementById("welcomeCard").classList.add("hidden");
            document.getElementById("content").classList.remove("hidden");
            document.getElementById("contentFrame").src = page;
        }

        function confirmLogout(event) {
            if (!confirm("Are you sure you want to logout?")) {
                event.preventDefault();
            }
        }
    </script>
</head>
<body class="app-auth-bg dashboard-shell">
    <div class="page-container">
        <div class="navbar">
            <div class="navbar-left">
                <h2 class="dashboard-title"><span class="dashboard-icon">&#9719;</span><span>MO Dashboard</span></h2>
                <a class="nav-link active" href="#" onclick="showDashboard(event)"><span class="nav-link-icon">&#8981;</span>Dashboard</a>
                <a class="nav-link" href="#" onclick="openSection('mo_job_list.jsp', event)"><span class="nav-link-icon">&#9638;</span>Job List</a>
                <a class="nav-link" href="#" onclick="openSection('MOJobServlet', event)"><span class="nav-link-icon">&#10010;</span>Post Job</a>
                <a class="nav-link" href="#" onclick="openSection('mo_view_applications.jsp', event)"><span class="nav-link-icon">&#9998;</span>View Applications</a>
                <a class="nav-link" href="#" onclick="openSection('mo_filter_students.jsp', event)"><span class="nav-link-icon">&#9906;</span>Filter Students</a>
            </div>
            <div class="navbar-right">
                <form action="LogoutServlet" method="get" style="margin: 0;" onsubmit="confirmLogout(event);">
                    <button type="submit" class="logout-btn">Logout</button>
                </form>
            </div>
        </div>

        <div class="welcome-card home-panel" id="welcomeCard">
            <span class="home-kicker">Module Organizer Workspace</span>
            <div class="home-heading-row">
                <h3>Welcome, <%= displayName %></h3>
            </div>
            <div class="home-meta">
                <span>Role: MO</span>
                <span>Name: <%= displayName %></span>
            </div>
            <p class="home-lead">
                This home page is your recruitment control center. Use it to move from publishing a vacancy
                to reviewing candidates and narrowing the applicant pool.
            </p>

            <div class="home-grid">
                <div class="home-card">
                    <h4>Check Vacancies</h4>
                    <p>Open Job List to inspect visible opportunities and confirm current vacancy details.</p>
                </div>
                <div class="home-card">
                    <h4>Post or Update Jobs</h4>
                    <p>Use Post Job to create TA positions, edit requirements, or close roles that are no longer active.</p>
                </div>
                <div class="home-card">
                    <h4>Review Candidates</h4>
                    <p>Use View Applications and Filter Students to compare applicants before making decisions.</p>
                </div>
            </div>
        </div>

        <div class="content hidden" id="content">
            <iframe id="contentFrame" name="contentFrame" src="about:blank"></iframe>
        </div>
    </div>
</body>
</html>
