<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Nunito', "Arial Rounded MT Bold", sans-serif;
        }

        html, body {
            width: 100%;
            min-height: 100vh;
        }

        body {
            background: url("images/bupt_campus_bg.jpg") no-repeat center center fixed;
            background-size: cover;
            position: relative;
            color: #222;
            padding: 32px 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
        }

        .bg-mask {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.85);
            z-index: 1;
        }

        .page-shell {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 880px;
            animation: fadeInUp 0.8s ease-out;
        }



        .card {
            width: 100%;
            background: rgba(255, 255, 255, 0.92);
            border: 3px solid #222;
            border-radius: 24px;
            padding: 32px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }

        h2 {
            text-align: center;
            font-size: 40px;
            font-weight: 800;
            color: #222;
            line-height: 1.2;
            margin-bottom: 16px;
        }

        .title-line {
            width: 100%;
            height: 4px;
            background-color: #222;
            margin: 0 auto 24px auto;
            border-radius: 4px;
        }

        .sub-desc {
            text-align: center;
            font-size: 21px;
            color: #d63031;
            line-height: 1.5;
            margin-bottom: 28px;
            font-weight: 600;
        }

        .error {
            color: #d63031;
            text-align: center;
            font-weight: 700;
            margin: 0 0 18px;
            font-size: 16px;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px 20px;
        }

        .full {
            grid-column: 1 / -1;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 700;
            color: #222;
            font-size: 16px;
        }

        input {
            width: 100%;
            box-sizing: border-box;
            padding: 13px 14px;
            border: 2px solid #222;
            border-radius: 16px;
            outline: none;
            background: rgba(255,255,255,0.96);
            font-size: 16px;
            color: #222;
            transition: all 0.25s ease;
        }

        input:focus {
            border-color: #d63031;
            box-shadow: 0 0 0 4px rgba(214, 48, 49, 0.12);
        }

        .btn-group,
        .role-group {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .action-btn,
        .choice-btn,
        button {
            display: inline-block;
            width: 100%;
            padding: 14px 24px;
            font-size: 22px;
            font-weight: 700;
            background-color: #fff;
            border: 3px solid #222;
            border-radius: 18px;
            text-decoration: none;
            text-align: center;
            color: #222;
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            margin-top: 20px;
        }

        .action-btn:hover,
        .choice-btn:hover,
        button:hover {
            background-color: #ffe8e8;
            transform: scale(1.02) translateY(-3px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.15);
        }

        .link,
        .footer-links {
            margin-top: 22px;
            text-align: center;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .link a,
        .footer-links a {
            color: #222;
            text-decoration: none;
            font-weight: 700;
            font-size: 16px;
            transition: all 0.2s ease;
        }

        .link a:hover,
        .footer-links a:hover {
            color: #d63031;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 768px) {
            body {
                padding: 20px 14px;
            }

            .card {
                padding: 24px 18px;
                border-radius: 20px;
            }

            h2 {
                font-size: 30px;
            }

            .sub-desc {
                font-size: 18px;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .action-btn,
            .choice-btn,
            button {
                font-size: 18px;
                padding: 12px 18px;
            }

            .logo-item img {
                width: 52px;
                height: 52px;
            }

            .logo-text {
                font-size: 14px;
            }
        }
    </style>

    <title>MO Registration</title>
</head>
<body>

    <div class="bg-mask"></div>

    <div class="page-shell">
        <div class="card">
            <h2>MO Registration</h2>
            <div class="title-line"></div>
            <p class="sub-desc">Create your MO account below.</p>

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
                <a href="register.jsp">Back to role selection</a>
                <a href="login.jsp">Already have an account? Login</a>
            </div>
        </div>

    </div>

</body>
</html>