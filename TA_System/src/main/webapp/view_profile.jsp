<%@ page import="com.me.finaldesignproject.model.User" %>
<%@ page import="com.me.finaldesignproject.model.TaProfile" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    User user = (User) request.getAttribute("userProfile");
    TaProfile taProfile = (TaProfile) request.getAttribute("taProfile");
    boolean isTa = user != null && user.getRole() != null && "TA".equalsIgnoreCase(user.getRole().trim());
    boolean isStudent = user != null && user.getRole() != null && "Student".equalsIgnoreCase(user.getRole().trim());
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
            font-family: Georgia, "Times New Roman", serif;
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
    }

    .label {
        color: #ffd166;
        font-weight: 700;
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
            <h2><%= isTa ? "TA Profile Overview" : "Student Profile Overview" %></h2>

            <div class="section-title">Basic Information</div>
            <div class="grid">
                <div class="card"><span class="label">Name:</span> <%= user.getFullName() == null ? "Not set" : user.getFullName() %></div>
                <div class="card"><span class="label">Student Number:</span> <%= user.getEnrollmentNo() == null ? "Not set" : user.getEnrollmentNo() %></div>
                <div class="card"><span class="label">Email:</span> <%= user.getEmail() == null ? "Not set" : user.getEmail() %></div>
                <div class="card"><span class="label">Role:</span> <%= user.getRole() == null ? "Not set" : user.getRole() %></div>
                <div class="card"><span class="label">Branch / College:</span> <%= user.getBranch() == null ? "Not set" : user.getBranch() %></div>
            </div>

            <% if (isTa || isStudent) { %>
                <div class="section-title">Profile Details (same as Manage Profile)</div>
                <div class="grid">
                    <div class="card"><span class="label">Name:</span> <%= taProfile != null && taProfile.getFullName()!=null ? taProfile.getFullName() : (user.getFullName()==null?"Not set":user.getFullName()) %></div>
                    <div class="card"><span class="label">Chinese name:</span> <%= taProfile != null && taProfile.getChineseName()!=null ? taProfile.getChineseName() : "Not set" %></div>
                    <div class="card"><span class="label">Gender:</span> <%= taProfile != null && taProfile.getGender()!=null ? taProfile.getGender() : "Not set" %></div>
                    <div class="card"><span class="label">QM ID:</span> <%= taProfile != null && taProfile.getQmId()!=null ? taProfile.getQmId() : "Not set" %></div>
                    <div class="card"><span class="label">BUPT ID:</span> <%= taProfile != null && taProfile.getBuptId()!=null ? taProfile.getBuptId() : (user.getEnrollmentNo()==null?"Not set":user.getEnrollmentNo()) %></div>
                    <div class="card"><span class="label">BUPT Class:</span> <%= taProfile != null && taProfile.getBuptClass()!=null ? taProfile.getBuptClass() : "Not set" %></div>
                    <div class="card"><span class="label">Major / Programme:</span> <%= taProfile != null && taProfile.getMajorProgramme()!=null ? taProfile.getMajorProgramme() : "Not set" %></div>
                    <div class="card"><span class="label">Grade:</span> <%= taProfile != null && taProfile.getGrade()!=null ? taProfile.getGrade() : "Not set" %></div>
                    <div class="card"><span class="label">Email:</span> <%= taProfile != null && taProfile.getEmail()!=null ? taProfile.getEmail() : (user.getEmail()==null?"Not set":user.getEmail()) %></div>
                    <div class="card"><span class="label">Mobile Phone:</span> <%= taProfile != null && taProfile.getMobilePhone()!=null ? taProfile.getMobilePhone() : "Not set" %></div>
                    <div class="card"><span class="label">WeChat ID:</span> <%= taProfile != null && taProfile.getWechatId()!=null ? taProfile.getWechatId() : "Not set" %></div>
                    <div class="card"><span class="label">Prior Joint Programme:</span> <%= taProfile != null && taProfile.getPriorAnswer()!=null ? taProfile.getPriorAnswer() : "Not set" %></div>
                    <div class="card"><span class="label">Programme & Graduation Year:</span> <%= taProfile != null && taProfile.getPriorProgramme()!=null ? taProfile.getPriorProgramme() : "Not set" %></div>
                    <div class="card"><span class="label">Availability:</span> <%= taProfile != null && taProfile.getAvailability()!=null ? taProfile.getAvailability() : "Not set" %></div>
                    <div class="card"><span class="label">Availability Notes:</span> <%= taProfile != null && taProfile.getAvailabilityNotes()!=null ? taProfile.getAvailabilityNotes() : "Not set" %></div>
                    <div class="card"><span class="label">Campus Preference:</span> <%= taProfile != null && taProfile.getCampusPreference()!=null ? taProfile.getCampusPreference() : "Not set" %></div>
                    <div class="card"><span class="label">Skills:</span> <%= taProfile != null && taProfile.getSkills()!=null ? taProfile.getSkills() : "Not set" %></div>
                    <div class="card" id="cvRow" style="word-break: break-word; overflow-wrap:anywhere;"><span class="label">CV Path:</span> <%= taProfile != null && taProfile.getResumePath()!=null ? taProfile.getResumePath() : "Not set" %></div>
                </div>
                <div class="card" style="margin-top:12px; display:flex; align-items:center; gap:12px; flex-wrap:wrap;">
                    <span class="label" style="margin:0;">Upload PDF:</span>
                    <input id="resumeFile" type="file" accept=".pdf,.doc,.docx,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document" style="max-width:260px; background:#f4f7fb; color:#132238; border-radius:8px; padding:8px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
                    <button id="uploadBtn" type="button" class="cta" style="margin:0;">Upload PDF</button>
                    <small style="color:#d7e3f1;">PDF/Word, up to 10MB. Uploading updates CV Path.</small>
                </div>
                <div id="msg" class="card" style="display:none; color:#ffd166; font-weight:700; background:rgba(255,255,255,0.08); margin-top:10px;"></div>
                <a class="cta" href="ta_profile.html">Edit / Manage Profile</a>
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
            const resp = await fetch('api/ta/resume/upload', {
                method: 'POST',
                credentials: 'same-origin',
                body: fd
            });
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
        } catch (e) {
            show('Upload failed: ' + e.message, false);
        } finally {
            btn.disabled = false;
        }
    });
})();
</script>
</body>
</html>
