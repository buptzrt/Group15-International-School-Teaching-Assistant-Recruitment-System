<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | Choose Role</title>
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
        }

        .header-logos {
            position: absolute;
            top: 0;
            left: 0;
            z-index: 10;
            display: flex;
            flex-direction: column;
            gap: 24px;
            padding: 28px 32px;
            width: min(520px, 28vw);
            min-width: 440px;
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
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
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
            margin: 0 auto 36px auto;
            border-radius: 2px;
        }

        .sub-desc {
            font-size: 16px;
            color: #e2e8f0;
            line-height: 1.8;
            margin-bottom: 28px;
        }

        .role-group {
            display: flex;
            flex-direction: column;
            gap: 18px;
            margin-bottom: 24px;
        }

        .choice-btn {
            display: inline-block;
            width: 100%;
            padding: 16px 24px;
            font-size: 20px;
            font-weight: 700;
            background: linear-gradient(135deg, #18b394 0%, #14a085 100%);
            border: 1.5px solid rgba(255, 255, 255, 0.15);
            border-radius: 14px;
            text-decoration: none;
            text-align: center;
            color: #fff;
            transition: all 0.3s ease;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .choice-btn:hover {
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
                transform: translate(-50%, 20px);
            }
            to {
                opacity: 1;
                transform: translate(-50%, 0);
            }
        }

        @media (max-width: 1360px) {
            .header-logos {
                width: 360px;
                min-width: 360px;
            }
        }

        @media (max-width: 1180px) {
            body {
                padding: 20px 14px;
            }

            .page-stage {
                min-height: auto;
                display: flex;
                flex-direction: column;
                gap: 18px;
            }

            .header-logos,
            .top-back-nav,
            .register-content {
                position: static;
                transform: none;
                width: 100%;
                max-width: 640px;
                margin-left: auto;
                margin-right: auto;
            }

            .header-logos {
                min-width: 0;
                padding: 20px 24px;
                gap: 18px;
            }

            .top-back-nav {
                justify-content: center;
            }

            .register-content {
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

            .choice-btn {
                font-size: 18px;
                padding: 14px 22px;
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
            <a href="index.html">Back to Home</a>
            <a href="javascript:history.back()">Return</a>
        </div>

        <div class="register-content">
            <p class="register-subtitle">TA Recruitment System</p>
            <h1 class="register-title">Register</h1>
            <div class="title-line"></div>
            <p class="sub-desc">Please select one role to continue registration.</p>

            <div class="role-group">
                <a href="mo_register.jsp" class="choice-btn">MO Registration</a>
                <a href="student_register.jsp" class="choice-btn">Student Registration</a>
            </div>

            <div class="link-group">
                <p>Already have an account? <a href="login.jsp">Login here.</a></p>
            </div>
        </div>
    </div>
</body>
</html>
