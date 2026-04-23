<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help - TA Recruitment System</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Georgia, "Times New Roman", serif;
        }

        body {
            background-image: url("images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #f4f7fb;
            min-height: 100vh;
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
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: transparent;
            z-index: 1;
        }

        .page-wrapper {
            position: relative;
            z-index: 10;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .top-nav {
            display: flex;
            justify-content: flex-end;
            padding: 30px 40px;
            gap: 15px;
        }

        .top-nav a {
            text-decoration: none;
            color: #e8eef7;
            font-weight: 700;
            font-size: 16px;
            padding: 12px 24px;
            border: 1.5px solid rgba(255, 255, 255, 0.2);
            border-radius: 50px;
            background-color: rgba(255, 255, 255, 0.08);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .top-nav a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.15), transparent);
            transition: left 0.5s ease;
        }
        .top-nav a:hover::before {
            left: 100%;
        }
        .top-nav a:hover {
            background-color: rgba(255, 255, 255, 0.12);
            color: #f4f7fb;
            border-color: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
        }

        .main-content {
            width: 90%;
            max-width: 900px;
            margin: 60px auto 80px auto;
            animation: fadeInUp 0.8s ease;
        }

        .title {
            text-align: center;
            font-size: 44px;
            font-weight: 700;
            margin-bottom: 12px;
            color: #f4f7fb;
        }

        .title-line {
            width: 80px;
            height: 3px;
            background: linear-gradient(to right, #c0d9e8, rgba(192, 217, 232, 0.2));
            margin: 0 auto 40px auto;
            border-radius: 2px;
        }

        .intro {
            text-align: center;
            font-size: 18px;
            color: #b0c4de;
            font-weight: 600;
            margin-bottom: 40px;
        }

        .card {
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 20px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(12px);
        }

        .card h2 {
            font-size: 24px;
            margin-bottom: 18px;
            color: #f4f7fb;
            font-weight: 700;
        }

        .card p, .card li {
            font-size: 17px;
            line-height: 1.8;
            color: #e8eef7;
        }

        .card ul {
            padding-left: 24px;
        }

        .card li {
            margin-bottom: 12px;
        }

        .github-box {
            margin-top: 20px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 16px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
        }

        .github-box a {
            color: #b0c4de;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        .github-box a:hover {
            color: #f4f7fb;
            text-decoration: underline;
        }

        .footer-nav {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-bottom: 30px;
            font-size: 16px;
            font-weight: 600;
        }

        .footer-nav a {
            text-decoration: none;
            color: #e8eef7;
            transition: all 0.2s ease;
            padding: 8px 12px;
            border-radius: 8px;
        }

        .footer-nav a:hover {
            color: #f4f7fb;
            background-color: rgba(255, 255, 255, 0.1);
        }

        .divider {
            width: 2px;
            height: 20px;
            background: rgba(255, 255, 255, 0.3);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px);}
            to { opacity: 1; transform: translateY(0);}
        }

        @media (max-width: 768px) {
            .title {
                font-size: 32px;
            }
            .card {
                padding: 24px;
            }
            .card h2 {
                font-size: 20px;
            }
            .main-content {
                margin-top: 20px;
            }
        }
    </style>
</head>

<body>
<div class="bg-mask"></div>

<div class="page-wrapper">

    <div class="top-nav">
        <a href="index.html">Home</a>
        <a href="aboutus.jsp">About</a>
        <a href="contact.jsp">Contact</a>
        <a href="login.jsp">Login</a>
    </div>

    <main class="main-content">
        <h1 class="title">Help & User Guide</h1>
        <div class="title-line"></div>

        <p class="intro">
            This page provides guidance on how to use the Teaching Assistant Recruitment System.
        </p>

        <div class="card">
            <h2>For Students</h2>
            <ul>
                <li>Create an account and complete your personal profile.</li>
                <li>Browse available Teaching Assistant positions.</li>
                <li>Submit your application for the desired courses.</li>
                <li>Track your application status through the system.</li>
            </ul>
        </div>

        <div class="card">
            <h2>For Administrators / Module Organisers</h2>
            <ul>
                <li>Publish and manage TA recruitment positions.</li>
                <li>Review student applications efficiently.</li>
                <li>Select suitable candidates based on requirements.</li>
                <li>Maintain a structured and transparent recruitment process.</li>
            </ul>
        </div>

        <div class="card">
            <h2>System Features</h2>
            <p>
                The TA Recruitment System is designed to simplify and digitalize the recruitment workflow.
                It improves communication efficiency, reduces manual workload, and ensures a more organized
                application process for all users.
            </p>
        </div>

        <div class="github-box">
            <p>
                For more details about the system, project implementation, or technical support,
                please visit our GitHub repository:
            </p>
            <p>
                <a href="https://github.com/buptzrt/Group15_TA_SYSTEM" target="_blank">
                    https://github.com/buptzrt/Group15_TA_SYSTEM
                </a>
            </p>
            <p style="margin-top:10px;">
                You can also contact us through this repository.
            </p>
        </div>

    </main>

    <div class="footer-nav">
        <a href="aboutus.jsp">About</a>
        <div class="divider"></div>
        <a href="help.jsp">Help</a>
        <div class="divider"></div>
        <a href="contact.jsp">Contact</a>
    </div>

</div>
</body>
</html>