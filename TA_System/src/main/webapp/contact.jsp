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
            color: #f4f7fb;
            overflow-x: hidden;
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

        .header-logos {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 20;
            display: flex;
            flex-direction: column;
            gap: 18px;
            padding: 24px 28px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(12px);
        }

        .logo-item {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-item img {
            width: 60px;
            height: 60px;
            object-fit: contain;
            background: rgba(255, 255, 255, 0.85);
            padding: 8px;
            border-radius: 50%;
            box-shadow: 0 4px 12px rgba(255, 255, 255, 0.15);
        }

        .logo-text {
            font-size: 14px;
            color: #e8eef7;
            font-weight: 600;
            line-height: 1.4;
            letter-spacing: 0.2px;
        }

        .top-nav {
            width: 100%;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            padding: 28px 40px 0 40px;
            gap: 14px;
        }

        .top-nav a {
            text-decoration: none;
            color: #e8eef7;
            font-size: 16px;
            font-weight: 600;
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
            flex: 1;
            width: 90%;
            max-width: 1000px;
            margin: 120px auto 80px auto;
            animation: fadeInUp 0.8s ease-out;
        }

        .page-title {
            text-align: center;
            font-size: 44px;
            font-weight: 700;
            color: #f4f7fb;
            line-height: 1.2;
            margin-bottom: 12px;
            letter-spacing: 1px;
        }

        .title-line {
            width: 80px;
            height: 3px;
            background: linear-gradient(to right, #c0d9e8, rgba(192, 217, 232, 0.2));
            margin: 0 auto 36px auto;
            border-radius: 2px;
        }

        .intro-text {
            text-align: center;
            font-size: 18px;
            line-height: 1.7;
            color: #b0c4de;
            font-weight: 600;
            max-width: 900px;
            margin: 0 auto 42px auto;
        }

        .contact-card {
            background-color: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 24px;
            padding: 40px 36px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3), inset 0 1px 1px rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            transition: all 0.3s ease;
        }

        .contact-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.35), inset 0 1px 1px rgba(255, 255, 255, 0.1);
        }

        .section-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 32px;
            color: #f4f7fb;
            text-align: center;
        }

        .member-list {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .member-item {
            background-color: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 16px;
            padding: 22px 20px;
            transition: all 0.3s ease;
        }

        .member-item:hover {
            background-color: rgba(24, 179, 148, 0.1);
            border-color: rgba(24, 179, 148, 0.3);
            transform: translateY(-2px);
        }

        .member-name {
            font-size: 18px;
            font-weight: 700;
            color: #f4f7fb;
            margin-bottom: 10px;
        }

        .member-info {
            font-size: 15px;
            line-height: 1.8;
            color: #e8eef7;
        }

        .support-box {
            margin-top: 24px;
            background-color: rgba(24, 179, 148, 0.1);
            border: 1px solid rgba(24, 179, 148, 0.3);
            border-radius: 16px;
            padding: 22px;
            text-align: center;
        }

        .support-box h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 12px;
            color: #f4f7fb;
        }

        .support-box p {
            font-size: 16px;
            line-height: 1.8;
            color: #e8eef7;
        }

        .support-box a {
            color: #b0c4de;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        .support-box a:hover {
            color: #f4f7fb;
            text-decoration: underline;
        }

        .footer-nav {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 40px;
            font-size: 16px;
            font-weight: 600;
            padding: 24px 0 30px 0;
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
            background-color: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
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

        @media (max-width: 900px) {
            .member-list {
                grid-template-columns: 1fr;
            }

            .page-title {
                font-size: 36px;
            }

            .intro-text {
                font-size: 16px;
            }

            .top-nav {
                justify-content: center;
                flex-wrap: wrap;
                padding-top: 100px;
            }

            .header-logos {
                position: static;
                padding: 20px 20px 0 20px;
                margin-bottom: 20px;
            }

            .main-content {
                margin-top: 40px;
            }

            .footer-nav {
                gap: 20px;
                font-size: 14px;
                flex-wrap: wrap;
            }

            .contact-card {
                padding: 24px 20px;
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
