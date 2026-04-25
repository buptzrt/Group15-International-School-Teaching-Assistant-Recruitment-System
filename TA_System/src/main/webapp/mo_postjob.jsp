<%--
  Created by IntelliJ IDEA.
  User: 华为
  Date: 2026/4/5
  Time: 00:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%
  if (session == null || session.getAttribute("role") == null || !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
  }
  List<Job> jobList = (List<Job>) request.getAttribute("jobList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage TA Vacancies</title>
  <style>
    /* 🌟 滚动条整体美化 🌟 */
    ::-webkit-scrollbar {
      width: 8px; /* 纵向滚动条的宽度 */
      height: 8px; /* 横向滚动条的高度 */
    }
    /* 滚动条轨道（背景） */
    ::-webkit-scrollbar-track {
      background: transparent; /* 让轨道彻底透明，完美融入星空背景 */
    }
    /* 滚动条滑块 */
    ::-webkit-scrollbar-thumb {
      background: rgba(255, 255, 255, 0.25); /* 半透明白色，带有磨砂感 */
      border-radius: 10px; /* 圆角设计 */
    }
    /* 鼠标悬停在滑块上的效果 */
    ::-webkit-scrollbar-thumb:hover {
      background: rgba(255, 255, 255, 0.45); /* 悬停时稍微变亮 */
    }
    body { margin: 0; padding: 36px 18px; font-family: Georgia, "Times New Roman", serif; background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg"); background-size: cover; background-position: center; background-attachment: fixed; color: #f4f7fb; min-height: 100vh; position: relative; }
    body::before { content: ''; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(18, 35, 61, 0.78); z-index: -1; }
    .page-container { max-width: 1000px; margin: 0 auto; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .header h2 { margin: 0; font-size: 32px; color: #ffd166; }
    /*.btn { background-color: #1e90ff; color: white; border: none; padding: 12px 24px; border-radius: 8px; font-size: 16px; cursor: pointer; transition: 0.3s; }*/
    .btn {
      background-color: #1e90ff;
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      font-size: 16px;
      cursor: pointer;
      transition: 0.3s;
      white-space: nowrap; /* 🌟 核心新增：防止按钮里的文字被挤成两行 */
    }
    .btn:hover { background-color: #187bcd; }
    .btn-danger { background-color: #ff4d4d; }
    .btn-warning { background-color: #f39c12; }
    .job-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
    .card { background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(10px); border-radius: 18px; padding: 25px; border: 1px solid rgba(255, 255, 255, 0.14); position: relative; }
    .card h3 { color: #9bd3ff; margin-top: 0; padding-right: 80px; }
    .status-badge { position: absolute; top: 20px; right: 20px; padding: 5px 10px; border-radius: 12px; font-size: 12px; }
    .status-open { background: rgba(46, 204, 113, 0.3); color: #2ecc71; border: 1px solid #2ecc71; }
    .status-closed { background: rgba(231, 76, 60, 0.3); color: #e74c3c; border: 1px solid #e74c3c; }
    .modal { display: none; position: fixed; z-index: 100; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); overflow: auto; backdrop-filter: blur(5px); }
    .modal-content { background: rgba(25, 40, 65, 0.95); margin: 5% auto; padding: 30px; border-radius: 15px; width: 80%; max-width: 700px; border: 1px solid rgba(255, 255, 255, 0.2); }
    .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; color: #ffd166; margin-bottom: 5px; }
    .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.2); background: rgba(255,255,255,0.1); color: white; box-sizing: border-box; }
    select option { background-color: #1a2a40; color: #ffffff; }
  </style>
</head>
<body>
<div class="page-container">
  <div class="header">
    <h2>My Posted Vacancies</h2>
    <button class="btn" onclick="openCreateModal()">+ Post New Vacancy</button>
  </div>
  <div class="job-grid">
    <% if (jobList != null && !jobList.isEmpty()) { for (Job job : jobList) { %>
    <div class="card">
      <span class="status-badge <%= job.getStatus().equals("Open") ? "status-open" : "status-closed" %>"><%= job.getStatus() %></span>
      <h3><%= job.getCourseName() %> (<%= job.getModuleCode() %>)</h3>
      <p><strong>Title:</strong> <%= job.getJobTitle() %></p>
      <p><strong>Type:</strong> <%= job.getActivityType() %></p>
      <p><strong>Deadline:</strong> <%= job.getApplicationDeadline() %></p>
      <p><strong>Positions:</strong> <%= job.getNumberOfPositions() %></p>

<%--      <div style="margin-top: 15px; display: flex; gap: 10px;">--%>
      <div style="margin-top: 15px; display: flex; gap: 10px; flex-wrap: wrap; align-items: center;">
        <a href="view_job.jsp?jobId=<%= job.getJobId() %>&from=MOJobServlet" class="btn" style="padding: 8px 12px; background-color: #17a2b8; text-decoration: none; text-align: center;">View</a>

        <button type="button" class="btn" style="padding: 8px 12px; background-color: #3498db;" onclick="openEditModal('<%= job.getJobId() %>')">Edit</button>

        <% if ("Open".equals(job.getStatus())) { %>
        <form action="MOJobServlet" method="POST" style="margin:0;">
          <input type="hidden" name="action" value="close">
          <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
          <button type="submit" class="btn btn-warning" style="padding: 8px 12px;">Close</button>
        </form>
        <% } else { %>
        <form action="MOJobServlet" method="POST" style="margin:0;">
          <input type="hidden" name="action" value="reopen">
          <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
          <button type="submit" class="btn" style="padding: 8px 12px; background-color: #2ecc71;">Re-open</button>
        </form>
        <% } %>
        <form action="MOJobServlet" method="POST" style="margin:0;" onsubmit="return confirm('Are you sure you want to delete this vacancy?');">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
          <button type="submit" class="btn btn-danger" style="padding: 8px 12px;">Delete</button>
        </form>
      </div>
    </div>
    <% } } else { %>
    <p style="color: #ccc;">You have not posted any vacancies yet.</p>
    <% } %>
  </div>
</div>

<div id="jobModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <h3 id="modalTitle" style="color: #ffd166; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px;">Create TA Vacancy</h3>

    <form id="jobForm" action="MOJobServlet" method="POST">
      <input type="hidden" name="action" id="modalAction" value="create">
      <input type="hidden" name="jobId" id="modalJobId" value="">

      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Module Code *</label><input type="text" id="form_moduleCode" name="moduleCode" required placeholder="e.g. CS101"></div>
        <div class="form-group" style="flex: 2;"><label>Course Name *</label><input type="text" id="form_courseName" name="courseName" required placeholder="e.g. Intro to Programming"></div>
      </div>
      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Job Title *</label><input type="text" id="form_jobTitle" name="jobTitle" required placeholder="e.g. Lab Assistant"></div>
        <div class="form-group" style="flex: 1;"><label>Activity Type</label>
          <select id="form_activityType" name="activityType">
            <option value="Teaching Assistant">Teaching Assistant</option>
            <option value="Invigilation">Invigilation (Exam)</option>
            <option value="Grading">Grading</option>
          </select>
        </div>
      </div>
      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Positions Needed *</label><input type="number" id="form_numberOfPositions" name="numberOfPositions" required min="1" value="1"></div>
        <div class="form-group" style="flex: 1;"><label>Application Deadline *</label><input type="date" id="form_applicationDeadline" name="applicationDeadline" required lang="en"></div>
        <div class="form-group" style="flex: 1;"><label>Working Hours</label><input type="text" id="form_workingHours" name="workingHours" placeholder="e.g. 10 hrs/week"></div>
      </div>
      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Semester</label><input type="text" id="form_semester" name="semester" placeholder="e.g. Spring 2026"></div>
        <div class="form-group" style="flex: 1;"><label>Location / Mode</label>
          <select id="form_location" name="location">
            <option value="Offline">Offline (On-campus)</option><option value="Online">Online (Remote)</option><option value="Hybrid">Hybrid</option>
          </select>
        </div>
      </div>
      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Min CGPA Required</label><input type="number" step="0.01" min="0" max="10" id="form_cgpaRequired" name="cgpaRequired" placeholder="e.g. 3.0"></div>
        <div class="form-group" style="flex: 1;"><label>Preferred Major</label><input type="text" id="form_preferredMajor" name="preferredMajor" placeholder="e.g. Computer Science"></div>
      </div>
      <div style="display: flex; gap: 15px;">
        <div class="form-group" style="flex: 1;"><label>Contact Email</label><input type="email" id="form_contactEmail" name="contactEmail" placeholder="email@university.edu"></div>
        <div class="form-group" style="flex: 1;"><label>Contact Phone</label><input type="text" id="form_contactPhone" name="contactPhone" placeholder="Optional"></div>
      </div>
      <div class="form-group"><label>Required Skills</label><input type="text" id="form_requiredSkills" name="requiredSkills" placeholder="e.g. Java, Python"></div>
      <div class="form-group"><label>Job Responsibilities *</label><textarea id="form_jobResponsibilities" name="jobResponsibilities" required rows="4" placeholder="Describe tasks..."></textarea></div>
      <button type="submit" id="modalSubmitBtn" class="btn" style="width: 100%;">Submit Vacancy</button>
    </form>
  </div>
</div>

<script>
  var modal = document.getElementById("jobModal");

  // 💡 创建一个 JS 字典，把所有职位数据安全地存起来供编辑时调用
  var jobsData = {};
  <% if (jobList != null) {
      for (Job j : jobList) { %>
  jobsData["<%= j.getJobId() %>"] = {
    moduleCode: "<%= j.getModuleCode() != null ? j.getModuleCode().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "" %>",
    courseName: "<%= j.getCourseName() != null ? j.getCourseName().replace("\"", "\\\"") : "" %>",
    jobTitle: "<%= j.getJobTitle() != null ? j.getJobTitle().replace("\"", "\\\"") : "" %>",
    activityType: "<%= j.getActivityType() != null ? j.getActivityType() : "Teaching Assistant" %>",
    numberOfPositions: "<%= j.getNumberOfPositions() %>",
    applicationDeadline: "<%= j.getApplicationDeadline() != null ? j.getApplicationDeadline() : "" %>",
    workingHours: "<%= j.getWorkingHours() != null ? j.getWorkingHours().replace("\"", "\\\"") : "" %>",
    semester: "<%= j.getSemester() != null ? j.getSemester().replace("\"", "\\\"") : "" %>",
    location: "<%= j.getLocation() != null ? j.getLocation() : "Offline" %>",
    cgpaRequired: "<%= j.getCgpaRequired() > 0 ? j.getCgpaRequired() : "" %>",
    preferredMajor: "<%= j.getPreferredMajor() != null ? j.getPreferredMajor().replace("\"", "\\\"") : "" %>",
    contactEmail: "<%= j.getContactEmail() != null ? j.getContactEmail().replace("\"", "\\\"") : "" %>",
    contactPhone: "<%= j.getContactPhone() != null ? j.getContactPhone().replace("\"", "\\\"") : "" %>",
    requiredSkills: "<%= j.getRequiredSkills() != null ? j.getRequiredSkills().replace("\"", "\\\"") : "" %>",
    jobResponsibilities: "<%= j.getJobResponsibilities() != null ? j.getJobResponsibilities().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "" %>",
    postedDate: "<%= j.getPostedDate() != null ? j.getPostedDate() : "" %>"
  };
  <%  }
  } %>

  function todayYmd() {
    var now = new Date();
    var year = now.getFullYear();
    var month = String(now.getMonth() + 1).padStart(2, "0");
    var day = String(now.getDate()).padStart(2, "0");
    return year + "-" + month + "-" + day;
  }

  function laterDate(a, b) {
    if (!a) return b || "";
    if (!b) return a || "";
    return a > b ? a : b;
  }

  function setDeadlineMin(postedDate) {
    var deadlineInput = document.getElementById("form_applicationDeadline");
    var minDate = laterDate(todayYmd(), postedDate || "");
    deadlineInput.min = minDate;

    if (deadlineInput.value && deadlineInput.value < minDate) {
      deadlineInput.value = minDate;
    }
  }

  function openCreateModal() {
    document.getElementById("jobForm").reset(); // 清空表单
    document.getElementById("modalAction").value = "create";
    document.getElementById("modalJobId").value = "";
    document.getElementById("modalTitle").innerText = "Create TA Vacancy";
    document.getElementById("modalSubmitBtn").innerText = "Submit Vacancy";
    setDeadlineMin(todayYmd());
    modal.style.display = "block";
  }

  function openEditModal(jobId) {
    var data = jobsData[jobId];
    if (!data) return;

    // 填入数据
    document.getElementById("modalAction").value = "edit";
    document.getElementById("modalJobId").value = jobId;

    document.getElementById("form_moduleCode").value = data.moduleCode;
    document.getElementById("form_courseName").value = data.courseName;
    document.getElementById("form_jobTitle").value = data.jobTitle;
    document.getElementById("form_activityType").value = data.activityType;
    document.getElementById("form_numberOfPositions").value = data.numberOfPositions;
    document.getElementById("form_applicationDeadline").value = data.applicationDeadline;
    document.getElementById("form_workingHours").value = data.workingHours;
    document.getElementById("form_semester").value = data.semester;
    document.getElementById("form_location").value = data.location;
    document.getElementById("form_cgpaRequired").value = data.cgpaRequired;
    document.getElementById("form_preferredMajor").value = data.preferredMajor;
    document.getElementById("form_contactEmail").value = data.contactEmail;
    document.getElementById("form_contactPhone").value = data.contactPhone;
    document.getElementById("form_requiredSkills").value = data.requiredSkills;
    document.getElementById("form_jobResponsibilities").value = data.jobResponsibilities;
    setDeadlineMin(data.postedDate);

    document.getElementById("modalTitle").innerText = "Edit TA Vacancy";
    document.getElementById("modalSubmitBtn").innerText = "Save Changes";
    modal.style.display = "block";
  }

  document.getElementById("jobForm").addEventListener("submit", function(event) {
    var deadlineInput = document.getElementById("form_applicationDeadline");
    var minDate = deadlineInput.min || todayYmd();
    if (deadlineInput.value && deadlineInput.value < minDate) {
      event.preventDefault();
      alert("The application deadline cannot be earlier than the posting date.");
    }
  });

  function closeModal() { modal.style.display = "none"; }
  window.onclick = function(event) { if (event.target == modal) { modal.style.display = "none"; } }
</script>
</body>
</html>
