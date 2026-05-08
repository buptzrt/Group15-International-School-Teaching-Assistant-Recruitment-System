<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%
    if (session == null || session.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    boolean isStudent = "Student".equalsIgnoreCase(role);
    if (!isStudent) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= isStudent ? "Student Dashboard" : "TA Dashboard" %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        body {
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            margin: 0;
            color: #eef4fb;
            position: relative;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin: 36px auto 20px;
            padding: 20px 24px;
            max-width: 1120px;
        }

        .navbar-left, .navbar-right {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .navbar-left h2 {
            margin: 0;
            color: #ffd166;
            font-size: 28px;
            font-weight: 700;
        }

        .logout-btn {
            font-size: 15px;
            padding: 11px 22px;
        }

        .content {
            max-width: 1120px;
            margin: 0 auto;
            height: calc(100vh - 150px);
            padding-bottom: 24px;
        }

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 22px;
            background: transparent;
            box-shadow: 0 18px 36px rgba(0, 0, 0, 0.18);
        }

        @media screen and (max-width: 768px) {
            .navbar {
                margin: 20px 14px 16px;
                padding: 18px;
            }

            .content {
                margin: 0 14px;
                height: calc(100vh - 170px);
            }
        }
    </style>
</head>
<body class="app-auth-bg dashboard-shell">
    <div class="navbar">
        <div class="navbar-left">
            <h2 class="dashboard-title"><span class="dashboard-icon">&#9673;</span><span>Student Dashboard</span></h2>
            <a class="nav-link active" href="#" onclick="loadStudentSection('welcome_student.jsp', event)"><span class="nav-link-icon">&#8962;</span>Home</a>
            <a class="nav-link" href="#" onclick="loadStudentSection('student_profile.html?dashboard=1', event)"><span class="nav-link-icon">&#9786;</span>My Profile</a>
            <a class="nav-link" href="#" onclick="loadStudentSection('StudentJobServlet', event)"><span class="nav-link-icon">&#9638;</span>View Job List</a>
            <a class="nav-link" href="#" onclick="loadStudentSection('my_applications.jsp', event)"><span class="nav-link-icon">&#9998;</span>My Applications</a>
        </div>
        <div class="navbar-right">
            <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="confirmLogout(event);">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

    <div class="content">
        <iframe id="contentFrame" src="welcome_student.jsp"></iframe>
    </div>

    <script>
        function setActiveNav(target) {
            document.querySelectorAll('.nav-link').forEach(function(link) {
                link.classList.remove('active');
            });
            if (target) {
                target.classList.add('active');
            }
        }

        function confirmLogout(event) {
            if (!confirm('Are you sure you want to logout?')) {
                event.preventDefault();
            }
        }

        function loadStudentSection(url, event) {
            event.preventDefault();
            setActiveNav(event.currentTarget);
            document.getElementById('contentFrame').src = url;
        }
    </script>
</body>
</html>
