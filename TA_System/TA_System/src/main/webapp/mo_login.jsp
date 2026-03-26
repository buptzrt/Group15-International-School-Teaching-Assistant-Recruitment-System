<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MO Login</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #141e30, #243b55);
            color: #f0f0f0;
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        body::before {
            content: "";
            position: fixed;
            top: 50%;
            left: 50%;
            width: 560px;
            height: 560px;
            background: url('images/handshake-logo.jpg') no-repeat center center;
            background-size: cover;
            border-radius: 50%;
            opacity: 0.08;
            transform: translate(-50%, -50%);
            z-index: 0;
            pointer-events: none;
        }

        .card {
            width: 100%;
            max-width: 440px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(8px);
            border-radius: 14px;
            padding: 28px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
            position: relative;
            z-index: 1;
        }

        h2 {
            margin-top: 0;
            margin-bottom: 16px;
            text-align: center;
            color: #f9ca24;
            font-size: 32px;
        }

        .msg {
            text-align: center;
            color: #95ffb9;
            font-weight: 500;
            margin: 0 0 12px;
        }

        .error {
            color: #ff8080;
            text-align: center;
            font-weight: 500;
            margin: 0 0 12px;
        }

        label {
            display: block;
            margin-top: 12px;
            margin-bottom: 6px;
            font-weight: 500;
        }

        input {
            width: 100%;
            box-sizing: border-box;
            padding: 11px;
            border: none;
            border-radius: 8px;
            outline: none;
        }

        button {
            width: 100%;
            margin-top: 18px;
            padding: 12px;
            border: none;
            border-radius: 8px;
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: #fff;
            font-weight: 600;
            cursor: pointer;
        }

        .link {
            margin-top: 12px;
            text-align: center;
        }

        .link a {
            color: #7ed6ff;
            text-decoration: none;
        }

        .link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>MO Login</h2>

        <% if ("success".equals(request.getParameter("registered"))) { %>
            <p class="msg">Registration successful. Please login.</p>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>

        <form method="post" action="MOLoginServlet">
            <label>MO ID or Email</label>
            <input type="text" name="loginId" required>

            <label>Password</label>
            <input type="password" name="password" required>

            <button type="submit">Login</button>
        </form>

        <div class="link">
            <a href="mo_register.jsp">Don't have an account? Register</a>
        </div>
    </div>
</body>
</html>