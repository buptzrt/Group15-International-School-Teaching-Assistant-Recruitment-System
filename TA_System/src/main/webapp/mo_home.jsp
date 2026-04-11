<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("role") == null ||
        !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MO Dashboard</title>
    <style>
        /* 🌟 针对 contentFrame 的完美全屏修复 🌟 */
        #contentFrame {
            width: 100%;
            /* 这里的 80px 是假设你顶部导航栏的高度。
               如果导航栏更厚或更薄，你可以把 80px 改成 70px 或 90px 等，自己微调一下 */
            height: calc(100vh - 80px);
            border: none; /* 去掉默认的丑陋凹陷边框 */
            display: block; /* 防止底部出现神秘的几像素留白 */
            background-color: transparent; /* 保持玻璃拟物风格的通透感 */
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
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
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
            padding: 28px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.16);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
        }

        .welcome-card h3 {
            margin-top: 0;
            color: #ffd166;
            font-size: 32px;
        }

        .welcome-card p {
            margin: 10px 0 0;
            font-size: 16px;
            line-height: 1.7;
            color: #e2e8f0;
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

            .content {
                height: auto;
            }
        }
    </style>
    <script>
        function showDashboard(event) {
            if (event) {
                event.preventDefault();
            }
            document.getElementById("welcomeCard").classList.remove("hidden");
            document.getElementById("content").classList.add("hidden");
            document.getElementById("contentFrame").src = "about:blank";
        }

        function openSection(page, event) {
            if (event) {
                event.preventDefault();
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
<body>
    <div class="page-container">
    <div class="navbar">
        <div class="navbar-left">
            <h2>MO Dashboard</h2>
            <a href="#" onclick="showDashboard(event)">Dashboard</a>
            <a href="#" onclick="openSection('mo_job_list.jsp', event)">Job List</a>
            <a href="#" onclick="openSection('MOJobServlet', event)">Post Job</a>
            <a href="#" onclick="openSection('mo_view_applications.jsp', event)">View Applications</a>
            <a href="#" onclick="openSection('filter_students.jsp', event)">Filter Students</a>
        </div>
        <div class="navbar-right">
            <form action="LogoutServlet" method="get" style="margin: 0;" onsubmit="confirmLogout(event);">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

    <div class="welcome-card" id="welcomeCard">
        <h3>Welcome <%= session.getAttribute("user_name") %></h3>
        <p>
            Welcome to the MO Dashboard.
            You can post job openings, view student applications, and filter candidates.
        </p>
    </div>

    <div class="content hidden" id="content">
        <iframe id="contentFrame" name="contentFrame" src="about:blank"></iframe>
    </div>
    </div>
</body>
</html>

