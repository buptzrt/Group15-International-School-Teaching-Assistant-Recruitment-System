<%@ page import="com.me.finaldesignproject.model.User" %>
<%@ page import="com.me.finaldesignproject.model.StudentProfile" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User user = (User) request.getAttribute("userProfile");
    StudentProfile studentProfile = (StudentProfile) request.getAttribute("studentProfile");
    Boolean readOnly = (Boolean) request.getAttribute("isReadOnly");
    boolean isReadOnly = readOnly != null && readOnly;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Profile</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        body { margin: 0; padding: 36px 18px; font-family: Georgia, "Times New Roman", serif; color: #f4f7fb; min-height: 100vh; position: relative; }
        .profile-container { max-width: 980px; margin: 0 auto; }
        .detail-back-row { display: flex; align-items: center; min-height: 42px; margin-bottom: 18px; }
        .header { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 24px; }
        .header h2 { margin: 0; font-size: 32px; color: #ffd166; }
        .card { background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(10px); border-radius: 18px; padding: 30px; border: 1px solid rgba(255, 255, 255, 0.14); }
        .section-title { color: #9bd3ff; margin-bottom: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; font-size: 14px; }
        .detail-grid { display: grid; grid-template-columns: repeat(2, minmax(240px, 1fr)); gap: 18px; }
        .detail-item { background: rgba(255, 255, 255, 0.06); border-radius: 14px; padding: 18px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .detail-item strong { display: block; margin-bottom: 8px; font-size: 14px; color: #ffd166; }
        .detail-item span { color: #e9effe; line-height: 1.7; white-space: pre-wrap; overflow-wrap: anywhere; }
        .description { margin-top: 26px; background: rgba(255, 255, 255, 0.06); border-radius: 16px; padding: 24px; border: 1px solid rgba(255, 255, 255, 0.1); color: #edf2ff; line-height: 1.9; }
        .description p { margin: 8px 0; white-space: pre-wrap; overflow-wrap: anywhere; }
        .footer { margin-top: 28px; display: flex; flex-wrap: wrap; gap: 16px; }
        .pill { display: inline-flex; align-items: center; padding: 12px 18px; border-radius: 999px; background: rgba(255, 255, 255, 0.08); color: #edf2ff; font-size: 13px; border: 1px solid rgba(255, 255, 255, 0.12); }
        .empty { color: #d7e3f1; font-style: italic; }
        .cta { display: inline-flex; align-items: center; margin-top: 24px; padding: 11px 18px; border-radius: 999px; background: #18b394; color: #fff; text-decoration: none; font-weight: 700; }
        @media (max-width: 760px) { .detail-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="app-auth-bg table-page role-table-page profile-page view-profile-page detail-display-page">
<div class="profile-container detail-surface">
    <div class="detail-back-row">
        <button type="button" class="detail-exit-arrow" onclick="exitDetailPage()" title="Back"></button>
    </div>
    <% if (user == null) { %>
    <div class="header"><h2>Student Profile</h2></div>
    <div class="card"><div class="detail-item empty">No profile data is available.</div></div>
    <% } else { %>
    <div class="header">
        <h2>Student Profile Overview</h2>
        <div class="pill">Role: <strong style="margin-left: 6px;"><%= user.getRole() == null ? "Student" : user.getRole() %></strong></div>
    </div>

    <div class="card">
        <div class="section-title">Basic Information</div>
        <div class="detail-grid">
            <div class="detail-item"><strong>English Name</strong><span><%= studentProfile != null && studentProfile.getFullName()!=null && !studentProfile.getFullName().trim().isEmpty() ? studentProfile.getFullName() : (user.getFullName() == null ? "Not set" : user.getFullName()) %></span></div>
            <div class="detail-item"><strong>Student Number</strong><span><%= user.getEnrollmentNo() == null ? "Not set" : user.getEnrollmentNo() %></span></div>
            <div class="detail-item"><strong>Email</strong><span><%= user.getEmail() == null ? "Not set" : user.getEmail() %></span></div>
            <div class="detail-item"><strong>Chinese Name</strong><span><%= studentProfile != null && studentProfile.getChineseName()!=null ? studentProfile.getChineseName() : "Not set" %></span></div>
            <div class="detail-item"><strong>Gender</strong><span><%= studentProfile != null && studentProfile.getGender()!=null ? studentProfile.getGender() : "Not set" %></span></div>
            <div class="detail-item"><strong>QM ID</strong><span><%= studentProfile != null && studentProfile.getQmId()!=null ? studentProfile.getQmId() : "Not set" %></span></div>
            <div class="detail-item"><strong>BUPT ID</strong><span><%= studentProfile != null && studentProfile.getBuptId()!=null ? studentProfile.getBuptId() : (user.getEnrollmentNo()==null?"Not set":user.getEnrollmentNo()) %></span></div>
            <div class="detail-item"><strong>BUPT Class</strong><span><%= studentProfile != null && studentProfile.getBuptClass()!=null ? studentProfile.getBuptClass() : "Not set" %></span></div>
            <div class="detail-item"><strong>Major / Programme</strong><span><%= studentProfile != null && studentProfile.getMajorProgramme()!=null ? studentProfile.getMajorProgramme() : "Not set" %></span></div>
            <div class="detail-item"><strong>Grade</strong><span><%= studentProfile != null && studentProfile.getGrade()!=null ? studentProfile.getGrade() : "Not set" %></span></div>
            <div class="detail-item"><strong>Mobile Phone</strong><span><%= studentProfile != null && studentProfile.getMobilePhone()!=null ? studentProfile.getMobilePhone() : "Not set" %></span></div>
            <div class="detail-item"><strong>WeChat ID</strong><span><%= studentProfile != null && studentProfile.getWechatId()!=null ? studentProfile.getWechatId() : "Not set" %></span></div>
        </div>

        <div class="description">
            <div class="section-title">Experience & Evaluation</div>
            <p><strong style="color: #ffd166;">Skills:</strong> <%= studentProfile != null && studentProfile.getSkills()!=null ? studentProfile.getSkills() : "Not set" %></p>
            <p><strong style="color: #ffd166;">Availability:</strong> <%= studentProfile != null && studentProfile.getAvailability()!=null ? studentProfile.getAvailability() : "Not set" %></p>
            <p><strong style="color: #ffd166;">Campus Preference:</strong> <%= studentProfile != null && studentProfile.getCampusPreference()!=null ? studentProfile.getCampusPreference() : "Not set" %></p>
            <p><strong style="color: #ffd166;">Prior Joint Programme:</strong> <%= studentProfile != null && studentProfile.getPriorAnswer()!=null ? studentProfile.getPriorAnswer() : "Not set" %></p>
        </div>

        <div class="footer">
            <div class="pill" style="word-break: break-word; overflow-wrap:anywhere;">
                CV:
            <%
                String rPath = (studentProfile != null) ? studentProfile.getResumePath() : null;
                if (rPath != null && !rPath.trim().isEmpty()) {
            %>
            <a href="${pageContext.request.contextPath}/<%= rPath %>" target="_blank" style="color: #18b394; text-decoration: underline; font-weight: bold; font-size: 14px; margin-left: 6px;">
                Click to View Resume (PDF)
            </a>
            <% } else { %>
            <span class="empty" style="margin-left: 6px;">Not set</span>
            <% } %>
            </div>
        </div>

        <% if (!isReadOnly) { %>
        <a class="cta" href="student_profile.html">Edit / Manage Profile</a>
        <% } %>
    </div>
    <% } %>
</div>
<script>
    function exitDetailPage() {
        if (window.parent && window.parent !== window && typeof window.parent.closeModal === "function") {
            window.parent.closeModal();
            return;
        }
        if (window.history.length > 1) {
            window.history.back();
        }
    }
</script>
</body>
</html>
