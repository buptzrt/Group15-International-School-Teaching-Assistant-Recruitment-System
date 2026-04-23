<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Georgia, "Times New Roman", serif;
        }

        html, body {
            width: 100%;
            min-height: 100vh;
            position: relative;
        }

        body {
            background-image: url("images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #f4f7fb;
            padding: 30px;
            overflow-x: hidden;
            overflow-y: auto;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: 1;
        }

        .bg-mask {
            position: fixed;
            inset: 0;
            background-color: transparent;
            z-index: 1;
        }

        .page-stage {
            position: relative;
            z-index: 10;
            min-height: calc(100vh - 60px);
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .header-logos {
            position: static;
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 24px;
            padding: 28px 32px;
            width: fit-content;
            max-width: 520px;
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
            top: 0;
            right: 0;
            z-index: 10;
            display: flex;
            gap: 14px;
            align-items: center;
            justify-content: flex-end;
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
        }

        .top-back-nav a:hover {
            background: rgba(255, 255, 255, 0.12);
            color: #f4f7fb;
            border-color: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
        }

        .register-content {
            position: static;
            z-index: 10;
            text-align: center;
            width: 100%;
            max-width: 760px;
            margin-left: auto;
            margin-right: auto;
            animation: fadeInUp 0.8s ease-out;
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3), inset 0 1px 1px rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            padding: 56px 48px;
        }

        .register-subtitle {
            font-size: 24px;
            font-weight: 600;
            color: #b0c4de;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            margin-bottom: 12px;
            opacity: 0.9;
        }

        .register-title {
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
            margin: 0 auto 42px auto;
            border-radius: 2px;
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
            border: 1px solid rgba(220, 38, 38, 0.3);
            border-left: 3px solid #dc2626;
        }

        .input-group {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 22px 20px;
            margin-bottom: 30px;
        }

        .input-item {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-start;
            text-align: left;
        }

        .input-item.full {
            grid-column: 1 / -1;
        }

        .input-item label {
            font-size: 17px;
            font-weight: 700;
            color: #b0c4de;
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
        }

        .input-item input::placeholder {
            color: rgba(244, 247, 251, 0.4);
        }

        .input-item input:focus {
            background-color: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.3);
            box-shadow: 0 0 25px rgba(192, 217, 232, 0.25);
        }

        .field-hint {
            font-size: 13px;
            color: rgba(216, 227, 239, 0.82);
            line-height: 1.5;
        }

        .register-btn {
            padding: 16px 48px;
            font-size: 20px;
            font-weight: 700;
            background: linear-gradient(135deg, #18b394 0%, #14a085 100%);
            border: 1.5px solid rgba(255, 255, 255, 0.15);
            border-radius: 14px;
            color: #fff;
            cursor: pointer;
            margin-bottom: 24px;
            width: 100%;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .register-btn:hover {
            background: linear-gradient(135deg, #1acd9f 0%, #18b394 100%);
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(24, 179, 148, 0.4);
            border-color: rgba(255, 255, 255, 0.25);
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

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 1180px) {
            body {
                padding: 20px 14px;
            }

            .page-stage {
                min-height: auto;
            }

            .header-logos {
                width: 100%;
                max-width: 760px;
                padding: 20px 24px;
                gap: 18px;
                margin-left: auto;
                margin-right: auto;
            }

            .top-back-nav {
                position: static;
                justify-content: center;
                flex-wrap: wrap;
                width: 100%;
                max-width: 760px;
                margin-left: auto;
                margin-right: auto;
            }

            .register-content {
                max-width: 760px;
                padding: 40px 28px;
            }
        }

        @media (max-width: 768px) {
            .register-title {
                font-size: 32px;
            }

            .register-subtitle {
                font-size: 14px;
            }

            .input-group {
                grid-template-columns: 1fr;
            }

            .input-item.full {
                grid-column: auto;
            }

            .input-item label {
                font-size: 15px;
            }

            .input-item input {
                font-size: 16px;
                padding: 14px 16px;
            }

            .register-btn {
                font-size: 18px;
                padding: 14px 28px;
            }

            .top-back-nav {
                flex-direction: column;
                gap: 10px;
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
        }
    </style>
</head>
<body>
    <div class="bg-mask"></div>

    <div class="page-stage">
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
            <a href="register.jsp">Back to Roles</a>
            <a href="login.jsp">Return</a>
        </div>

        <div class="register-content">
            <p class="register-subtitle">TA Recruitment System</p>
            <h1 class="register-title">Student Register</h1>
            <div class="title-line"></div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="StudentRegisterServlet" method="post">
                <div class="input-group">
                    <div class="input-item">
                        <label for="full_name">Full Name:</label>
                        <input type="text" id="full_name" name="full_name" required>
                    </div>
                    <div class="input-item">
                        <label for="enrollment_no">Student ID:</label>
                        <input type="text" id="enrollment_no" name="enrollment_no" placeholder="eg: 2023213070" pattern="^202[0-6](212|213)\d{3}$" maxlength="10" inputmode="numeric" required title="Use 2020-2026 + 212/213 + any 3 digits.">
                        <div class="field-hint">please input valid Student ID.</div>
                    </div>
                    <div class="input-item full">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="input-item">
                        <label for="password">Password:</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    <div class="input-item">
                        <label for="confirm_password">Confirm Password:</label>
                        <input type="password" id="confirm_password" name="confirm_password" required>
                    </div>
                </div>

                <button type="submit" class="register-btn">Register</button>

                <div class="link-group">
                    <p>Back to role selection? <a href="register.jsp">Click here.</a></p>
                    <p>Already have an account? <a href="login.jsp">Login here.</a></p>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
