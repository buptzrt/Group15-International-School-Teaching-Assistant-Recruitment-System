<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%
    // 权限校验：仅允许 MO 角色访问该页面。
    if (session == null || session.getAttribute("role") == null || !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    // 获取所有职位，并默认排序：未过期职位在前，超过 Deadline 的职位放到最后；同组内按 Deadline 从早到晚排序。
    List<Job> allJobs = new JobDao().getAllJobs();
    if (allJobs != null) {
        allJobs.sort(new Comparator<Job>() {
            private LocalDate parseDeadline(Job job) {
                try {
                    String deadline = job == null ? null : job.getApplicationDeadline();
                    if (deadline == null || deadline.trim().isEmpty()) {
                        // 没有截止日期的职位排在最后。
                        return LocalDate.MAX;
                    }
                    return LocalDate.parse(deadline.trim());
                } catch (Exception ignored) {
                    // 截止日期格式异常时也排在最后，避免页面渲染失败。
                    return LocalDate.MAX;
                }
            }

            private boolean isOverdue(Job job) {
                LocalDate deadline = parseDeadline(job);
                return !LocalDate.MAX.equals(deadline) && deadline.isBefore(LocalDate.now());
            }

            @Override
            public int compare(Job a, Job b) {
                int overdueCompare = Boolean.compare(isOverdue(a), isOverdue(b));
                if (overdueCompare != 0) {
                    return overdueCompare;
                }
                return parseDeadline(a).compareTo(parseDeadline(b));
            }
        });
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Job List</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app-theme.css">
    <style>
        /* 滚动条整体样式 */
        ::-webkit-scrollbar {
            width: 8px; /* 纵向滚动条宽度 */
            height: 8px; /* 横向滚动条高度 */
        }
        /* 滚动条轨道 */
        ::-webkit-scrollbar-track {
            background: transparent; /* 轨道透明，和背景融合 */
        }
        /* 滚动条滑块 */
        ::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.25); /* 半透明白色滑块 */
            border-radius: 10px; /* 圆角设计 */
        }
        /* 鼠标悬停在滑块上的效果 */
        ::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.45); /* 悬停时稍微变亮 */
        }
        /* 页面基础样式 */
        body {
            margin: 0;
            padding: 36px 18px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #f4f7fb;
            min-height: 100vh;
            position: relative;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background: rgba(18, 35, 61, 0.78);
            z-index: -1;
        }

        .page-container {
            max-width: 1060px;
            margin: 0 auto;
        }

        .panel {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 18px;
            padding: 22px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
            backdrop-filter: blur(10px);
        }

        h2 {
            margin: 0 0 14px;
            color: #ffd166;
            font-size: 30px;
            font-weight: 700;
        }

        .toolbar {
            margin-bottom: 14px;
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }

        .toolbar-left {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            flex: 1;
        }

        .toolbar-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .search-input {
            width: min(520px, 100%);
            padding: 10px 12px;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.28);
            background: rgba(255, 255, 255, 0.12);
            color: #fff;
            font-size: 15px;
        }

        .search-input::placeholder {
            color: #d8e2ef;
        }

        .search-input:focus {
            outline: none;
            border-color: #9bd3ff;
            box-shadow: 0 0 0 3px rgba(155, 211, 255, 0.22);
        }

        .search-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
            width: min(620px, 100%);
        }

        .search-wrap .search-input {
            flex: 1;
            width: auto;
        }

        .search-btn {
            border: 1px solid rgba(255, 255, 255, 0.22);
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border-radius: 10px;
            padding: 9px 12px;
            cursor: pointer;
            font-size: 18px;
            line-height: 1;
            min-width: 44px;
        }

        .search-btn:hover {
            background: rgba(255, 255, 255, 0.18);
        }

        .hint {
            color: #d8e2ef;
            font-size: 13px;
        }

        .top-filter-btn {
            border: 1px solid rgba(255, 255, 255, 0.2);
            background: rgba(255, 255, 255, 0.08);
            color: #fff;
            border-radius: 999px;
            padding: 9px 16px;
            cursor: pointer;
            font-size: 14px;
        }

        .top-filter-btn.active {
            background: #18b394;
            border-color: #18b394;
        }

        .table-wrap {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.18);
            position: relative;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
            background: rgba(255, 255, 255, 0.05);
        }

        thead th {
            text-align: left;
            color: #ffd166;
            font-weight: 700;
            font-size: 15px;
            padding: 12px 14px;
            background: rgba(0, 0, 0, 0.15);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            cursor: pointer;
            user-select: none;
            white-space: nowrap;
            position: relative;
        }

        thead th.action-col {
            cursor: default;
        }

        .header-caret {
            margin-left: 6px;
            font-size: 13px;
            font-weight: 700;
            color: #ffd166;
        }

        .filter-mark {
            margin-left: 6px;
            font-size: 12px;
            color: #9bd3ff;
        }

        tbody td {
            padding: 12px 14px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            color: #f5f9ff;
            font-size: 15px;
            line-height: 1.45;
            vertical-align: middle;
        }

        tbody tr:hover {
            background: rgba(255, 255, 255, 0.08);
        }

        tr.overdue-job-row,
        .table-page tbody tr.overdue-job-row,
        .role-table-page tbody tr.overdue-job-row {
            filter: grayscale(0.85);
        }

        tr.overdue-job-row td,
        .table-page tbody tr.overdue-job-row td,
        .role-table-page tbody tr.overdue-job-row td {
            color: rgba(210, 218, 226, 0.56) !important;
            background: rgba(104, 113, 123, 0.42) !important;
            border-bottom-color: rgba(210, 218, 226, 0.12) !important;
        }

        tr.overdue-job-row:hover td,
        .table-page tbody tr.overdue-job-row:hover td,
        .role-table-page tbody tr.overdue-job-row:hover td {
            background: rgba(104, 113, 123, 0.5) !important;
        }

        tr.overdue-job-row .view-btn,
        .table-page tbody tr.overdue-job-row .view-btn,
        .role-table-page tbody tr.overdue-job-row .view-btn {
            background: rgba(127, 140, 141, 0.9) !important;
            color: rgba(255, 255, 255, 0.82) !important;
            border-color: rgba(210, 218, 226, 0.18) !important;
            box-shadow: none !important;
        }

        .view-btn {
            display: inline-block;
            padding: 7px 12px;
            border-radius: 8px;
            color: #fff;
            background: #1e90ff;
            text-decoration: none;
            font-size: 13px;
            border: 1px solid rgba(255,255,255,0.18);
        }

        .view-btn:hover {
            background: #187bcd;
        }

        .empty {
            color: #d7e3f1;
            margin-top: 10px;
            font-style: italic;
        }

        /* 表头筛选弹窗样式 */
        .header-filter {
            position: fixed;
            z-index: 9999;
            min-width: 220px;
            max-width: 320px;
            max-height: 300px;
            overflow: auto;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.24);
            background: #20344f;
            box-shadow: 0 16px 30px rgba(0,0,0,0.35);
            padding: 10px;
            display: none;
        }

        .header-filter .filter-title {
            color: #ffd166;
            font-weight: 700;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .filter-option {
            width: 100%;
            text-align: left;
            margin-bottom: 6px;
            padding: 7px 9px;
            border-radius: 7px;
            border: 1px solid rgba(255,255,255,0.18);
            background: rgba(255,255,255,0.06);
            color: #fff;
            cursor: pointer;
            font-size: 13px;
        }

        .filter-option.active {
            border-color: #18b394;
            background: rgba(24,179,148,0.3);
        }

        .deadline-box {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .deadline-box input[type="date"] {
            padding: 8px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            background: rgba(255,255,255,0.1);
            color: #fff;
        }

        .deadline-actions {
            display: flex;
            gap: 8px;
        }

        .deadline-actions button {
            flex: 1;
            padding: 7px 8px;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.2);
            color: #fff;
            background: rgba(255,255,255,0.08);
            cursor: pointer;
            font-size: 13px;
        }

        .deadline-actions button.primary {
            background: #18b394;
            border-color: #18b394;
        }
    </style>
</head>
<body class="app-auth-bg table-page role-table-page">
<div class="page-container">
    <div class="panel">
        <h2>Job List</h2>

        <div class="toolbar">
            <div class="toolbar-left">
                <div class="search-wrap">
                    <input id="jobSearch" class="search-input" type="text" placeholder="Search visible columns...">
                    <button id="btnSearch" class="search-btn" type="button" title="Search">Search</button>
                </div>
                <span class="hint">Click a header to filter.</span>
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
                    <th data-key="creator">Creator<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th data-key="course">Course<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th data-key="type">Type<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th data-key="location">Location<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th data-key="deadline">Deadline<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th data-key="position">Position<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th class="action-col">Action</th>
                </tr>
                </thead>
                <tbody>
                <% if (allJobs != null && !allJobs.isEmpty()) { %>
                <% for (Job job : allJobs) {
                    String courseName = job.getCourseName() == null ? "" : job.getCourseName();
                    String moduleCode = job.getModuleCode() == null ? "-" : job.getModuleCode();
                    String course = courseName + " (" + moduleCode + ")";
                    String type = job.getActivityType() == null ? "-" : job.getActivityType();
                    String location = job.getLocation() == null ? "-" : job.getLocation();
                    String deadline = job.getApplicationDeadline() == null ? "-" : job.getApplicationDeadline();
                    String position = String.valueOf(job.getNumberOfPositions());
                    boolean isOverdue = false;
                    try {
                        isOverdue = job.getApplicationDeadline() != null
                                && !job.getApplicationDeadline().trim().isEmpty()
                                && LocalDate.parse(job.getApplicationDeadline().trim()).isBefore(LocalDate.now());
                    } catch (Exception ignored) {
                        isOverdue = false;
                    }
                    // 获取发布者姓名，缺失时显示为 Unknown。
                    String creatorName = (job.getCreatorName() == null || job.getCreatorName().isEmpty()) ? "Unknown" : job.getCreatorName();

                    String courseAttr = course.toLowerCase().replace("\"", "&quot;");
                    String typeAttr = type.toLowerCase().replace("\"", "&quot;");
                    String locationAttr = location.toLowerCase().replace("\"", "&quot;");
                    String deadlineAttr = deadline.replace("\"", "&quot;");
                    String positionAttr = position.replace("\"", "&quot;");
                    // 处理 data 属性值，方便前端搜索和筛选。
                    String creatorAttr = creatorName.toLowerCase().replace("\"", "&quot;");
                %>
                <tr class="<%= isOverdue ? "overdue-job-row" : "" %>"
                    data-course="<%= courseAttr %>"
                    data-type="<%= typeAttr %>"
                    data-location="<%= locationAttr %>"
                    data-deadline="<%= deadlineAttr %>"
                    data-position="<%= positionAttr %>"
                    data-creator="<%= creatorAttr %>">
                    <td><%= creatorName %></td>
                    <td><%= course %></td>
                    <td><%= type %></td>
                    <td><%= location %></td>
                    <td><%= deadline %></td>
                    <td><%= position %></td>
                    <td><a class="view-btn" href="view_job.jsp?jobId=<%= job.getJobId() %>&from=mo_job_list.jsp">View</a></td>
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

<div id="headerFilter" class="header-filter"></div>

<script>
    (function () {
        const table = document.getElementById("jobTable");
        if (!table) return;

        const tbody = table.querySelector("tbody");
        const rows = Array.from(tbody.querySelectorAll("tr"));
        const searchInput = document.getElementById("jobSearch");
        const btnSearch = document.getElementById("btnSearch");
        const btnClearAll = document.getElementById("btnClearAll");
        const btnNotExpired = document.getElementById("btnNotExpired");
        const filterPopup = document.getElementById("headerFilter");
        const headers = Array.from(table.querySelectorAll("thead th[data-key]"));

        const state = {
            textQuery: "",
            onlyNotExpired: false,
            columnFilters: {
                course: "",
                type: "",
                location: "",
                position: "",
                creator: "" // Creator 列的筛选状态。
            },
            deadlineBefore: ""
        };

        function normalize(str) {
            return (str || "").toString().trim().toLowerCase();
        }

        function buildSearchHay(row) {
            const visibleCols = [];
            // 搜索前 6 列的可见文本内容。
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
            if (!q) return true;
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
                if (key === "deadline") {
                    mark.textContent = state.deadlineBefore ? "*" : "";
                } else {
                    mark.textContent = state.columnFilters[key] ? "*" : "";
                }
            });
        }

        function applyFilters() {
            const q = normalize(state.textQuery);
            const today = todayStart();
            const beforeTime = parseYmdDate(state.deadlineBefore);

            rows.forEach(row => {
                const searchHay = buildSearchHay(row);
                const courseVal = normalize(row.getAttribute("data-course"));
                const typeVal = normalize(row.getAttribute("data-type"));
                const locationVal = normalize(row.getAttribute("data-location"));
                const positionVal = normalize(row.getAttribute("data-position"));
                // 获取 Creator 和 Deadline 的筛选值。
                const creatorVal = normalize(row.getAttribute("data-creator"));
                const deadlineVal = (row.getAttribute("data-deadline") || "").trim();
                const deadlineTime = parseYmdDate(deadlineVal);

                let visible = true;

                if (!matchesSearch(searchHay, q)) visible = false;
                if (visible && state.onlyNotExpired) visible = deadlineTime !== null && deadlineTime >= today;
                if (visible && state.columnFilters.course && courseVal !== state.columnFilters.course) visible = false;
                if (visible && state.columnFilters.type && typeVal !== state.columnFilters.type) visible = false;
                if (visible && state.columnFilters.location && locationVal !== state.columnFilters.location) visible = false;
                if (visible && state.columnFilters.position && positionVal !== state.columnFilters.position) visible = false;
                if (visible && state.columnFilters.creator && creatorVal !== state.columnFilters.creator) visible = false;
                if (visible && beforeTime !== null) visible = deadlineTime !== null && deadlineTime <= beforeTime;

                row.style.display = visible ? "" : "none";
            });

            refreshHeaderMarks();
            btnNotExpired.classList.toggle("active", state.onlyNotExpired);
        }

        function closePopup() {
            filterPopup.style.display = "none";
            filterPopup.innerHTML = "";
        }

        function placePopupNear(th) {
            const rect = th.getBoundingClientRect();
            filterPopup.style.top = (rect.bottom + 6) + "px";
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
            // 映射各筛选列在表格中的列索引。
            const colIndex = {
                creator: 0,
                course: 1,
                type: 2,
                location: 3,
                position: 5
            }[key];
            const values = getUniqueValues(key, colIndex);

            let html = '<div class="filter-title">Filter ' + th.textContent.trim() + '</div>';
            html += '<button class="filter-option ' + (!state.columnFilters[key] ? 'active' : '') + '" data-val="">All</button>';
            values.forEach(([val, label]) => {
                const active = state.columnFilters[key] === val ? 'active' : '';
                html += '<button class="filter-option ' + active + '" data-val="' + val.replace(/"/g, '&quot;') + '">' + label + '</button>';
            });

            filterPopup.innerHTML = html;
            placePopupNear(th);

            filterPopup.querySelectorAll(".filter-option").forEach(btn => {
                btn.addEventListener("click", () => {
                    state.columnFilters[key] = normalize(btn.getAttribute("data-val"));
                    closePopup();
                    applyFilters();
                });
            });
        }

        function openDeadlineFilter(th) {
            const safeVal = state.deadlineBefore || "";
            filterPopup.innerHTML = '' +
                '<div class="filter-title">Deadline Filter</div>' +
                '<div class="deadline-box">' +
                '  <input type="date" id="deadlineFilterInput" value="' + safeVal + '">' +
                '  <div class="hint">Show jobs with deadline on or before selected date.</div>' +
                '  <div class="deadline-actions">' +
                '    <button type="button" class="primary" id="deadlineApplyBtn">Apply</button>' +
                '    <button type="button" id="deadlineClearBtn">Clear</button>' +
                '  </div>' +
                '</div>';

            placePopupNear(th);

            const input = document.getElementById("deadlineFilterInput");
            document.getElementById("deadlineApplyBtn").addEventListener("click", () => {
                state.deadlineBefore = (input.value || "").trim();
                closePopup();
                applyFilters();
            });
            document.getElementById("deadlineClearBtn").addEventListener("click", () => {
                state.deadlineBefore = "";
                closePopup();
                applyFilters();
            });
        }

        function runSearch() {
            state.textQuery = searchInput.value || "";
            applyFilters();
        }

        searchInput.addEventListener("input", runSearch);
        btnSearch.addEventListener("click", runSearch);
        searchInput.addEventListener("keydown", (e) => {
            if (e.key === "Enter") {
                e.preventDefault();
                runSearch();
            }
        });

        btnNotExpired.addEventListener("click", () => {
            state.onlyNotExpired = !state.onlyNotExpired;
            applyFilters();
        });

        btnClearAll.addEventListener("click", () => {
            state.textQuery = "";
            state.onlyNotExpired = false;
            state.columnFilters.course = "";
            state.columnFilters.type = "";
            state.columnFilters.location = "";
            state.columnFilters.position = "";
            state.columnFilters.creator = "";
            state.deadlineBefore = "";
            searchInput.value = "";
            closePopup();
            applyFilters();
        });

        headers.forEach(th => {
            th.addEventListener("click", (e) => {
                e.stopPropagation();
                const key = th.dataset.key;
                if (!key) return;
                closePopup();
                if (key === "deadline") openDeadlineFilter(th);
                else openValueFilter(th);
            });
        });

        document.addEventListener("click", (e) => {
            if (filterPopup.style.display !== "block") return;
            if (!filterPopup.contains(e.target)) closePopup();
        });

        applyFilters();
    })();
</script>
</body>
</html>
