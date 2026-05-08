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
            Use this guide to understand the main workflow for Students, Module Organisers, and Admin users.
        </p>

        <div class="card">
            <h2>Getting Started</h2>
            <ul>
                <li>Open Register to choose either Student Registration or MO Registration.</li>
                <li>After registration, use Login with your ID or email and password.</li>
                <li>The system will open the correct dashboard automatically according to your role.</li>
                <li>Use Logout on the top-right of the dashboard when you finish your work.</li>
            </ul>
        </div>

        <div class="card">
            <h2>Student Guide</h2>
            <ul>
                <li>Home shows your role information and quick guidance for the student workflow.</li>
                <li>My Profile lets you view and edit your personal information, academic details, skills, experience, and resume information.</li>
                <li>View Job List shows available vacancies. You can search visible columns, filter by table headers, show only not expired jobs, view job details, and apply for suitable positions.</li>
                <li>AI Match and AI Gap Analysis help compare your profile with job requirements when analysis data is available.</li>
                <li>My Applications shows every submitted application, including MO creator, application date, status, workload warnings, and the job detail link.</li>
                <li>Application statuses are shown as Pending, Accepted, or Rejected. A workload warning appears when your applications may exceed the 20-hour limit.</li>
            </ul>
        </div>

        <div class="card">
            <h2>MO Guide</h2>
            <ul>
                <li>Dashboard provides shortcuts for checking vacancies, posting jobs, and reviewing candidates.</li>
                <li>Job List shows all visible vacancies with search, column filters, deadline filtering, and the option to show only not expired jobs.</li>
                <li>Post Job lets you create new TA vacancies, edit job requirements, close open jobs, re-open available closed jobs, delete jobs, and view job details.</li>
                <li>View Applications lists student submissions for your jobs. You can view student profiles, approve applications, reject applications, and mark overtime cases when needed.</li>
                <li>Filter Students runs AI candidate matching for a selected job and returns match scores plus evaluation reasons to support shortlisting.</li>
            </ul>
        </div>

        <div class="card">
            <h2>Admin Guide</h2>
            <ul>
                <li>Home summarizes the admin workspace and links to application and job management.</li>
                <li>Manage Application shows all submitted applications with statistics for total, accepted, rejected, and pending records.</li>
                <li>Use the status filter to focus on All, Pending, Accepted, or Rejected applications.</li>
                <li>Admin can approve, reject, or withdraw application decisions when an override is required.</li>
                <li>Manage Jobs shows all vacancies sorted by deadline by default. You can search the table, view details, edit jobs, close jobs, re-open jobs, and delete jobs.</li>
                <li>The job table also shows hall visibility rules, deadline-related hiding, quota left, and whether the vacancy needs admin attention.</li>
            </ul>
        </div>

        <div class="card">
            <h2>Tips for Daily Use</h2>
            <ul>
                <li>Use the search box when a table has many rows; it searches the visible columns on that page.</li>
                <li>Click table headers when filters are available. Use Clear All Filters to return to the full list.</li>
                <li>Jobs and applications use colored status badges so you can quickly distinguish open, closed, pending, accepted, and rejected records.</li>
                <li>If a pop-up detail page opens, use the back arrow in the upper-left of the detail panel to return.</li>
                <li>If AI analysis fails or times out, try again later or review the applicant information manually.</li>
            </ul>
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
