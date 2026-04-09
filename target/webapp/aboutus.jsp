<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About System - TA Recruitment System</title>
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
            min-height: 100%;
            position: relative;
        }

        body {
            background: url("images/bupt_campus_bg.jpg") no-repeat center center fixed;
            background-size: cover;
            color: #222;
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

        .page-wrapper {
            position: relative;
            z-index: 10;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header-logos {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 20;
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .logo-item {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-item img {
            width: 75px;
            height: 75px;
            object-fit: contain;
            border-radius: 12px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.1);
        }

        .logo-text {
            font-size: 17px;
            color: #000;
            font-weight: 600;
            line-height: 1.4;
        }

        .top-nav {
            width: 100%;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 28px 40px 0 40px;
            gap: 18px;
        }

        .top-nav a {
            text-decoration: none;
            color: #222;
            font-size: 18px;
            font-weight: 700;
            padding: 10px 18px;
            border: 2px solid #222;
            border-radius: 14px;
            background-color: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
        }

        .top-nav a:hover {
            background-color: #ffe8e8;
            transform: translateY(-2px);
        }

        .main-content {
            flex: 1;
            width: 90%;
            max-width: 1100px;
            margin: 140px auto 80px auto;
            animation: fadeInUp 0.8s ease-out;
        }

        .page-title {
            text-align: center;
            font-size: 52px;
            font-weight: 800;
            color: #222;
            line-height: 1.2;
            margin-bottom: 18px;
            letter-spacing: 1px;
        }

        .title-line {
            width: 100%;
            max-width: 760px;
            height: 4px;
            background-color: #222;
            margin: 0 auto 40px auto;
            border-radius: 4px;
        }

        .intro-text {
            text-align: center;
            font-size: 24px;
            line-height: 1.7;
            color: #d63031;
            font-weight: 700;
            max-width: 920px;
            margin: 0 auto 45px auto;
        }

        .content-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 28px;
        }

        .card {
            background-color: rgba(255, 255, 255, 0.88);
            border: 3px solid #222;
            border-radius: 22px;
            padding: 30px 28px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 10px 24px rgba(0,0,0,0.12);
        }

        .card h2 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 16px;
            color: #222;
        }

        .card p {
            font-size: 18px;
            line-height: 1.8;
            color: #333;
        }

        .card ul {
            padding-left: 22px;
            margin-top: 8px;
        }

        .card ul li {
            font-size: 18px;
            line-height: 1.8;
            color: #333;
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
            font-size: 20px;
            font-weight: 600;
            padding: 24px 0 30px 0;
        }

        .footer-nav a {
            text-decoration: none;
            color: #222;
            transition: all 0.2s ease;
            padding: 5px 10px;
            border-radius: 8px;
        }

        .footer-nav a:hover {
            color: #d63031;
            background-color: rgba(255,255,255,0.7);
        }

        .divider {
            width: 2px;
            height: 26px;
            background-color: #222;
            border-radius: 2px;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
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
                font-size: 20px;
            }

            .top-nav {
                justify-content: center;
                flex-wrap: wrap;
                padding-top: 120px;
            }

            .header-logos {
                position: static;
                padding: 20px 20px 0 20px;
            }

            .main-content {
                margin-top: 40px;
            }

            .footer-nav {
                gap: 20px;
                font-size: 16px;
                flex-wrap: wrap;
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

        <div class="top-nav">
            <a href="index.html">Home</a>
            <a href="contact.jsp">Contact</a>
            <a href="help.jsp">Help</a>
        </div>

        <main class="main-content">
            <h1 class="page-title">About the TA Recruitment System</h1>
            <div class="title-line"></div>

            <p class="intro-text">
                This system was developed for the International School of Beijing University of Posts and Telecommunications
                to support the recruitment and management of Teaching Assistants in a clearer, faster, and more organized way.
            </p>

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