<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");

    String savedLoginId = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("saved_login_id".equals(cookie.getName())) {
                savedLoginId = cookie.getValue();
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - TA Recruitment System</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Nunito', "Arial", sans-serif;
        }

        html, body {
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            position: relative;
        }

        body {
            background: url("images/bupt_campus_bg.jpg") no-repeat center center;
            background-size: cover;
        }
        .bg-mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.85);
            z-index: 1;
        }

        .header-logos {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 18px;
        }
        .logo-item {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .logo-item img {
            width: 55px;
            height: 55px;
            object-fit: contain;
        }
        .logo-text {
            font-size: 16px;
            color: #000;
            font-weight: 500;
            line-height: 1.4;
        }

        .top-back-nav {
            position: absolute;
            top: 20px;
            right: 30px;
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 12px;
            text-align: right;
        }
        .top-back-nav a {
            font-size: 24px;
            font-weight: 500;
            color: #0047ab;
            text-decoration: underline;
            transition: all 0.2s ease;
        }
        .top-back-nav a:hover {
            color: #002d6f;
        }

        .login-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 10;
            text-align: center;
            width: 90%;
            max-width: 700px;
            animation: fadeInUp 0.8s ease-out;
        }

        .login-title {
            font-size: 80px;
            font-weight: normal;
            color: #000;
            margin-bottom: 15px;
            letter-spacing: 2px;
        }

        .title-line {
            width: 100%;
            height: 3px;
            background-color: #000;
            margin: 0 auto 40px auto;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 25px;
            align-items: center;
        }
        .input-item {
            width: 100%;
            max-width: 550px;
            display: flex;
            align-items: center;
            border: 3px solid #000;
            background-color: #fff;
            border-radius: 4px;
        }
        .input-item label {
            font-size: 30px;
            font-weight: 500;
            color: #000;
            padding: 12px 15px;
            white-space: nowrap;
        }
        .input-item input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 26px;
            padding: 12px 15px;
            background-color: transparent;
        }

        .login-btn {
            padding: 12px 60px;
            font-size: 28px;
            font-weight: 600;
            background-color: #fff;
            border: 3px solid #000;
            border-radius: 8px;
            color: #000;
            cursor: pointer;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }
        .login-btn:hover {
            background-color: #f0f0f0;
            transform: scale(1.03);
        }

        .remember-group {
            width: 100%;
            max-width: 550px;
            margin: 0 auto 20px auto;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .remember-group input {
            width: 22px;
            height: 22px;
            accent-color: #c82027;
            cursor: pointer;
        }
        .remember-group label {
            font-size: 26px;
            font-weight: 500;
            color: #c82027;
            cursor: pointer;
        }

        .link-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .link-group p {
            font-size: 24px;
            color: #000;
        }
        .link-group a {
            color: #c82027;
            font-weight: 500;
            text-decoration: underline;
            transition: color 0.2s ease;
        }
        .link-group a:hover {
            color: #a01515;
        }

        .error-msg {
            background-color: #ffebee;
            color: #c62828;
            padding: 12px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 25px;
            font-weight: 600;
            font-size: 18px;
            border-left: 4px solid #c62828;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translate(-50%, -45%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }

        @media (max-width: 768px) {
            .login-title {
                font-size: 50px;
            }
            .input-item label, .remember-group label {
                font-size: 20px;
            }
            .input-item input {
                font-size: 18px;
            }
            .link-group p {
                font-size: 18px;
            }
            .login-btn {
                font-size: 22px;
                padding: 10px 40px;
            }
            .top-back-nav a {
                font-size: 18px;
            }
            .logo-item img {
                width: 40px;
                height: 40px;
            }
            .logo-text {
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <div class="bg-mask"></div>

    <div class="header-logos">
        <div class="logo-item">
            <img src="images/bupt_logo.png" alt="Beijing University of Posts and Telecommunications">
            <div class="logo-text">Beijing University of Posts and<br>Telecommunications</div>
        </div>
        <div class="logo-item">
            <img src="images/qmul_logo.png" alt="Queen Mary University of London">
            <div class="logo-text">Queen Mary University of London</div>
        </div>
    </div>

    <div class="top-back-nav">
        <a href="index.html">Back to Home</a>
        <a href="javascript:history.back()">Return</a>
    </div>

    <div class="login-content">
        <h1 class="login-title">Login</h1>
        <div class="title-line"></div>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="error-msg"><%= error %></div>
        <% } %>

        <form action="<%=request.getContextPath()%>/LoginServlet" method="POST">
            <div class="input-group">
                <div class="input-item">
                    <label for="loginId">User ID/Email:</label>
                    <input type="text" id="loginId" name="loginId" value="<%= savedLoginId %>" required>
                </div>
                <div class="input-item">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                </div>
            </div>

            <button type="submit" class="login-btn">Login</button>

            <div class="remember-group">
                <input type="checkbox" id="remember" name="remember" <%= !savedLoginId.isEmpty() ? "checked" : "" %>>
                <label for="remember">Remember me</label>
            </div>

            <div class="link-group">
                <p>Forgot Password? <a href="#">Click here to retrieve.</a></p>
                <p>Don't have an account? <a href="register.jsp">Register here.</a></p>
            </div>
        </form>
    </div>
</body>
</html>


