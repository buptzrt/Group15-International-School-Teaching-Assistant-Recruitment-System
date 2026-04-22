<%@ page import="com.me.finaldesignproject.model.User" %>
<%@ page import="com.me.finaldesignproject.model.StudentProfile" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User user = (User) request.getAttribute("userProfile");
    StudentProfile studentProfile = (StudentProfile) request.getAttribute("studentProfile");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile</title>
    <style>
        body {
            margin: 0;
            padding: 36px 18px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
            background: linear-gradient(135deg, #17293d 0%, #25496d 100%);
            color: #f4f7fb;
        }

        .profile-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 28px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 18px;
            box-shadow: 0 18px 40px rgba(0, 0, 0, 0.18);
        }

        h2 {
            margin: 0 0 20px;
            color: #ffd166;
            font-size: 30px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 12px;
        }

        .card {
            padding: 12px 14px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.06);
            line-height: 1.5;
            font-size: 16px;
            font-weight: 500;
            letter-spacing: 0.1px;
            font-variant-numeric: tabular-nums;
        }

        /* 🌟 特殊处理：让 Skills 占据更多空间并在同一行与 CV 搭配 */
        .full-row-grid {
            display: grid;
            grid-template-columns: 2fr 1fr; /* Skills 占 2 份，CV 占 1 份 */
            gap: 12px;
            margin-top: 12px;
        }

        /* 移动端自适应 */
        @media (max-width: 600px) {
            .full-row-grid {
                grid-template-columns: 1fr;
            }
        }

        .label {
            color: #ffd166;
            font-weight: 700;
            letter-spacing: 0.2px;
        }

        .empty {
            color: #d7e3f1;
            font-style: italic;
        }

        .section-title {
            margin: 18px 0 8px;
            color: #9bd3ff;
            font-size: 20px;
        }

        .cta {
            display: inline-block;
            margin-top: 24px;
            padding: 11px 18px;
            border-radius: 999px;
            background: #18b394;
            color: #fff;
            text-decoration: none;
            font-weight: 700;
        }

        .back-btn {
            display: inline-block;
            margin-bottom: 14px;
            padding: 9px 16px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: #f4f7fb;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.25s ease;
        }

        .back-btn:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-1px);
        }
    </style>
</head>
<body>
<div class="profile-container">
    <%
        String currentRole = (String) session.getAttribute("role");
        if ("MO".equalsIgnoreCase(currentRole)) {
    %>
    <a href="#" class="back-btn" onclick="history.back(); return false;">&larr; Back to Applications</a>
    <% } %>

    <% if (user == null) { %>
    <h2>My Profile</h2>
    <div class="row empty">No profile data is available in the current session.</div>
    <% } else { %>
    <h2>Student Profile Overview</h2>

    <div class="section-title">Basic Information</div>
    <div class="grid">
        <div class="card"><span class="label">Name:</span> <%= user.getFullName() == null ? "Not set" : user.getFullName() %></div>
        <div class="card"><span class="label">Student Number:</span> <%= user.getEnrollmentNo() == null ? "Not set" : user.getEnrollmentNo() %></div>
        <div class="card"><span class="label">Email:</span> <%= user.getEmail() == null ? "Not set" : user.getEmail() %></div>
        <div class="card"><span class="label">Role:</span> <%= user.getRole() == null ? "Not set" : user.getRole() %></div>
    </div>

    <% if (user != null && studentProfile != null) { %>
    <div class="section-title">Profile Details (same as Manage Profile)</div>
    <div class="grid">
        <div class="card"><span class="label">Name:</span> <%= studentProfile != null && studentProfile.getFullName()!=null ? studentProfile.getFullName() : (user.getFullName()==null?"Not set":user.getFullName()) %></div>
        <div class="card"><span class="label">Chinese name:</span> <%= studentProfile != null && studentProfile.getChineseName()!=null ? studentProfile.getChineseName() : "Not set" %></div>
        <div class="card"><span class="label">Gender:</span> <%= studentProfile != null && studentProfile.getGender()!=null ? studentProfile.getGender() : "Not set" %></div>
        <div class="card"><span class="label">QM ID:</span> <%= studentProfile != null && studentProfile.getQmId()!=null ? studentProfile.getQmId() : "Not set" %></div>
        <div class="card"><span class="label">BUPT ID:</span> <%= studentProfile != null && studentProfile.getBuptId()!=null ? studentProfile.getBuptId() : (user.getEnrollmentNo()==null?"Not set":user.getEnrollmentNo()) %></div>
        <div class="card"><span class="label">BUPT Class:</span> <%= studentProfile != null && studentProfile.getBuptClass()!=null ? studentProfile.getBuptClass() : "Not set" %></div>
        <div class="card"><span class="label">Major / Programme:</span> <%= studentProfile != null && studentProfile.getMajorProgramme()!=null ? studentProfile.getMajorProgramme() : "Not set" %></div>
        <div class="card"><span class="label">Grade:</span> <%= studentProfile != null && studentProfile.getGrade()!=null ? studentProfile.getGrade() : "Not set" %></div>
        <div class="card"><span class="label">Email:</span> <%= studentProfile != null && studentProfile.getEmail()!=null ? studentProfile.getEmail() : (user.getEmail()==null?"Not set":user.getEmail()) %></div>
        <div class="card"><span class="label">Mobile Phone:</span> <%= studentProfile != null && studentProfile.getMobilePhone()!=null ? studentProfile.getMobilePhone() : "Not set" %></div>
        <div class="card"><span class="label">WeChat ID:</span> <%= studentProfile != null && studentProfile.getWechatId()!=null ? studentProfile.getWechatId() : "Not set" %></div>
        <div class="card"><span class="label">Prior Joint Programme:</span> <%= studentProfile != null && studentProfile.getPriorAnswer()!=null ? studentProfile.getPriorAnswer() : "Not set" %></div>
        <div class="card"><span class="label">Availability:</span> <%= studentProfile != null && studentProfile.getAvailability()!=null ? studentProfile.getAvailability() : "Not set" %></div>
        <div class="card"><span class="label">Campus Preference:</span> <%= studentProfile != null && studentProfile.getCampusPreference()!=null ? studentProfile.getCampusPreference() : "Not set" %></div>
    </div>

    <div class="full-row-grid">
        <div class="card"><span class="label">Skills:</span> <%= studentProfile != null && studentProfile.getSkills()!=null ? studentProfile.getSkills() : "Not set" %></div>
        <div class="card" id="cvRow" style="word-break: break-word; overflow-wrap:anywhere;">
            <span class="label">CV Path:</span><br>
            <%
                String rPath = (studentProfile != null) ? studentProfile.getResumePath() : null;
                if (rPath != null && !rPath.trim().isEmpty()) {
            %>
            <a href="${pageContext.request.contextPath}/<%= rPath %>"
               target="_blank"
               style="color: #18b394; text-decoration: underline; font-weight: bold; font-size: 14px;">
                Click to View Resume (PDF)
            </a>
            <% } else { %>
            <span class="empty">Not set</span>
            <% } %>
        </div>
    </div>

    <div id="msg" class="card" style="display:none; color:#ffd166; font-weight:700; background:rgba(255,255,255,0.08); margin-top:10px;"></div>
    <% if (!"MO".equalsIgnoreCase(currentRole)) { %>
    <a class="cta" href="student_profile.html">Edit / Manage Profile</a>
    <% } %>
    <% } %>
    <% } %>
</div>
</body>
</html>