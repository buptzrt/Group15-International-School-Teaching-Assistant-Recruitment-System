<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="com.me.finaldesignproject.dao.ApplicationDao" %>
<%
    // 权限校验：只要登录即可查看（TA/Student 角色）
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    // 数据来源：从 StudentJobServlet 传递过来的 jobList 中获取
    List<Job> allJobs = (List<Job>) request.getAttribute("jobList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Job List</title>
    <style>
        /* 核心修改：将子页面 body 设为透明，以便透出 Home 页的背景图和 0.85 蒙层 */
        body {
            margin: 0;
            padding: 36px 18px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
            /* 关键点：这里必须透明，否则会挡住父页面的校园背景图 */
            background: transparent !important;
            color: #222;
            min-height: 100vh;
            position: relative;
        }

        /* 关键点：移除子页面自己的蒙层，防止颜色叠加导致变死白 */
        body::before {
            display: none;
        }

        .page-container {
            max-width: 1060px;
            margin: 0 auto;
        }

        .panel {
            /* 保持 0.5 透明度白色，形成磨砂玻璃感 */
            background: rgba(255, 255, 255, 0.5);
            border: 1px solid rgba(0, 0, 0, 0.1);
            border-radius: 18px;
            padding: 22px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }

        h2 {
            margin: 0 0 14px;
            color: #2c3e50;
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
            border: 1px solid rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 0.8);
            color: #333;
            font-size: 15px;
        }

        .search-input::placeholder {
            color: #7f8c8d;
        }

        .search-input:focus {
            outline: none;
            border-color: #1e90ff;
            box-shadow: 0 0 0 3px rgba(30, 144, 255, 0.1);
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
            border: 1px solid rgba(0, 0, 0, 0.1);
            background: #2c3e50;
            color: #fff;
            border-radius: 10px;
            padding: 9px 12px;
            cursor: pointer;
            font-size: 18px;
            line-height: 1;
            min-width: 44px;
        }

        .search-btn:hover {
            background: #1a252f;
        }

        .hint {
            color: #555;
            font-size: 13px;
        }

        .top-filter-btn {
            border: 1px solid rgba(0, 0, 0, 0.1);
            background: rgba(255, 255, 255, 0.8);
            color: #2c3e50;
            border-radius: 999px;
            padding: 9px 16px;
            cursor: pointer;
            font-size: 14px;
        }

        .top-filter-btn.active {
            background: #18b394;
            border-color: #18b394;
            color: #fff;
        }

        .table-wrap {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid rgba(0, 0, 0, 0.1);
            position: relative;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
            background: rgba(255, 255, 255, 0.3);
        }

        thead th {
            text-align: left;
            color: #2c3e50;
            font-weight: 700;
            font-size: 15px;
            padding: 12px 14px;
            background: rgba(0, 0, 0, 0.05);
            border-bottom: 1px solid rgba(0, 0, 0, 0.08);
            cursor: pointer;
            user-select: none;
            white-space: nowrap;
            position: relative;
        }

        thead th.action-col {
            cursor: default;
        }

        .filter-mark {
            margin-left: 6px;
            font-size: 12px;
            color: #1e90ff;
        }

        tbody td {
            padding: 12px 14px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            color: #333;
            font-size: 15px;
            line-height: 1.45;
            vertical-align: middle;
        }

        tbody tr:hover {
            background: rgba(255, 255, 255, 0.5);
        }

        .view-btn {
            display: inline-block;
            padding: 7px 12px;
            border-radius: 8px;
            color: #fff;
            background: #1e90ff;
            text-decoration: none;
            font-size: 13px;
            border: none;
        }

        .view-btn:hover {
            background: #187bcd;
        }

        .empty {
            color: #666;
            margin-top: 10px;
            font-style: italic;
        }

        /* 筛选弹窗样式 */
        .header-filter {
            position: fixed;
            z-index: 9999;
            min-width: 220px;
            max-width: 320px;
            max-height: 300px;
            overflow: auto;
            border-radius: 10px;
            border: 1px solid #ddd;
            background: #fff;
            box-shadow: 0 16px 30px rgba(0,0,0,0.15);
            padding: 10px;
            display: none;
        }

        .header-filter .filter-title {
            color: #2c3e50;
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
            border: 1px solid #eee;
            background: #f9f9f9;
            color: #333;
            cursor: pointer;
            font-size: 13px;
        }

        .filter-option.active {
            border-color: #18b394;
            background: rgba(24, 179, 148, 0.1);
            color: #18b394;
        }

        .deadline-box {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .deadline-box input[type="date"] {
            padding: 8px;
            border-radius: 8px;
            border: 1px solid #ddd;
            background: #fff;
            color: #333;
        }

        .deadline-actions {
            display: flex;
            gap: 8px;
        }

        .deadline-actions button {
            flex: 1;
            padding: 7px 8px;
            border-radius: 8px;
            border: 1px solid #ddd;
            color: #333;
            background: #f5f5f5;
            cursor: pointer;
            font-size: 13px;
        }

        .deadline-actions button.primary {
            background: #18b394;
            border-color: #18b394;
            color: #fff;
        }

        /* 新增橙色 Apply 按钮样式 */
        /* 1. 基础 Apply 按钮样式 */
        .apply-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 7px 16px; /* 稍微增加宽度，更有质感 */
            border-radius: 10px;
            color: #ffffff;
            /* 使用渐变橙色，比纯色更现代 */
            background: linear-gradient(135deg, #ff9800, #f57c00);
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            border: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            box-shadow: 0 4px 10px rgba(255, 152, 0, 0.25);
        }

        /* 2. 悬浮效果：颜色变深且阴影增强 */
        .apply-btn:hover {
            background: linear-gradient(135deg, #fb8c00, #ef6c00);
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(255, 152, 0, 0.4);
        }

        /* 3. 点击瞬间的缩放效果 */
        .apply-btn:active {
            transform: translateY(0);
            box-shadow: 0 2px 5px rgba(255, 152, 0, 0.3);
        }

        /* 4. ✅ 关键修改：点击成功后的“变灰”禁用状态 */
        .apply-btn.disabled {
            /* 使用你要求的深灰色 */
            background: #555555 !important;
            color: #999999 !important;
            cursor: not-allowed !important;
            pointer-events: none; /* 彻底禁止点击事件 */
            transform: none !important;
            box-shadow: none !important;
            opacity: 0.8;
        }
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
                    <th data-key="creator">Creator<span class="filter-mark"></span></th>
                    <th data-key="course">Course<span class="filter-mark"></span></th>
                    <th data-key="title">Title<span class="filter-mark"></span></th>
                    <th data-key="type">Type<span class="filter-mark"></span></th>
                    <th data-key="deadline">Deadline<span class="filter-mark"></span></th>
                    <th data-key="position">Position<span class="filter-mark"></span></th>
                    <th class="action-col">Action</th>
                </tr>
                </thead>

                <%
                    // ✅ 修复 500 报错的 Java 逻辑
                    String currentUserId = (String) session.getAttribute("userId");
                    Set<String> appliedJobIds = new HashSet<>();
                    if (currentUserId != null) {
                        // 直接通过 DAO 获取已申请记录，不再在 JSP 里重复写文件路径和解析代码
                        appliedJobIds = new ApplicationDao().getAppliedJobIds(currentUserId);
                    }
                %>

                <tbody>
                <% if (allJobs != null && !allJobs.isEmpty()) { %>
                <% for (Job job : allJobs) {
                    String courseName = job.getCourseName() == null ? "" : job.getCourseName();
                    String moduleCode = job.getModuleCode() == null ? "-" : job.getModuleCode();
                    String course = courseName + " (" + moduleCode + ")";
                    String title = job.getJobTitle() == null ? "-" : job.getJobTitle();
                    String type = job.getActivityType() == null ? "-" : job.getActivityType();
                    String deadline = job.getApplicationDeadline() == null ? "-" : job.getApplicationDeadline();
                    String position = String.valueOf(job.getNumberOfPositions());
                    String creatorName = (job.getCreatorName() == null || job.getCreatorName().isEmpty()) ? "Unknown" : job.getCreatorName();

                    String courseAttr = course.toLowerCase().replace("\"", "&quot;");
                    String titleAttr = title.toLowerCase().replace("\"", "&quot;");
                    String typeAttr = type.toLowerCase().replace("\"", "&quot;");
                    String deadlineAttr = deadline.replace("\"", "&quot;");
                    String positionAttr = position.replace("\"", "&quot;");
                    String creatorAttr = creatorName.toLowerCase().replace("\"", "&quot;");
                %>
                <tr data-course="<%= courseAttr %>"
                    data-title="<%= titleAttr %>"
                    data-type="<%= typeAttr %>"
                    data-deadline="<%= deadlineAttr %>"
                    data-position="<%= positionAttr %>"
                    data-creator="<%= creatorAttr %>">
                    <td><%= creatorName %></td>
                    <td><%= course %></td>
                    <td><%= title %></td>
                    <td><%= type %></td>
                    <td><%= deadline %></td>
                    <td><%= position %></td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <a class="view-btn" href="view_job.jsp?jobId=<%= job.getJobId() %>&from=StudentJobServlet">View</a>

                            <%-- ✅ 修改按钮渲染：根据 DAO 查出的结果判断是否变灰 --%>
                            <% if (appliedJobIds.contains(job.getJobId())) { %>
                            <a class="apply-btn disabled" href="javascript:void(0);">Applied</a>
                            <% } else { %>
                            <a class="apply-btn" href="javascript:void(0);"
                               onclick="confirmApply('<%= job.getJobId() %>', '<%= job.getJobTitle().replace("'", "\\'") %>', event)">Apply</a>
                            <% } %>
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

<div id="headerFilter" class="header-filter"></div>

<script>
    /**
     * 保持 confirmApply 在全局作用域，确保 onclick 能够调用
     */
    function confirmApply(jobId, jobTitle, event) {
        if (event) event.preventDefault();
        const btn = event.currentTarget;
        if (btn.classList.contains('disabled')) return;

        const msg = "Are you sure you want to apply for the position: \n[" + jobTitle + "]?";
        if (confirm(msg)) {
            fetch("ApplyJobServlet?jobId=" + jobId)
                .then(response => {
                    if (response.ok) {
                        alert("Applied successfully!");
                        // 即时反馈：变灰并锁定
                        btn.classList.add('disabled');
                        btn.innerText = "Applied";
                        btn.onclick = null;
                    } else {
                        alert("Application failed. Please check your connection.");
                    }
                })
                .catch(err => alert("Server error. Please try again later."));
        }
    }

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
                title: "",
                type: "",
                position: "",
                creator: ""
            },
            deadlineBefore: ""
        };

        function normalize(str) {
            return (str || "").toString().trim().toLowerCase();
        }

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
                const titleVal = normalize(row.getAttribute("data-title"));
                const typeVal = normalize(row.getAttribute("data-type"));
                const positionVal = normalize(row.getAttribute("data-position"));
                const creatorVal = normalize(row.getAttribute("data-creator"));
                const deadlineVal = (row.getAttribute("data-deadline") || "").trim();
                const deadlineTime = parseYmdDate(deadlineVal);

                let visible = true;

                if (!matchesSearch(searchHay, q)) visible = false;
                if (visible && state.onlyNotExpired) visible = deadlineTime !== null && deadlineTime >= today;
                if (visible && state.columnFilters.course && courseVal !== state.columnFilters.course) visible = false;
                if (visible && state.columnFilters.title && titleVal !== state.columnFilters.title) visible = false;
                if (visible && state.columnFilters.type && typeVal !== state.columnFilters.type) visible = false;
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
            const colIndex = {
                creator: 0,
                course: 1,
                title: 2,
                type: 3,
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
            state.columnFilters.title = "";
            state.columnFilters.type = "";
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