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
            font-family: Georgia, "Times New Roman", serif;
        }

        html, body {
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            position: relative;
        }

        body {
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #f4f7fb;
            margin: 0;
            padding: 0;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: 1;
        }

        .bg-mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: transparent;
            z-index: 1;
        }

        .header-logos {
            position: absolute;
            top: 30px;
            left: 30px;
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 24px;
            padding: 28px 32px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(12px);
        }
        .logo-item {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .logo-item img {
            width: 65px;
            height: 65px;
            object-fit: contain;
            background: rgba(255, 255, 255, 0.85);
            padding: 10px;
            border-radius: 50%;
            box-shadow: 0 4px 12px rgba(255, 255, 255, 0.15);
        }
        .logo-text {
            font-size: 15px;
            color: #e8eef7;
            font-weight: 600;
            line-height: 1.5;
            letter-spacing: 0.3px;
        }

        .top-back-nav {
            position: absolute;
            top: 30px;
            right: 30px;
            z-index: 10;
            display: flex;
            flex-direction: row;
            gap: 14px;
            align-items: center;
        }
        .top-back-nav a {
            font-size: 16px;
            font-weight: 600;
            color: #e8eef7;
            text-decoration: none;
            transition: all 0.3s ease;
            padding: 12px 28px;
            border-radius: 50px;
            display: inline-block;
            background: rgba(255, 255, 255, 0.08);
            border: 1.5px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            position: relative;
            overflow: hidden;
        }
        .top-back-nav a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.15), transparent);
            transition: left 0.5s ease;
        }
        .top-back-nav a:hover::before {
            left: 100%;
        }
        .top-back-nav a:hover {
            background: rgba(255, 255, 255, 0.12);
            color: #f4f7fb;
            border-color: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(255, 255, 255, 0.15);
        }

        .login-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 10;
            text-align: center;
            width: 90%;
            max-width: 520px;
            animation: fadeInUp 0.8s ease-out;
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3), inset 0 1px 1px rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            padding: 56px 48px;
        }

        .login-subtitle {
            font-size: 24px;
            font-weight: 600;
            color: #b0c4de;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            margin-bottom: 12px;
            opacity: 0.9;
        }

        .login-title {
            font-size: 36px;
            font-weight: 700;
            color: #f4f7fb;
            margin-bottom: 8px;
            letter-spacing: 1px;
        }

        .title-line {
            width: 80px;
            height: 3px;
            background: linear-gradient(to right, #c0d9e8, rgba(192, 217, 232, 0.2));
            margin: 0 auto 48px auto;
            border-radius: 2px;
        }

        .input-group {
            display: flex;
            flex-direction: column;
            gap: 22px;
            margin-bottom: 32px;
            align-items: center;
        }
        .input-item {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-start;
        }
        .input-item label {
            font-size: 17px;
            font-weight: 700;
            color: #b0c4de;
            white-space: nowrap;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .input-item input {
            width: 100%;
            border: 1.5px solid rgba(255, 255, 255, 0.15);
            outline: none;
            font-size: 18px;
            padding: 18px 20px;
            background-color: rgba(255, 255, 255, 0.06);
            color: #f4f7fb;
            border-radius: 14px;
            transition: all 0.3s ease;
            font-family: Georgia, "Times New Roman", serif;
        }
        .input-item input::placeholder {
            color: rgba(244, 247, 251, 0.4);
        }
        .input-item input:focus {
            background-color: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.3);
            box-shadow: 0 0 25px rgba(192, 217, 232, 0.25);
            transform: translateY(-1px);
        }

        .login-btn {
            padding: 16px 48px;
            font-size: 20px;
            font-weight: 700;
            background: linear-gradient(135deg, #18b394 0%, #14a085 100%);
            border: 1.5px solid rgba(255, 255, 255, 0.15);
            border-radius: 14px;
            color: #fff;
            cursor: pointer;
            margin-bottom: 28px;
            width: 100%;
            transition: all 0.3s ease;
            font-family: Georgia, "Times New Roman", serif;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: relative;
            overflow: hidden;
        }
        .login-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.1);
            transition: left 0.5s ease;
            z-index: -1;
        }
        .login-btn:hover::before {
            left: 100%;
        }
        .login-btn:hover {
            background: linear-gradient(135deg, #1acd9f 0%, #18b394 100%);
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(24, 179, 148, 0.4);
            border-color: rgba(255, 255, 255, 0.25);
        }
        .login-btn:active {
            transform: translateY(-1px);
        }

        .remember-group {
            width: 100%;
            margin: 0 auto 20px auto;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .remember-group input {
            width: 20px;
            height: 20px;
            accent-color: #18b394;
            cursor: pointer;
        }
        .remember-group label {
            font-size: 16px;
            font-weight: 500;
            color: #e8eef7;
            cursor: pointer;
            margin: 0;
        }

        .link-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .link-group p {
            font-size: 16px;
            color: #e2e8f0;
            margin: 0;
        }
        .link-group a {
            color: #b0c4de;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s ease;
            display: inline;
            border-bottom: 1px dotted #b0c4de;
        }
        .link-group a:hover {
            color: #e8eef7;
            border-bottom-style: solid;
        }

        .error-msg {
            background-color: rgba(220, 38, 38, 0.15);
            color: #fca5a5;
            padding: 14px 16px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 24px;
            font-weight: 600;
            font-size: 16px;
            border-left: 3px solid #dc2626;
            border: 1px solid rgba(220, 38, 38, 0.3);
            border-left: 3px solid #dc2626;
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
            .login-content {
                padding: 40px 28px;
                max-width: 90%;
            }
            .login-title {
                font-size: 36px;
            }
            .login-subtitle {
                font-size: 14px;
            }
            .input-item label, .remember-group label {
                font-size: 15px;
            }
            .input-item input {
                font-size: 16px;
                padding: 14px 16px;
            }
            .link-group p {
                font-size: 14px;
            }
            .login-btn {
                font-size: 18px;
                padding: 14px 28px;
            }
            .top-back-nav {
                flex-direction: column;
                gap: 10px;
                top: 20px;
                right: 20px;
            }
            .top-back-nav a {
                font-size: 14px;
                padding: 10px 20px;
            }
            .logo-item img {
                width: 50px;
                height: 50px;
            }
            .logo-text {
                font-size: 13px;
            }
            .header-logos {
                padding: 20px 24px;
                gap: 18px;
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
        <p class="login-subtitle">TA Recruitment System</p>
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


