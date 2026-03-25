<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Registration</title>
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
            color: #ffdd57;
            font-size: 30px;
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
            max-width: 600px; /* 因为字段少了，把表单改窄一点更好看 */
            margin: auto;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(6px);
            padding: 35px;
            border-radius: 15px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.3);
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
        }

        .form-group {
            flex: 1;
            min-width: 220px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            color: #ffdd57;
            font-weight: 500;
            text-align: left;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 16px;
            border: none;
            border-radius: 10px;
            background-color: rgba(255, 255, 255, 0.1);
            color: #fff;
            font-size: 15px;
            box-sizing: border-box;
        }

        input::placeholder {
            color: #ccc;
        }

        input[type="submit"] {
            background-color: #1e90ff;
            color: white;
            font-weight: bold;
            font-size: 16px;
            border-radius: 25px;
            padding: 12px 30px;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.3s ease;
            margin-top: 10px;
            width: 100%; /* 按钮横跨整个底部 */
        }

        input[type="submit"]:hover {
            background-color: #187bcd;
            transform: scale(1.02);
        }

        .error {
            color: #ff4d4d;
            background: rgba(255, 0, 0, 0.1);
            padding: 12px;
            border-radius: 10px;
            font-weight: bold;
            margin-bottom: 20px;
            position: relative;
            z-index: 1;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .login-link {
            display: block;
            margin-top: 15px;
            color: #ccc;
            text-decoration: none;
            font-size: 14px;
        }

        .login-link:hover {
            color: #ffdd57;
        }

        @media screen and (max-width: 768px) {
            .form-row {
                flex-direction: column;
            }
            h2 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>

<h2>Create an Account</h2>

<% if (request.getAttribute("error") != null) { %>
<p class="error"><%= request.getAttribute("error") %></p>
<% } %>

<form action="StudentRegisterServlet" method="post">

    <div class="form-row">
        <div class="form-group">
            <label>Name</label>
            <input type="text" name="full_name" placeholder="Enter your full name" maxlength="100" required>
        </div>

        <div class="form-group">
            <label>Student/Staff ID</label>
            <input type="text" name="enrollment_no" placeholder="e.g. S12345" maxlength="20" required>
        </div>
    </div>

    <div class="form-row">
        <div class="form-group" style="flex: 100%;">
            <label>University Email</label>
            <input type="email" name="email" placeholder="student@university.edu" maxlength="100" required>
        </div>
    </div>

    <div class="form-row">
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Create a password" maxlength="255" required>
        </div>

        <div class="form-group">
            <label>Confirm Password</label>
            <input type="password" name="confirm_password" placeholder="Confirm your password" maxlength="255" required>
        </div>
    </div>

    <input type="submit" value="Register">

    <a href="student_login.jsp" class="login-link">Already have an account? Login here</a>
</form>

</body>
</html>
