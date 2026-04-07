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
        margin-top: 14px;
        padding: 11px 18px;
        border-radius: 999px;
        background: #18b394;
        color: #fff;
        text-decoration: none;
        font-weight: 700;
    }
    </style>
</head>
<body>
    <div class="profile-container">
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
                <div class="card"><span class="label">Branch / College:</span> <%= user.getBranch() == null ? "Not set" : user.getBranch() %></div>
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
                    <div class="card"><span class="label">Programme & Graduation Year:</span> <%= studentProfile != null && studentProfile.getPriorProgramme()!=null ? studentProfile.getPriorProgramme() : "Not set" %></div>
                    <div class="card"><span class="label">Availability:</span> <%= studentProfile != null && studentProfile.getAvailability()!=null ? studentProfile.getAvailability() : "Not set" %></div>
                    <div class="card"><span class="label">Availability Notes:</span> <%= studentProfile != null && studentProfile.getAvailabilityNotes()!=null ? studentProfile.getAvailabilityNotes() : "Not set" %></div>
                    <div class="card"><span class="label">Campus Preference:</span> <%= studentProfile != null && studentProfile.getCampusPreference()!=null ? studentProfile.getCampusPreference() : "Not set" %></div>
                    <div class="card"><span class="label">Skills:</span> <%= studentProfile != null && studentProfile.getSkills()!=null ? studentProfile.getSkills() : "Not set" %></div>
                    <div class="card" id="cvRow" style="word-break: break-word; overflow-wrap:anywhere;"><span class="label">CV Path:</span> <%= studentProfile != null && studentProfile.getResumePath()!=null ? studentProfile.getResumePath() : "Not set" %></div>
                </div>
                <div class="card" style="margin-top:12px; display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                    <span class="label" style="margin:0;">Upload PDF:</span>
                    <input id="resumeFile" type="file" accept=".pdf,.doc,.docx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document" style="max-width:260px; background:#f4f7fb; color:#132238; border-radius:8px; padding:8px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
                    <button id="uploadBtn" type="button" class="cta" style="margin:0;">Upload PDF</button>
                    <small style="color:#d7e3f1;">PDF/Word, up to 10MB. Uploading updates CV Path.</small>
                </div>
                <div id="msg" class="card" style="display:none; color:#ffd166; font-weight:700; background:rgba(255,255,255,0.08); margin-top:10px;"></div>
                <a class="cta" href="student_profile.html">Edit / Manage Profile</a>
            <% } %>
        <% } %>
    </div>
<script>
(function() {
    const btn = document.getElementById('uploadBtn');
    if (!btn) return;
    const input = document.getElementById('resumeFile');
    const msg = document.getElementById('msg');
    const cvRow = document.getElementById('cvRow');

    function show(text, ok) {
        if (!msg) return;
        msg.style.display = 'block';
        msg.style.color = ok ? '#9fedc1' : '#ffb3b3';
        msg.textContent = text;
    }

    btn.addEventListener('click', async () => {
        if (!input.files || input.files.length === 0) {
            show('Please choose a PDF file first.', false);
            return;
        }
        const file = input.files[0];
        if (file.type !== 'application/pdf') {
            show('Only PDF files are allowed.', false);
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            show('File too large. Keep under 10MB.', false);
            return;
        }
        btn.disabled = true;
        show('Uploading...', true);
        try {
            const fd = new FormData();
            fd.append('file', file);
            const resp = await fetch('api/student/resume/upload', {
                method: 'POST',
                credentials: 'same-origin',
                body: fd
            });
            
            // 检查会话过期
            if (resp.status === 401 || resp.status === 403) {
                show('Your session has expired. Please log in again.', false);
                setTimeout(() => {
                    window.location.href = 'login.jsp';
                }, 1500);
                return;
            }
            
            // 检查响应是否为JSON
            const contentType = resp.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                show('Server error. Please try again later.', false);
                btn.disabled = false;
                return;
            }
            
            const data = await resp.json();
            if (!resp.ok || data.success === false) {
                show(data.message || 'Upload failed.', false);
                btn.disabled = false;
                return;
            }
            const path = data.path || '';
            if (cvRow) {
                cvRow.innerHTML = '<span class="label">CV Path:</span> ' + path;
            }
            show(data.message || 'Upload succeeded.', true);
            
            // 【重要修改】上传成功后不自动刷新整个页面，因为这会导致 session 丢失
            // 原因：整体刷新会重新请求 StudentProfileServlet，可能导致 session 过期
            // 改进：延迟 2 秒后，用 JavaScript 刷新 CV Path 行，或让用户手动点击刷新按钮
            console.log("Upload succeeded, you can click 'Reload Profile' button to see the updated CV path");
            // 选项1：自动更新 CV Path 显示（无需刷新页面）
            setTimeout(() => {
                if (cvRow && data.path) {
                    cvRow.innerHTML = '<span class="label">CV Path:</span> ' + data.path;
                    console.log("CV path updated: " + data.path);
                }
            }, 1000);
        } catch (e) {
            console.error("Upload error:", e);
            show('Upload failed: ' + e.message, false);
        } finally {
            btn.disabled = false;
        }
    });
})();
</script>
</body>
</html>
