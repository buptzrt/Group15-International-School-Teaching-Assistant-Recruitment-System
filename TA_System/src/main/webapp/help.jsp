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
            font-family: 'Nunito', "Arial Rounded MT Bold", sans-serif;
        }

        body {
            background: url("images/bupt_campus_bg.jpg") no-repeat center center fixed;
            background-size: cover;
            color: #222;
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
            color: #222;
            font-weight: 700;
            padding: 10px 18px;
            border: 2px solid #222;
            border-radius: 14px;
            background-color: rgba(255,255,255,0.9);
            transition: all 0.3s ease;
        }

        .top-nav a:hover {
            background-color: #ffe8e8;
        }

        .main-content {
            width: 90%;
            max-width: 1000px;
            margin: 100px auto;
            animation: fadeInUp 0.8s ease;
        }

        .title {
            text-align: center;
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 15px;
        }

        .title-line {
            width: 100%;
            height: 4px;
            background: #222;
            margin-bottom: 40px;
        }

        .intro {
            text-align: center;
            font-size: 22px;
            color: #d63031;
            font-weight: 700;
            margin-bottom: 40px;
        }

        .card {
            background: rgba(255,255,255,0.92);
            border: 3px solid #222;
            border-radius: 20px;
            padding: 28px;
            margin-bottom: 25px;
        }

        .card h2 {
            font-size: 26px;
            margin-bottom: 15px;
        }

        .card p, .card li {
            font-size: 18px;
            line-height: 1.7;
        }

        .card ul {
            padding-left: 20px;
        }

        .github-box {
            margin-top: 20px;
            text-align: center;
            border: 2px solid #222;
            border-radius: 18px;
            padding: 20px;
            background: #fff;
        }

        .github-box a {
            color: #d63031;
            font-weight: 700;
            text-decoration: none;
        }

        .github-box a:hover {
            text-decoration: underline;
        }

        .footer-nav {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-bottom: 30px;
        }

        .footer-nav a {
            text-decoration: none;
            color: #222;
            font-weight: 600;
        }

        .divider {
            width: 2px;
            height: 20px;
            background: #222;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px);}
            to { opacity: 1; transform: translateY(0);}
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