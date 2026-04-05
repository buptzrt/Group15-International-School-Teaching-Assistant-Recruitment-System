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
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #222;
            animation: fadeInBody 0.7s ease;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.85);
            z-index: -1;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 30px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            background: rgba(44, 62, 80, 0.95);
            backdrop-filter: blur(6px);
            animation: slideDown 0.7s ease;
        }

        .navbar-left, .navbar-right {
            display: flex;
            align-items: center;
        }

        .navbar-left h2 {
            margin: 0;
            margin-right: 40px;
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
            transform: scale(1.05);
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
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            transition: background 0.3s ease, transform 0.2s ease;
        }

        .logout-btn:hover {
            background: linear-gradient(135deg, #163357, #244a7c);
            transform: scale(1.05);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
        }

        .content {
            height: calc(100vh - 80px);
            background: transparent !important;
        }

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            opacity: 1;
            background: transparent;
        }

        @keyframes fadeInBody {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-18px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media screen and (max-width: 768px) {
            .navbar {
                flex-direction: column;
                align-items: flex-start;
                padding: 20px;
            }
            .navbar-left, .navbar-right {
                flex-direction: column;
                align-items: flex-start;
            }
            .navbar-left h2 {
                margin-bottom: 15px;
            }
            .navbar a, .logout-btn {
                margin-bottom: 10px;
                width: 100%;
                text-align: left;
            }
        }
    </style>
</head>

<body>
    <div class="navbar">
        <div class="navbar-left">
            <h2>Student Dashboard</h2>
            <a href="#" onclick="loadStudentSection('welcome_student.jsp', event)">Home</a>
            <a href="#" onclick="loadStudentSection('student_profile.html', event)">Manage Profile</a>
            <a href="#" onclick="loadStudentSection('StudentProfileServlet', event)">View My Profile</a>
            <a href="#" onclick="loadStudentSection('view_companies.jsp', event)">View Company List</a>
            <a href="#" onclick="loadStudentSection('my_applications.jsp', event)">My Applications</a>
        </div>
        <div class="navbar-right">
            <form action="LogoutServlet" method="get" style="margin:0;" onsubmit="confirmLogout(event);">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>

    <div class="content">
        <iframe id="contentFrame"
                src="welcome_student.jsp"
                onload="onStudentFrameLoad()"></iframe>
    </div>

    <script>
        function confirmLogout(event) {
            if (!confirm("Are you sure you want to logout?")) {
                event.preventDefault();
            }
        }

        function loadStudentSection(url, event) {
            event.preventDefault();
            var frame = document.getElementById("contentFrame");
            frame.src = url;
        }

        function onStudentFrameLoad() {
            var frame = document.getElementById("contentFrame");
            var doc = frame.contentDocument;
            if (!doc) return;

            try {
                // 1. 统一背景透明
                doc.body.style.background = "transparent";
                doc.body.style.backgroundColor = "transparent";

                // 2. 欢迎页文字变红（仅Home页生效）
                const allPs = doc.querySelectorAll("p");
                allPs.forEach(p => {
                    const t = p.textContent.trim();
                    if (t.startsWith("Hello,") || t.includes("view your profile") || t.includes("navigation menu")) {
                        p.style.color = "#E53935";
                        p.style.fontWeight = "bold";
                    }
                });

                // 3. ✅ 仅 Student Profile Overview 页面生效
                if (frame.src.includes("StudentProfileServlet")) {
                    const allElements = doc.querySelectorAll("*");
                    allElements.forEach(el => {
                        // 跳过绿色按钮（包含"Upload PDF"文字的按钮）及其内部文字
                        const isGreenButton = el.tagName === "BUTTON" && el.textContent.includes("Upload PDF");
                        const isInsideGreenButton = el.closest("button")?.textContent.includes("Upload PDF");

                        if (!isGreenButton && !isInsideGreenButton) {
                            // 强制所有非按钮内的文字为黑色
                            el.style.setProperty("color", "#000000", "important");
                        }
                    });
                }

                // 4. 统一白色卡片样式
                const profileBox = doc.querySelector(".profile-box, .student-profile-box, [class*='profile']");
                if (profileBox) {
                    profileBox.style.background = "rgba(255, 255, 255, 0.9)";
                }

            } catch (e) {
                console.error("样式修改错误:", e);
            }
        }
    </script>
</body>
</html>