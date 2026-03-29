<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact - TA Recruitment System</title>
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
            margin: 0 auto 35px auto;
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

        .contact-card {
            background-color: rgba(255, 255, 255, 0.90);
            border: 3px solid #222;
            border-radius: 22px;
            padding: 35px 30px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
        }

        .contact-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 24px rgba(0,0,0,0.12);
        }

        .section-title {
            font-size: 30px;
            font-weight: 800;
            margin-bottom: 24px;
            color: #222;
            text-align: center;
        }

        .member-list {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 22px;
        }

        .member-item {
            background-color: #fff;
            border: 2px solid #222;
            border-radius: 18px;
            padding: 22px 20px;
            transition: all 0.3s ease;
        }

        .member-item:hover {
            background-color: #fff5f5;
            transform: translateY(-3px);
        }

        .member-name {
            font-size: 22px;
            font-weight: 800;
            color: #222;
            margin-bottom: 10px;
        }

        .member-info {
            font-size: 17px;
            line-height: 1.8;
            color: #333;
        }

        .support-box {
            margin-top: 32px;
            background-color: #fff;
            border: 2px solid #222;
            border-radius: 18px;
            padding: 24px;
            text-align: center;
        }

        .support-box h3 {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 12px;
            color: #222;
        }

        .support-box p {
            font-size: 18px;
            line-height: 1.8;
            color: #333;
        }

        .support-box a {
            color: #d63031;
            text-decoration: none;
            font-weight: 700;
        }

        .support-box a:hover {
            text-decoration: underline;
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
            .member-list {
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
            <a href="aboutus.jsp">About System</a>
            <a href="login.jsp">Login</a>
        </div>

        <main class="main-content">
            <h1 class="page-title">Contact the Project Team</h1>
            <div class="title-line"></div>

            <p class="intro-text">
                Meet the development team behind the TA Recruitment System and the support contact for this project.
            </p>

            <section class="contact-card">
                <h2 class="section-title">Software Engineering Group 15</h2>

                <div class="member-list">
                    <div class="member-item">
                        <div class="member-name">Runtian Zhou</div>
                        <div class="member-info">
                            Chinese Name: 周润恬<br>
                            GitHub Username: buptzrt<br>
                            QMID: 231220013
                        </div>
                    </div>

                    <div class="member-item">
                        <div class="member-name">Sirong Qi</div>
                        <div class="member-info">
                            Chinese Name: 祁思榕<br>
                            GitHub Username: penguin-qsr<br>
                            QMID: 231221157
                        </div>
                    </div>

                    <div class="member-item">
                        <div class="member-name">Chenyu Zhang</div>
                        <div class="member-info">
                            Chinese Name: 章晨瑜<br>
                            GitHub Username: Charity-zcy<br>
                            QMID: 231222062
                        </div>
                    </div>

                    <div class="member-item">
                        <div class="member-name">Jiayi Wang</div>
                        <div class="member-info">
                            Chinese Name: 王佳仪<br>
                            GitHub Username: lucy-wjy<br>
                            QMID: 231220459
                        </div>
                    </div>

                    <div class="member-item">
                        <div class="member-name">Qiutong Chen</div>
                        <div class="member-info">
                            Chinese Name: 陈秋彤<br>
                            GitHub Username: ChenQiutong-123<br>
                            QMID: 231222545
                        </div>
                    </div>

                    <div class="member-item">
                        <div class="member-name">Zichun Ao</div>
                        <div class="member-info">
                            Chinese Name: 敖子淳<br>
                            GitHub Username: aaazcshuaige0905<br>
                            QMID: 231222844
                        </div>
                    </div>
                </div>

                <div class="support-box">
                    <h3>Support Contact</h3>
                    <p>
                        Yuxuan Wang (Support TA)<br>
                        Email:
                        <a href="mailto:yuxuanwwang@outlook.com">yuxuanwwang@outlook.com</a>
                    </p>
                </div>
            </section>
        </main>

        <div class="footer-nav">
            <a href="aboutus.jsp">About System</a>
            <div class="divider"></div>
            <a href="help.jsp">Help</a>
            <div class="divider"></div>
            <a href="contact.jsp">Contact</a>
        </div>
    </div>
</body>
</html>
