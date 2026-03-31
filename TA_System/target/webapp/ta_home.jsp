<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("role") == null
            || !"TA".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>TA Dashboard</title>
    <style>
        body {
            font-family: 'Segoe UI', 'PingFang SC', sans-serif;
            margin: 0;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #fff;
            animation: fadeInBody 0.7s ease;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 30px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            background: rgba(44, 62, 80, 0.95);
            backdrop-filter: blur(6px);
        }

        .navbar-left, .navbar-right {
            display: flex;
            align-items: center;
        }

        .navbar-left h2 {
            margin: 0 40px 0 0;
            font-size: 24px;
            color: #f9ca24;
            font-weight: 600;
        }

        .navbar a {
            margin: 0 12px;
            color: #ecf0f1;
            text-decoration: none;
            font-size: 16px;
            padding: 8px 16px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .navbar a:hover {
            background-color: #00b894;
            color: #fff;
        }

        .logout-btn {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: #f1f1f1;
            border: none;
            font-size: 15px;
            padding: 9px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
        }

        .logout-btn:hover {
            transform: scale(1.05);
        }

        .content {
            height: calc(100vh - 56px);
        }

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            background: #f5f6fa;
        }

        @keyframes fadeInBody {
            from { opacity: 0; }
            to { opacity: 1; }
        }
    </style>
    <script>
        function confirmLogout(event) {
            if (!confirm("确定要退出登录吗？")) {
                event.preventDefault();
            }
        }

        function loadSection(url, event) {
            event.preventDefault();
            document.getElementById("contentFrame").src = url;
        }
    </script>
</head>
<body>
    <div class="navbar">
        <div class="navbar-left">
            <h2>TA Dashboard</h2>
            <a href="#" onclick="loadSection('ta_profile.html', event)">Manage TA Profile</a>
        </div>
        <div class="navbar-right">
            <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="confirmLogout(event);">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>
    <div class="content">
        <iframe id="contentFrame" title="TA content" src="ta_profile.html"></iframe>
    </div>
</body>
</html>
