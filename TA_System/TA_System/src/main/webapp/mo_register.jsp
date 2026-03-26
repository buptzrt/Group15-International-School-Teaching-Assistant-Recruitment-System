<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MO Registration</title>
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
            max-width: 600px;
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

        .error {
            color: #ff8080;
            text-align: center;
            font-weight: 500;
            margin: 0 0 12px;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .full {
            grid-column: 1 / -1;
        }

        label {
            display: block;
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
            margin-top: 16px;
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

        @media (max-width: 700px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="card">
        <h2>MO Registration</h2>

        <% if (request.getAttribute("error") != null) { %>
            <p class="error"><%= request.getAttribute("error") %></p>
        <% } %>

        <form action="MORegisterServlet" method="post">
            <div class="grid">
                <div>
                    <label>Full Name</label>
                    <input type="text" name="company_name" required>
                </div>
                <div>
                    <label>MO ID</label>
                    <input type="text" name="enrollment_no" placeholder="MO001">
                </div>
                <div class="full">
                    <label>Email</label>
                    <input type="email" name="email" required>
                </div>
                <div>
                    <label>Password</label>
                    <input type="password" name="password" required>
                </div>
                <div>
                    <label>Confirm Password</label>
                    <input type="password" name="confirm_password" required>
                </div>
            </div>
            <button type="submit">Register MO</button>
        </form>

        <div class="link">
            <a href="mo_login.jsp">Already have an account? Login</a>
        </div>
    </div>
</body>
</html>
