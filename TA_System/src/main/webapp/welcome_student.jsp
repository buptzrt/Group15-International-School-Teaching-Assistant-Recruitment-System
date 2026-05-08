<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.me.finaldesignproject.model.User" %>
<%
    String studentName = null;
    Object sessionUser = session.getAttribute("user");
    if (sessionUser instanceof User) {
        studentName = ((User) sessionUser).getFullName();
    }
    String studentEmail = (String) session.getAttribute("email");
    String studentId = (String) session.getAttribute("userId");
    if (studentName == null || studentName.trim().isEmpty()) {
        studentName = studentEmail;
    }
    if (studentName == null || studentName.trim().isEmpty()) {
        studentName = "-";
    }
    if (studentEmail == null || studentEmail.trim().isEmpty()) {
        studentEmail = "-";
    }
    if (studentId == null || studentId.trim().isEmpty()) {
        studentId = "-";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Home</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        body {
            margin: 0;
            padding: 18px 28px;
            background: transparent;
            color: #eef4fb;
        }

        .student-home {
            width: 100%;
            padding: 30px 34px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            box-shadow: 0 24px 48px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(14px);
        }
    </style>
</head>
<body>
    <div class="student-home home-panel">
        <span class="home-kicker">Student Workspace</span>
        <div class="home-heading-row">
            <h3>Welcome, <%= studentName %></h3>
        </div>
        <div class="home-meta">
            <span>Role: Student</span>
            <span>Email: <%= studentEmail %></span>
            <span>ID: <%= studentId %></span>
        </div>
        <p class="home-lead">
            This home page helps you prepare your profile, find suitable TA opportunities,
            and track every application from one place.
        </p>

        <div class="home-grid">
            <div class="home-card">
                <h4>Complete Your Profile</h4>
                <p>Keep your personal information, academic background, and resume ready before applying.</p>
            </div>
            <div class="home-card">
                <h4>Find Open Jobs</h4>
                <p>Use View Job List to compare active vacancies, requirements, deadlines, and available positions.</p>
            </div>
            <div class="home-card">
                <h4>Track Applications</h4>
                <p>Open My Applications to review submission status and follow the progress of your TA applications.</p>
            </div>
        </div>

    </div>
</body>
</html>
