<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="com.me.finaldesignproject.dao.ApplicationDao" %>
<%
    // 权限校验：只要登录即可查看
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Job> allJobs = (List<Job>) request.getAttribute("jobList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Job List</title>
    <style>
        @keyframes pulse { 0% {opacity: 1;} 50% {opacity: 0.4;} 100% {opacity: 1;} }
        body { margin: 0; padding: 36px 18px; font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif; background: transparent !important; color: #222; min-height: 100vh; position: relative; overflow-y: scroll; /* 🌟 强制显示滚动条轨道，防止挤压跳动 */ }
        body::before { display: none; }
        .page-container { max-width: 1060px; margin: 0 auto; }
        .panel { background: rgba(255, 255, 255, 0.5); border: 1px solid rgba(0, 0, 0, 0.1); border-radius: 18px; padding: 22px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1); backdrop-filter: blur(10px); }
        h2 { margin: 0 0 14px; color: #2c3e50; font-size: 30px; font-weight: 700; }
        .toolbar { margin-bottom: 14px; display: flex; justify-content: space-between; gap: 12px; align-items: center; flex-wrap: wrap; }
        .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; flex: 1; }
        .toolbar-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .search-input { width: min(520px, 100%); padding: 10px 12px; border-radius: 10px; border: 1px solid rgba(0, 0, 0, 0.15); background: rgba(255, 255, 255, 0.8); color: #333; font-size: 15px; }
        .search-input::placeholder { color: #7f8c8d; }
        .search-input:focus { outline: none; border-color: #1e90ff; box-shadow: 0 0 0 3px rgba(30, 144, 255, 0.1); }
        .search-wrap { display: flex; align-items: center; gap: 8px; width: min(620px, 100%); }
        .search-wrap .search-input { flex: 1; width: auto; }
        .search-btn { border: 1px solid rgba(0, 0, 0, 0.1); background: #2c3e50; color: #fff; border-radius: 10px; padding: 9px 12px; cursor: pointer; font-size: 18px; line-height: 1; min-width: 44px; }
        .search-btn:hover { background: #1a252f; }
        .hint { color: #555; font-size: 13px; }
        .top-filter-btn { border: 1px solid rgba(0, 0, 0, 0.1); background: rgba(255, 255, 255, 0.8); color: #2c3e50; border-radius: 999px; padding: 9px 16px; cursor: pointer; font-size: 14px; }
        .top-filter-btn.active { background: #18b394; border-color: #18b394; color: #fff; }
        .table-wrap { overflow-x: auto; border-radius: 12px; border: 1px solid rgba(0, 0, 0, 0.1); position: relative; }
        table { width: 100%; border-collapse: collapse; min-width: 900px; background: rgba(255, 255, 255, 0.3); table-layout: fixed; /* 🌟 锁死表格布局，绝不自动乱调宽度 */ }
        thead th { text-align: left; color: #2c3e50; font-weight: 700; font-size: 15px; padding: 12px 14px; background: rgba(0, 0, 0, 0.05); border-bottom: 1px solid rgba(0, 0, 0, 0.08); cursor: pointer; user-select: none; white-space: nowrap; position: relative; }
        thead th.action-col { cursor: default; }
        .header-caret { margin-left: 6px; font-size: 13px; font-weight: 700; color: #2c3e50; }
        .filter-mark { margin-left: 6px; font-size: 12px; color: #1e90ff; }
        tbody td { padding: 14px; border-bottom: 1px solid rgba(0, 0, 0, 0.05); color: #333; font-size: 15px; line-height: 1.45; vertical-align: middle; }

        /* 🌟 二级展开UI设计 */
        .job-row { cursor: pointer; transition: background-color 0.2s ease; }
        .job-row:hover { background-color: rgba(30, 144, 255, 0.06) !important; }
        .expand-row { display: none; background-color: #fcfcfc; border-bottom: 2px solid #eaeaea; }
        .expand-row.open { display: table-row; }
        .expand-content { padding: 20px 24px; color: #444; display: flex; flex-direction: column; gap: 12px; border-left: 4px solid #1e90ff; }
        .expand-title { font-weight: 700; color: #2c3e50; font-size: 15px; display: block; margin-bottom: 4px; }
        .responsibilities-text { font-size: 14px; line-height: 1.6; background: #fff; padding: 12px 16px; border-radius: 8px; border: 1px solid #eee; }

        .view-btn { display: inline-block; padding: 7px 12px; border-radius: 8px; color: #fff; background: #1e90ff; text-decoration: none; font-size: 13px; border: none; }
        .view-btn:hover { background: #187bcd; }
        .view-btn.closed, .view-btn.overdue { background: #95a5a6; cursor: not-allowed; pointer-events: none; }
        .apply-btn { display: inline-flex; align-items: center; justify-content: center; padding: 7px 16px; border-radius: 10px; color: #ffffff; background: linear-gradient(135deg, #ff9800, #f57c00); text-decoration: none; font-size: 13px; font-weight: 600; border: none; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer; box-shadow: 0 4px 10px rgba(255, 152, 0, 0.25); }
        .apply-btn:hover { background: linear-gradient(135deg, #fb8c00, #ef6c00); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(255, 152, 0, 0.4); }
        .apply-btn.disabled { background: #555555 !important; color: #999999 !important; cursor: not-allowed !important; pointer-events: none; transform: none !important; box-shadow: none !important; opacity: 0.8; }

        .gap-btn { background: linear-gradient(135deg, #8e44ad, #9b59b6); padding: 9px 20px; font-size: 14px; border-radius: 8px; align-self: flex-start; margin-top: 5px; }
        .gap-btn:hover { background: linear-gradient(135deg, #732d91, #8e44ad); box-shadow: 0 6px 15px rgba(142, 68, 173, 0.4); }

        .empty { color: #666; margin-top: 10px; font-style: italic; }
        .header-filter { position: fixed; z-index: 9999; min-width: 220px; max-width: 320px; max-height: 300px; overflow: auto; border-radius: 10px; border: 1px solid #ddd; background: #fff; box-shadow: 0 16px 30px rgba(0,0,0,0.15); padding: 10px; display: none; }
        .header-filter .filter-title { color: #2c3e50; font-weight: 700; margin-bottom: 8px; font-size: 14px; }
        .filter-option { width: 100%; text-align: left; margin-bottom: 6px; padding: 7px 9px; border-radius: 7px; border: 1px solid #eee; background: #f9f9f9; color: #333; cursor: pointer; font-size: 13px; }
        .filter-option.active { border-color: #18b394; background: rgba(24, 179, 148, 0.1); color: #18b394; }

        /* 🌟 Gap Report Modal 样式 */
        #gapModal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 10000; justify-content: center; align-items: center; opacity: 0; transition: opacity 0.3s ease; }
        #gapModalContent { background: #fff; width: 650px; max-width: 90%; border-radius: 16px; padding: 30px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); transform: translateY(20px); transition: transform 0.3s ease; display: flex; flex-direction: column; }
        #gapModalTitle { margin-top: 0; color: #2c3e50; font-size: 22px; border-bottom: 2px solid #f0f2f5; padding-bottom: 15px; margin-bottom: 15px; }
        #gapModalBody { font-size: 15px; line-height: 1.8; color: #444; max-height: 60vh; overflow-y: auto; padding-right: 10px; }
        #gapModalBody::-webkit-scrollbar { width: 6px; }
        #gapModalBody::-webkit-scrollbar-thumb { background: #ccc; border-radius: 4px; }
    </style>
</head>
<body>
<div class="page-container">
    <div class="panel">
        <h2>Job List</h2>

        <div class="toolbar">
            <div class="toolbar-left">
                <div class="search-wrap">
                    <input id="jobSearch" class="search-input" type="text" placeholder="Search visible columns...">
                    <button id="btnSearch" class="search-btn" type="button" title="Search">Search</button>
                </div>
                <span class="hint">Click a header to filter. Max Applications Workload: 20h.</span>
            </div>
            <div class="toolbar-right">
                <button id="btnClearAll" class="top-filter-btn" type="button">Clear All Filters</button>
                <button id="btnNotExpired" class="top-filter-btn" type="button">Only Not Expired</button>
            </div>
        </div>

        <div class="table-wrap">
            <table id="jobTable">
                <thead>
                <tr>
                    <th style="width: 10%;" data-key="creator" data-label="Creator">Creator<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 18%;" data-key="course" data-label="Course">Course<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 19%;" data-key="title" data-label="Title">Title<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 12%;" data-key="deadline" data-label="Deadline">Deadline<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 9%;" data-key="position" data-label="Position">Position<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 10%; text-align: center;">AI Match</th>
                    <th style="width: 22%;" class="action-col">Action</th>
                </tr>
                </thead>

                <%
                    // 🌟 获取已申请岗位的总工时累积 (同学提供的功能)
                    String currentUserId = (String) session.getAttribute("userId");
                    Set<String> appliedJobIds = new HashSet<>();
                    int totalAppliedHours = 0;
                    if (currentUserId != null) {
                        ApplicationDao appDao = new ApplicationDao();
                        appliedJobIds = appDao.getAppliedJobIds(currentUserId);
                        // 累加已申请的所有岗位的时长
                        totalAppliedHours = appDao.getAppliedTotalHours(currentUserId);
                    }
                %>

                <tbody>
                <% if (allJobs != null && !allJobs.isEmpty()) { %>
                <% LocalDate today = LocalDate.now();
                    for (Job job : allJobs) {
                        String courseName = job.getCourseName() == null ? "" : job.getCourseName();
                        String moduleCode = job.getModuleCode() == null ? "-" : job.getModuleCode();
                        String course = courseName + " (" + moduleCode + ")";
                        String title = job.getJobTitle() == null ? "-" : job.getJobTitle();
                        String deadline = job.getApplicationDeadline() == null ? "-" : job.getApplicationDeadline();
                        int positionsLeft = job.getNumberOfPositions();
                        String creatorName = (job.getCreatorName() == null || job.getCreatorName().isEmpty()) ? "Unknown" : job.getCreatorName();

                        // 🌟 解析当前职位的工时 (同学提供的功能)
                        int thisJobHours = 0;
                        try {
                            String hStr = (job.getWorkingHours() != null) ? job.getWorkingHours().replaceAll("[^0-9]", "") : "0";
                            thisJobHours = hStr.isEmpty() ? 0 : Integer.parseInt(hStr);
                        } catch(Exception e) { thisJobHours = 0; }

                        boolean isClosed = "Closed".equalsIgnoreCase(job.getStatus()) || !job.isStudentCanApply();
                        boolean isOverdue = false;
                        try {
                            if (job.getApplicationDeadline() != null && !job.getApplicationDeadline().trim().isEmpty()) {
                                isOverdue = LocalDate.parse(job.getApplicationDeadline().trim()).isBefore(today);
                            }
                        } catch (Exception e) {
                            isOverdue = false;
                        }

                        boolean blockView = isClosed || isOverdue;
                        String viewClass = isOverdue ? "view-btn overdue" : (isClosed ? "view-btn closed" : "view-btn");
                        String viewLabel = isOverdue ? "Overdue" : (isClosed ? "Close" : "View");

                        String courseAttr = course.toLowerCase().replace("\"", "&quot;");
                        String titleAttr = title.toLowerCase().replace("\"", "&quot;");
                        String deadlineAttr = deadline.replace("\"", "&quot;");
                        String positionAttr = String.valueOf(positionsLeft).replace("\"", "&quot;");
                        String creatorAttr = creatorName.toLowerCase().replace("\"", "&quot;");

                        // 🌟 获取岗位职责并转义 HTML (你的功能)
                        String respText = job.getJobResponsibilities() == null || job.getJobResponsibilities().trim().isEmpty()
                                ? "No detailed responsibilities provided by the MO."
                                : job.getJobResponsibilities().replace("\"", "&quot;").replace("\r\n", "<br>").replace("\n", "<br>");
                %>
                <tr class="job-row" data-jobid="<%= job.getJobId() %>"
                    data-course="<%= courseAttr %>"
                    data-title="<%= titleAttr %>"
                    data-deadline="<%= deadlineAttr %>"
                    data-position="<%= positionAttr %>"
                    data-creator="<%= creatorAttr %>"
                    onclick="toggleExpand(this)">

                    <td><%= creatorName %></td>
                    <td><%= course %></td>
                    <td><%= title %></td>
                    <td><%= deadline %></td>
                    <td><%= positionsLeft %></td>

                    <!-- Ai没准备好就是loading+沙漏的状态 -->
                    <td class="ai-score-cell" style="text-align: center; font-weight: bold;">
                        <% if (blockView) { %>
                        <span style="color: #95a5a6;">N/A</span>
                        <% } else { %>
                        <span style="color: #1e90ff; font-size: 13px; animation: pulse 1.5s infinite;">⏳ Loading</span>
                        <% } %>
                    </td>

                    <td>
                        <div style="display: flex; gap: 8px;">
                            <% if (blockView) { %>
                            <span class="<%= viewClass %>" onclick="event.stopPropagation();"><%= viewLabel %></span>
                            <% } else { %>
                            <a class="<%= viewClass %>" href="view_job.jsp?jobId=<%= job.getJobId() %>&from=StudentJobServlet" onclick="event.stopPropagation();">View</a>
                            <% } %>

                            <% if (appliedJobIds != null && appliedJobIds.contains(job.getJobId())) { %>
                            <a class="apply-btn disabled" href="javascript:void(0);" onclick="event.stopPropagation();">Applied</a>
                            <% } else if (isOverdue) { %>
                            <a class="apply-btn disabled" href="javascript:void(0);" onclick="event.stopPropagation();">Apply</a>
                            <% } else if (isClosed) { %>
                            <a class="apply-btn disabled" style="background: #b9770e !important;" href="javascript:void(0);" onclick="event.stopPropagation();">Close</a>
                            <% } else if (positionsLeft <= 0) { %>
                            <a class="apply-btn disabled" style="background: #777 !important;" href="javascript:void(0);" onclick="event.stopPropagation();">Full</a>
                            <% } else { %>

                            <%-- 🌟 核心融合点：防冒泡 (你的) + 传递同学的新工时参数 (同学的) --%>
                            <a class="apply-btn" href="javascript:void(0);"
                               onclick="event.stopPropagation(); confirmApply('<%= job.getJobId() %>', '<%= title.replace("'", "\\'").replace("\n", " ").replace("\r", " ") %>', event, <%= totalAppliedHours %>, <%= thisJobHours %>)">Apply</a>
                            <% } %>
                        </div>
                    </td>
                </tr>

                <tr class="expand-row" id="expand-<%= job.getJobId() %>">
                    <td colspan="7" style="padding: 0;">
                        <div class="expand-content">
                            <div>
                                <span class="expand-title">Responsibilities / Requirements:</span>
                                <div class="responsibilities-text"><%= respText %></div>
                            </div>
                            <div>
                                <% if (!blockView) { %>
                                <button class="apply-btn gap-btn" type="button" onclick="showGapModal('<%= job.getJobId() %>')">
                                    ✨ Review AI Gap Analysis
                                </button>
                                <% } else { %>
                                <span style="color:#999; font-size:12px; font-style:italic;">(Analysis disabled for closed jobs)</span>
                                <% } %>
                            </div>
                        </div>
                    </td>
                </tr>
                <% } %>
                <% } %>
                </tbody>
            </table>
        </div>

        <% if (allJobs == null || allJobs.isEmpty()) { %>
        <div class="empty">No jobs found.</div>
        <% } %>
    </div>
</div>

<div id="gapModal">
    <div id="gapModalContent">
        <h3 id="gapModalTitle">AI Gap Analysis</h3>
        <div id="gapModalBody"></div>
        <div style="text-align: right; margin-top: 20px;">
            <button onclick="closeGapModal()" style="padding: 10px 24px; border: none; background: #1e90ff; color: #fff; border-radius: 8px; cursor: pointer; font-weight: bold; transition: background 0.2s;">Got it</button>
        </div>
    </div>
</div>

<div id="headerFilter" class="header-filter"></div>

<script>
    // --- 你的 UI 与展开控制逻辑 ---
    function toggleExpand(row) {
        const expandRow = row.nextElementSibling;
        if (expandRow && expandRow.classList.contains('expand-row')) {
            expandRow.classList.toggle('open');
        }
    }

    // 🌟 终极防弹版 Modal 控制逻辑
    function showGapModal(jobId) {
        // 核心修复：坚决杜绝反引号拼接！用原始的加号，绝不让 Tomcat 误吃变量
        const mainRow = document.querySelector("tr.job-row[data-jobid='" + jobId + "']");
        if(!mainRow) return;

        const reason = mainRow.getAttribute('data-aireason');
        const title = mainRow.getAttribute('data-title') || '岗位';

        // 拦截所有的空值，防止程序静默崩溃
        if (!reason || reason === 'undefined' || reason === 'null' || reason.trim() === '') {
            alert("⚠️ AI 分析报告不可用！\n\n可能原因：\n1. AI 还在排队打分，请稍候。\n2. 该岗位已关闭或未开放打分。");
            return;
        }

        // 自动排版优化：换行与高亮
        let formattedReason = reason.replace(/\n/g, '<br><br>');
        formattedReason = formattedReason.replace(/•\s*(.*?):/g, '<strong style="color:#1e90ff; font-size:16px;">• $1:</strong>');

        document.getElementById('gapModalTitle').innerText = '【' + title + '】 AI Skills Analysis';
        document.getElementById('gapModalBody').innerHTML = formattedReason;

        const modal = document.getElementById('gapModal');
        const modalContent = document.getElementById('gapModalContent');
        modal.style.display = 'flex';
        void modal.offsetWidth; // 触发重绘，保证动画连贯
        modal.style.opacity = '1';
        modalContent.style.transform = 'translateY(0)';
    }

    function closeGapModal() {
        const modal = document.getElementById('gapModal');
        const modalContent = document.getElementById('gapModalContent');
        modal.style.opacity = '0';
        modalContent.style.transform = 'translateY(20px)';
        setTimeout(() => { modal.style.display = 'none'; }, 300);
    }

    // --- 同学的重构版 Apply 确认逻辑 ---
    function confirmApply(jobId, jobTitle, event, totalAppliedHours, thisJobHours) {
        if (event) event.preventDefault();
        const btn = event.currentTarget;

        if (btn.classList.contains('disabled')) return;

        const currentTotal = parseInt(totalAppliedHours) || 0;
        const adding = parseInt(thisJobHours) || 0;
        const nextTotal = currentTotal + adding;

        console.log("Applied Hours:", currentTotal, "Current Job:", adding, "Estimated Total:", nextTotal);

        let msg = "Are you sure you want to apply for the position: \n[" + jobTitle + "]?";

        if (nextTotal > 20) {
            msg = "⚠️ WORKLOAD LIMIT WARNING!\n\n" +
                "Your current applied workload is " + currentTotal + "h.\n" +
                "Applying for this " + adding + "h job will bring your total workload to " + nextTotal + "h.\n\n" +
                "This exceeds the 20h limit. The Module Leader may reject your application. Do you still want to proceed?";
        }

        if (confirm(msg)) {
            btn.classList.add('disabled');
            btn.innerText = "Processing...";

            fetch("ApplyJobServlet?jobId=" + jobId, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
                .then(response => {
                    if (response.ok) {
                        alert("Applied successfully!");

                        // 🌟 核心优化：不要刷新页面！直接把当前按钮变成灰色的“已申请”状态
                        btn.classList.add('disabled');
                        btn.innerText = "Applied";
                        btn.style.background = "#555555"; // 变成灰色
                        btn.style.boxShadow = "none";
                        btn.onclick = null; // 彻底废掉它的点击功能
                    } else {
                        alert("Application failed. You may have already applied or the session expired.");
                        btn.classList.remove('disabled');
                        btn.innerText = "Apply";
                    }
                })
                .catch(err => {
                    alert("Server error, please try again.");
                    btn.classList.remove('disabled');
                    btn.innerText = "Apply";
                });
        }
    }

    // --- 筛选与搜索功能 ---
    (function () {
        const table = document.getElementById("jobTable");
        if (!table) return;

        const tbody = table.querySelector("tbody");
        const rows = Array.from(tbody.querySelectorAll("tr.job-row")); // 仅筛选主行
        const searchInput = document.getElementById("jobSearch");
        const btnSearch = document.getElementById("btnSearch");
        const btnClearAll = document.getElementById("btnClearAll");
        const btnNotExpired = document.getElementById("btnNotExpired");
        const filterPopup = document.getElementById("headerFilter");
        const headers = Array.from(table.querySelectorAll("thead th[data-key]"));

        const state = { textQuery: "", onlyNotExpired: false, columnFilters: { course: "", title: "", position: "", creator: "" }, deadlineBefore: "" };

        function normalize(str) { return (str || "").toString().trim().toLowerCase(); }

        function buildSearchHay(row) {
            const visibleCols = [];
            for (let i = 0; i <= 5; i++) {
                const cell = row.cells[i];
                if (cell) visibleCols.push(cell.textContent || "");
            }
            return normalize(visibleCols.join(" "));
        }

        function matchesSearch(hay, query) {
            if (!query) return true;
            const h = normalize(hay);
            const q = normalize(query);
            return q.split(/\s+/).filter(Boolean).every(token => h.includes(token));
        }

        function parseYmdDate(dateStr) {
            const v = (dateStr || "").trim();
            if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) return null;
            const t = Date.parse(v + "T00:00:00");
            return isNaN(t) ? null : t;
        }

        function todayStart() {
            const d = new Date();
            d.setHours(0, 0, 0, 0);
            return d.getTime();
        }

        function refreshHeaderMarks() {
            headers.forEach(th => {
                const key = th.dataset.key;
                const mark = th.querySelector(".filter-mark");
                if (!mark) return;
                mark.textContent = (key === "deadline") ? (state.deadlineBefore ? "*" : "") : (state.columnFilters[key] ? "*" : "");
            });
        }

        function applyFilters() {
            const q = normalize(state.textQuery);
            const today = todayStart();
            const beforeTime = parseYmdDate(state.deadlineBefore);

            rows.forEach(row => {
                const searchHay = buildSearchHay(row);
                const courseVal = normalize(row.getAttribute("data-course"));
                const titleVal = normalize(row.getAttribute("data-title"));
                const positionVal = normalize(row.getAttribute("data-position"));
                const creatorVal = normalize(row.getAttribute("data-creator"));
                const deadlineVal = (row.getAttribute("data-deadline") || "").trim();
                const deadlineTime = parseYmdDate(deadlineVal);

                let visible = true;
                if (!matchesSearch(searchHay, q)) visible = false;
                if (visible && state.onlyNotExpired) visible = deadlineTime !== null && deadlineTime >= today;
                if (visible && state.columnFilters.course && courseVal !== state.columnFilters.course) visible = false;
                if (visible && state.columnFilters.title && titleVal !== state.columnFilters.title) visible = false;
                if (visible && state.columnFilters.position && positionVal !== state.columnFilters.position) visible = false;
                if (visible && state.columnFilters.creator && creatorVal !== state.columnFilters.creator) visible = false;
                if (visible && beforeTime !== null) visible = deadlineTime !== null && deadlineTime <= beforeTime;

                row.style.display = visible ? "" : "none";

                // 搜索时同步隐藏折叠行
                const expandRow = document.getElementById("expand-" + row.getAttribute("data-jobid"));
                if (expandRow) {
                    if (!visible) expandRow.classList.remove('open');
                }
            });

            refreshHeaderMarks();
            btnNotExpired.classList.toggle("active", state.onlyNotExpired);
        }

        function closePopup() { filterPopup.style.display = "none"; filterPopup.innerHTML = ""; }

        function placePopupNear(th) {
            const rect = th.getBoundingClientRect();
            filterPopup.style.top = (rect.bottom + window.scrollY + 6) + "px";
            filterPopup.style.left = Math.max(10, rect.left) + "px";
            filterPopup.style.display = "block";
        }

        function getUniqueValues(key, colIndex) {
            const map = new Map();
            rows.forEach(row => {
                const v = normalize(row.getAttribute("data-" + key));
                const label = (row.cells[colIndex] ? row.cells[colIndex].textContent : "").trim();
                if (v && !map.has(v)) map.set(v, label || v);
            });
            return Array.from(map.entries()).sort((a, b) => a[1].localeCompare(b[1]));
        }

        function openValueFilter(th) {
            const key = th.dataset.key;
            const headerLabel = th.dataset.label || th.textContent.trim();
            const colIndex = { creator: 0, course: 1, title: 2, position: 4 }[key];
            const values = getUniqueValues(key, colIndex);
            let html = '<div class="filter-title">Filter ' + headerLabel + '</div>';
            html += '<button class="filter-option ' + (!state.columnFilters[key] ? 'active' : '') + '" data-val="">All</button>';
            values.forEach(([val, label]) => {
                const active = state.columnFilters[key] === val ? 'active' : '';
                html += '<button class="filter-option ' + active + '" data-val="' + val.replace(/"/g, '&quot;') + '">' + label + '</button>';
            });
            filterPopup.innerHTML = html;

            placePopupNear(th);
            filterPopup.querySelectorAll(".filter-option").forEach(btn => {
                btn.addEventListener("click", () => { state.columnFilters[key] = normalize(btn.getAttribute("data-val")); closePopup(); applyFilters(); });
            });
        }

        function openDeadlineFilter(th) {
            const safeVal = state.deadlineBefore || "";
            filterPopup.innerHTML = '<div class="filter-title">Deadline Filter</div><div class="deadline-box"><input type="date" id="deadlineFilterInput" value="' + safeVal + '"><div class="hint">On or before selected date.</div><div class="deadline-actions"><button type="button" class="primary" id="deadlineApplyBtn">Apply</button><button type="button" id="deadlineClearBtn">Clear</button></div></div>';
            placePopupNear(th);
            const input = document.getElementById("deadlineFilterInput");
            document.getElementById("deadlineApplyBtn").addEventListener("click", () => { state.deadlineBefore = (input.value || "").trim(); closePopup(); applyFilters(); });
            document.getElementById("deadlineClearBtn").addEventListener("click", () => { state.deadlineBefore = ""; closePopup(); applyFilters(); });
        }

        function runSearch() { state.textQuery = searchInput.value || ""; applyFilters(); }
        searchInput.addEventListener("input", runSearch);
        btnSearch.addEventListener("click", runSearch);
        btnNotExpired.addEventListener("click", () => { state.onlyNotExpired = !state.onlyNotExpired; applyFilters(); });
        btnClearAll.addEventListener("click", () => { state.textQuery = ""; state.onlyNotExpired = false; state.deadlineBefore = ""; Object.keys(state.columnFilters).forEach(k => state.columnFilters[k] = ""); searchInput.value = ""; closePopup(); applyFilters(); });
        headers.forEach(th => { th.addEventListener("click", (e) => { e.stopPropagation(); const key = th.dataset.key; if (!key) return; closePopup(); if (key === "deadline") openDeadlineFilter(th); else openValueFilter(th); }); });
        document.addEventListener("click", (e) => { if (filterPopup.style.display !== "block") return; if (!filterPopup.contains(e.target)) closePopup(); });
        applyFilters();
    })();


    // --- 你的 AI 打分获取与排队渲染 ---注意美元加中括号对的写法在jsp中的歧义
    async function loadAiScores() {
        const tbody = document.querySelector("#jobTable tbody");
        if (!tbody) return;
        const rows = Array.from(tbody.querySelectorAll("tr.job-row"));
        const contextPath = "<%= request.getContextPath() %>";

        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            let jobId = row.getAttribute("data-jobid");
            if (!jobId || jobId.trim() === "") continue;
            jobId = jobId.trim();

            const aiCell = row.querySelector('.ai-score-cell') || row.cells[5];
            if (!aiCell || aiCell.innerText.includes('N/A')) continue;

            try {
                const url = new URL(window.location.origin + contextPath + "/GetAiScoreServlet");
                url.searchParams.append("jobId", jobId);

                const res = await fetch(url.toString());
                const text = await res.text();

                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    aiCell.innerHTML = "<span style='color:#e74c3c; font-weight:bold;'>Error</span>";
                    continue;
                }

                if (data.success) {
                    row.setAttribute('data-aiscore', data.score);
                    row.setAttribute('data-aireason', data.reason);
                    row.setAttribute('data-title', row.cells[2].innerText.trim());

                    let color = data.score >= 80 ? "#2ecc71" : (data.score >= 60 ? "#f39c12" : "#e74c3c");
                    let finalScore = Number(data.score) || 0;

                    aiCell.innerHTML = "<span style='color: " + color + "; font-weight: bold; font-size: 16px;'>" + finalScore + "%</span>";
                } else {
                    aiCell.innerHTML = "<span style='color: #e74c3c; font-size: 13px;'>" + (data.message || 'Error') + "</span>";
                }
            } catch (err) {
                aiCell.innerHTML = "<span style='color: #e74c3c; font-size: 13px;'>Net Err</span>";
            }
        }

        sortTableByAiScore();
    }

    // 🌟 终极防撕裂排序逻辑：将主行和折叠行“死死绑定”后再排序
    function sortTableByAiScore() {
        const tbody = document.querySelector("#jobTable tbody");
        const mainRows = Array.from(tbody.querySelectorAll("tr.job-row"));

        // 1. 在打乱顺序前，先把它们结成“对子”
        const rowPairs = mainRows.map(row => {
            return {
                main: row,
                // 直接抓取紧跟在主行后面的那个折叠行，不再依赖 ID 查找
                expand: (row.nextElementSibling && row.nextElementSibling.classList.contains('expand-row')) ? row.nextElementSibling : null,
                score: parseInt(row.getAttribute('data-aiscore')) || -1
            };
        });

        // 2. 根据 AI 分数对“对子”进行排序
        rowPairs.sort((a, b) => b.score - a.score);

        // 3. 按排好的顺序，成对地挂载回表格，绝对不会再错位！
        rowPairs.forEach(pair => {
            tbody.appendChild(pair.main);
            if (pair.expand) {
                tbody.appendChild(pair.expand);
            }
        });
    }

    window.addEventListener('DOMContentLoaded', loadAiScores);
</script>
</body>
</html>
