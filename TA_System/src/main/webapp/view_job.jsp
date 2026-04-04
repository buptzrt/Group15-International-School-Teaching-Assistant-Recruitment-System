<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("role") == null ||
        !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String courseName = request.getParameter("course_name");
    String jobTitle = request.getParameter("job_title");
    String applicationDeadline = request.getParameter("application_deadline");
    String numberOfPositions = request.getParameter("number_of_positions");
    String cgpaRequired = request.getParameter("cgpa_required");
    String location = request.getParameter("location");
    String contactEmail = request.getParameter("contact_email");
    String contactPhone = request.getParameter("contact_phone");
    String status = request.getParameter("status");
    String postedDate = request.getParameter("posted_date");
    String jobDescription = request.getParameter("job_description");

    if (courseName == null || courseName.isEmpty()) {
        courseName = "Pending course name";
    }
    if (jobTitle == null || jobTitle.isEmpty()) {
        jobTitle = "Pending TA job title";
    }
    if (applicationDeadline == null || applicationDeadline.isEmpty()) {
        applicationDeadline = "Please publish the job before setting the deadline";
    }
    if (numberOfPositions == null || numberOfPositions.isEmpty()) {
        numberOfPositions = "0";
    }
    if (cgpaRequired == null || cgpaRequired.isEmpty()) {
        cgpaRequired = "Not set";
    }
    if (location == null || location.isEmpty()) {
        location = "Location or mode pending";
    }
    if (contactEmail == null || contactEmail.isEmpty()) {
        contactEmail = "contact@example.com";
    }
    if (contactPhone == null || contactPhone.isEmpty()) {
        contactPhone = "Not set";
    }
    if (status == null || status.isEmpty()) {
        status = "Open";
    }
    if (postedDate == null || postedDate.isEmpty()) {
        postedDate = "Not published yet";
    }
    if (jobDescription == null || jobDescription.isEmpty()) {
        jobDescription = "Please enter the TA responsibilities, requirements, course guidance information, and other details on the posting page.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View TA Job Posting</title>
    <style>
        body {
            margin: 0;
            padding: 36px 18px;
            font-family: Georgia, "Times New Roman", serif;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            color: #f4f7fb;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(18, 35, 61, 0.78);
            z-index: -1;
        }

        .page-container {
            max-width: 980px;
            margin: 0 auto;
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 24px;
        }

        .header h2 {
            margin: 0;
            font-size: 32px;
            color: #ffd166;
        }

        .card {
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(10px);
            border-radius: 18px;
            padding: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
            border: 1px solid rgba(255, 255, 255, 0.14);
        }

        .section-title {
            color: #9bd3ff;
            margin-bottom: 18px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-size: 14px;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(240px, 1fr));
            gap: 18px;
        }

        .detail-item {
            background: rgba(255, 255, 255, 0.06);
            border-radius: 14px;
            padding: 18px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .detail-item strong {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            color: #ffd166;
        }

        .detail-item span {
            color: #e9effe;
            line-height: 1.7;
        }

        .description {
            margin-top: 26px;
            background: rgba(255, 255, 255, 0.06);
            border-radius: 16px;
            padding: 24px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #edf2ff;
            line-height: 1.9;
        }

        .footer {
            margin-top: 28px;
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }

        .pill {
            display: inline-flex;
            align-items: center;
            padding: 12px 18px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            color: #edf2ff;
            font-size: 13px;
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        select,
        .dropdown,
        select.form-control {
            min-height: 48px;
            font-size: 16px;
            padding: 12px 14px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.08);
            color: #f4f7fb;
            width: 100%;
            box-sizing: border-box;
        }

        select:focus {
            outline: none;
            box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.14);
        }

        @media (max-width: 760px) {
            .detail-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="page-container">
        <div class="header">
            <h2>TA Job Posting</h2>
            <div class="pill">Status: <strong><%= status %></strong></div>
        </div>

        <div class="card">
            <div class="section-title">Posting Summary</div>
            <div class="detail-grid">
                <div class="detail-item">
                    <strong>Course Name</strong>
                    <span><%= courseName %></span>
                </div>
                <div class="detail-item">
                    <strong>Job Title</strong>
                    <span><%= jobTitle %></span>
                </div>
                <div class="detail-item">
                    <strong>Application Deadline</strong>
                    <span><%= applicationDeadline %></span>
                </div>
                <div class="detail-item">
                    <strong>Openings</strong>
                    <span><%= numberOfPositions %></span>
                </div>
                <div class="detail-item">
                    <strong>CGPA Requirement</strong>
                    <span><%= cgpaRequired %></span>
                </div>
                <div class="detail-item">
                    <strong>Location / Mode</strong>
                    <span><%= location %></span>
                </div>
            </div>

            <div class="description">
                <div class="section-title">Job Description</div>
                <p><%= jobDescription %></p>
            </div>

            <div class="footer">
                <div class="pill">Posted On: <strong><%= postedDate %></strong></div>
                <div class="pill">Contact Email: <strong><%= contactEmail %></strong></div>
                <div class="pill">Contact Phone: <strong><%= contactPhone %></strong></div>
            </div>
        </div>
    </div>
</body>
</html>
