<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Registration</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap');

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #0c0c36, #123456, #1c5d82);
            color: #f0f0f0;
            margin: 0;
            min-height: 100vh;
            padding: 60px 20px;
            text-align: center;
            overflow-x: hidden;
            overflow-y: auto;
        }

        body::before {
            content: "";
            position: fixed;
            top: 50%;
            left: 50%;
            width: 600px;
            height: 600px;
            background: url('handshake-logo.jpeg') no-repeat center center;
            background-size: cover;
            border-radius: 50%;
            opacity: 0.08;
            transform: translate(-50%, -50%) scale(1);
            z-index: 0;
            pointer-events: none;
            animation: pulse 10s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: translate(-50%, -50%) scale(1); }
            50% { transform: translate(-50%, -50%) scale(1.05); }
        }

        h2 {
            color: #f9ca24;
            font-size: 36px;
            margin-bottom: 30px;
            animation: fadeInDown 1s ease-in-out forwards;
            position: relative;
            z-index: 1;
        }

        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        form {
            max-width: 600px;
            display: inline-block;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(10px);
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.35);
            z-index: 1;
            position: relative;
            animation: fadeInUp 1.2s ease forwards;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-bottom: 10px;
        }

        .form-group {
            flex: 1;
            min-width: 240px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #f9ca24;
            font-weight: 500;
            text-align: left;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: none;
            border-radius: 8px;
            background-color: rgba(255, 255, 255, 0.1);
            color: #fff;
            font-size: 15px;
            box-sizing: border-box;
            outline: none;
            transition: background-color 0.3s;
        }

        input:focus {
            background-color: rgba(255, 255, 255, 0.2);
        }

        input::placeholder { color: #ccc; }

        input[type="submit"] {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: white;
            font-weight: 600;
            font-size: 16px;
            border-radius: 25px;
            padding: 14px;
            border: none;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
            margin-top: 15px;
            width: 100%;
        }

        input[type="submit"]:hover {
            transform: scale(1.02);
            box-shadow: 0 0 15px rgba(249, 202, 36, 0.3);
        }

        .error {
            color: #ff4d4d;
            background: rgba(255, 0, 0, 0.1);
            padding: 12px;
            border-radius: 8px;
            font-weight: bold;
            margin-bottom: 20px;
            z-index: 1;
            position: relative;
        }

        .login-link {
            display: block;
            margin-top: 20px;
            color: #ccc;
            text-decoration: none;
            font-size: 14px;
        }

        .login-link:hover { color: #f9ca24; }
    </style>
</head>
<body>

<h2>Admin Registration</h2>

<% if (request.getAttribute("error") != null) { %>
<p class="error"><%= request.getAttribute("error") %></p>
<% } %>

<form action="AdminRegisterServlet" method="post">
    <div class="form-row">
        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="full_name" placeholder="Enter Admin Name" required>
        </div>
        <div class="form-group">
            <label>Admin ID / Staff No</label>
            <input type="text" name="enrollment_no" placeholder="e.g. AD001" required>
        </div>
    </div>

    <div class="form-row">
        <div class="form-group">
            <label>Admin Email</label>
            <input type="email" name="email" placeholder="admin@university.edu" required style="width: 100%;">
        </div>
    </div>

    <div class="form-row">
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Create password" required>
        </div>
        <div class="form-group">
            <label>Confirm Password</label>
            <input type="password" name="confirm_password" placeholder="Repeat password" required>
        </div>
    </div>

    <input type="submit" value="Register Admin Account">
    <a href="admin_login.jsp" class="login-link">Already have an admin account? Login here</a>
</form>

</body>
</html>