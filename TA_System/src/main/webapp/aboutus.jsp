<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About System - TA Recruitment System</title>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --page-text: #f4f7fb;
            --muted-text: #d8e3ef;
            --accent-text: #b0c4de;
            --accent-line: #c0d9e8;
            --card-bg: rgba(11, 27, 46, 0.76);
            --card-border: rgba(255, 255, 255, 0.14);
            --panel-bg: rgba(255, 255, 255, 0.08);
            --panel-border: rgba(255, 255, 255, 0.16);
            --nav-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Georgia, "Times New Roman", serif;
        }

        html, body {
            width: 100%;
            min-height: 100%;
            position: relative;
        }

        body {
            background-image: url("images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: var(--page-text);
            overflow-x: hidden;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(10, 22, 39, 0.84), rgba(18, 35, 61, 0.76));
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
            padding: 30px 30px 24px;
        }

        .header-logos {
            display: flex;
            flex-direction: column;
            gap: 24px;
            width: fit-content;
            padding: 28px 32px;
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            border-radius: 20px;
            box-shadow: var(--nav-shadow);
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
            top: 30px;
            right: 30px;
            z-index: 20;
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }

        .top-back-nav a {
            text-decoration: none;
            color: #e8eef7;
            font-size: 16px;
            font-weight: 600;
            padding: 12px 28px;
            border-radius: 50px;
            background: var(--panel-bg);
            border: 1.5px solid rgba(255, 255, 255, 0.2);
            box-shadow: var(--nav-shadow);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .top-back-nav a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.15), transparent);
            transition: left 0.5s ease;
        }

        .top-back-nav a:hover::before {
            left: 100%;
        }

        .top-back-nav a:hover {
            background: rgba(255, 255, 255, 0.12);
            color: var(--page-text);
            border-color: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
        }

        .main-content {
            flex: 1;
            width: 100%;
            max-width: 1180px;
            margin: 132px auto 80px auto;
            animation: fadeInUp 0.8s ease-out;
        }

        .intro-section {
            text-align: center;
            max-width: 860px;
            margin: 0 auto 54px auto;
        }

        .page-subtitle {
            font-size: 18px;
            font-weight: 600;
            color: var(--accent-text);
            letter-spacing: 4px;
            text-transform: uppercase;
            margin-bottom: 18px;
        }

        .page-title {
            text-align: center;
            font-size: clamp(42px, 5vw, 60px);
            font-weight: 700;
            color: var(--page-text);
            line-height: 1.2;
            margin-bottom: 18px;
            letter-spacing: 0.8px;
        }

        .title-line {
            width: 88px;
            height: 3px;
            background: linear-gradient(to right, var(--accent-line), rgba(192, 217, 232, 0.16));
            margin: 0 auto 32px auto;
            border-radius: 2px;
        }

        .intro-text {
            text-align: center;
            font-size: 20px;
            line-height: 1.7;
            color: var(--muted-text);
            font-weight: 500;
            max-width: 760px;
            margin: 0 auto;
        }

        .content-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 28px;
        }

        .card {
            background: linear-gradient(180deg, rgba(11, 27, 46, 0.82), var(--card-bg));
            border: 1px solid var(--card-border);
            border-radius: 24px;
            padding: 34px 30px;
            box-shadow: 0 22px 40px rgba(4, 11, 21, 0.28);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 26px 44px rgba(4, 11, 21, 0.34);
            border-color: rgba(255, 255, 255, 0.22);
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 30px;
            width: 64px;
            height: 3px;
            background: linear-gradient(90deg, #18b394, rgba(24, 179, 148, 0.1));
            border-radius: 999px;
        }

        .card h2 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 16px;
            color: var(--page-text);
        }

        .card p {
            font-size: 18px;
            line-height: 1.8;
            color: var(--muted-text);
        }

        .card ul {
            padding-left: 24px;
            margin-top: 8px;
        }

        .card ul li {
            font-size: 18px;
            line-height: 1.8;
            color: var(--muted-text);
            margin-bottom: 8px;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .footer-nav {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 50px;
            font-size: 16px;
            font-weight: 600;
            padding: 24px 0 6px 0;
            flex-wrap: wrap;
        }

        .footer-nav a {
            text-decoration: none;
            color: #e8eef7;
            transition: all 0.2s ease;
            padding: 8px 14px;
            border-radius: 8px;
        }

        .footer-nav a:hover {
            color: var(--page-text);
            background-color: rgba(255, 255, 255, 0.1);
        }

        .divider {
            width: 2px;
            height: 20px;
            background-color: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(26px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 900px) {
            .content-grid {
                grid-template-columns: 1fr;
            }

            .page-title {
                font-size: 38px;
            }

            .intro-text {
                font-size: 17px;
            }

            .page-wrapper {
                padding: 20px 20px 24px;
            }

            .header-logos {
                padding: 20px 24px;
                gap: 18px;
            }

            .main-content {
                margin-top: 40px;
            }

            .footer-nav {
                gap: 20px;
                font-size: 16px;
            }

            .top-back-nav {
                position: static;
                justify-content: center;
                margin-top: 18px;
            }

            .top-back-nav a {
                font-size: 14px;
                padding: 10px 20px;
            }

            .logo-item img {
                width: 50px;
                height: 50px;
            }

            .card {
                padding: 30px 24px;
            }

            .card h2 {
                font-size: 24px;
            }

            .card p,
            .card ul li {
                font-size: 16px;
            }
        }
    </style>
</head>
<body>
    <div class="bg-mask"></div>

    <div class="page-wrapper">
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
            <a href="contact.jsp">Contact</a>
            <a href="help.jsp">Help</a>
        </div>

        <main class="main-content">
            <section class="intro-section">
                <p class="page-subtitle">TA Recruitment System</p>
                <h1 class="page-title">About the Platform</h1>
                <div class="title-line"></div>
                <p class="intro-text">
                    This system was developed for the International School of Beijing University of Posts and Telecommunications
                    to support the recruitment and management of Teaching Assistants in a clearer, faster, and more organized way.
                </p>
            </section>

            <div class="content-grid">
                <section class="card">
                    <h2>Project Background</h2>
                    <p>
                        The TA Recruitment System is a software engineering project created by Group 15 for the Software Engineering course.
                        It was designed to improve the traditional recruitment process, which often relies on forms, spreadsheets,
                        and manual communication. By building a web-based platform, the team aimed to make TA recruitment more efficient,
                        transparent, and user-friendly for both applicants and administrators.
                    </p>
                </section>

                <section class="card">
                    <h2>Development Purpose</h2>
                    <p>
                        The purpose of this system is to provide a dedicated platform for publishing Teaching Assistant opportunities
                        within BUPT International School. It allows student applicants to view positions, submit applications,
                        and track their progress, while Module Organisers and administrators can manage vacancies, review candidates,
                        and coordinate recruitment work more effectively.
                    </p>
                </section>

                <section class="card">
                    <h2>Core Features</h2>
                    <ul>
                        <li>Create and manage applicant profiles</li>
                        <li>Browse available TA positions</li>
                        <li>Submit job applications online</li>
                        <li>Track application status</li>
                        <li>Support position posting and candidate selection</li>
                    </ul>
                </section>

                <section class="card">
                    <h2>Project Team</h2>
                    <p>
                        This system was developed by Software Engineering Group 15 as part of the course project.
                        The team followed an agile development approach throughout requirements analysis, design,
                        implementation, testing, and iterative improvement. The project also reflects collaborative development,
                        incremental delivery, and continuous feedback in practice.
                    </p>
                </section>

                <section class="card full-width">
                    <h2>System Value</h2>
                    <p>
                        More than just a course assignment, this platform serves as a focused recruitment solution for the International School.
                        It helps reduce repetitive manual work, improves communication between applicants and organisers,
                        and offers a more structured experience for TA recruitment each semester. The system also demonstrates
                        how software engineering methods can be applied to solve practical management problems in an academic environment.
                    </p>
                </section>
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
