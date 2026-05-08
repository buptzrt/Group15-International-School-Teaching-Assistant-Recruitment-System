<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%@ page import="com.me.finaldesignproject.dao.ApplicationDao" %>
<%
    // Access control: logged-in students only.
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Job> allJobs = (List<Job>) request.getAttribute("jobList");
    if (allJobs != null) {
        // 默认排序：未过期职位在前，超过 Deadline 的职位放到最后；同组内按 Deadline 从早到晚排序。
        allJobs.sort(new Comparator<Job>() {
            private LocalDate parseDeadline(Job job) {
                try {
                    String deadline = job == null ? null : job.getApplicationDeadline();
                    if (deadline == null || deadline.trim().isEmpty()) {
                        return LocalDate.MAX;
                    }
                    return LocalDate.parse(deadline.trim());
                } catch (Exception ignored) {
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
        @keyframes pulse { 0% {opacity: 1;} 50% {opacity: 0.4;} 100% {opacity: 1;} }
        body { margin: 0; padding: 36px 18px; font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif; color: #eef4fb; min-height: 100vh; position: relative; overflow-y: scroll; }
        .page-container { max-width: 1060px; margin: 0 auto; }
        .panel { background: rgba(58, 84, 118, 0.74); border: 1px solid rgba(255, 255, 255, 0.14); border-radius: 24px; padding: 22px; box-shadow: 0 16px 30px rgba(0, 0, 0, 0.14); backdrop-filter: blur(12px); }
        h2 { margin: 0 0 14px; color: #ffd166; font-size: 30px; font-weight: 700; }
        .toolbar { margin-bottom: 14px; display: flex; justify-content: space-between; gap: 12px; align-items: center; flex-wrap: wrap; padding: 12px; border-radius: 18px; background: rgba(255, 255, 255, 0.04); border: 1px solid rgba(255, 255, 255, 0.14); }
        .toolbar-left { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; flex: 1; }
        .toolbar-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .search-input { width: min(520px, 100%); padding: 10px 12px; border-radius: 12px; border: none; background: rgba(255, 255, 255, 0.10); color: #eef4fb; font-size: 15px; }
        .search-input::placeholder { color: #d8e7f5; }
        .search-input:focus { outline: none; border-color: rgba(127, 208, 255, 0.72); box-shadow: 0 0 0 3px rgba(127, 208, 255, 0.1); }
        .search-wrap { display: flex; align-items: center; gap: 8px; width: min(620px, 100%); }
        .search-wrap .search-input { flex: 1; width: auto; }
        .search-btn { border: none; background: rgba(255, 255, 255, 0.10); color: #fff; border-radius: 12px; padding: 9px 12px; cursor: pointer; font-size: 18px; line-height: 1; min-width: 44px; }
        .search-btn:hover { background: rgba(31, 207, 143, 0.16); }
        .hint { color: #d8e7f5; font-size: 13px; }
        .top-filter-btn { border: none; background: rgba(255, 255, 255, 0.10); color: #eef4fb; border-radius: 999px; padding: 9px 16px; cursor: pointer; font-size: 14px; }
        .top-filter-btn.active { background: #18b394; border-color: #18b394; color: #fff; }
        .table-wrap { overflow-x: auto; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.18); position: relative; background: rgba(255, 255, 255, 0.03); }
        table { width: 100%; border-collapse: collapse; min-width: 900px; background: rgba(255, 255, 255, 0.02); table-layout: fixed; /* 濡絽鍟惃?闂備礁銇橀悞锕傤敆鐎靛憡鍋橀柕濠忓婢规劙鎮介姘殭闁活亶鍓熼弫宥呯暆閳ь剛鍒掗柨瀣枖鐎广儱鐗嗗▓浼存煕閺傝濡洪悹鎰剁磿閹奉偊宕橀…鎴濇櫖闁?*/ }
        thead th { text-align: left; color: #ffd166; font-weight: 700; font-size: 15px; padding: 14px 16px; background: rgba(47, 118, 145, 0.72); border-bottom: 1px solid rgba(255, 255, 255, 0.12); cursor: pointer; user-select: none; white-space: nowrap; position: relative; }
        thead th.action-col { cursor: default; }
        .header-caret { margin-left: 6px; font-size: 13px; font-weight: 700; color: #ffd166; }
        .filter-mark { margin-left: 6px; font-size: 12px; color: #7fd0ff; }
        tbody td { padding: 16px; border-bottom: 1px solid rgba(255, 255, 255, 0.10); color: #eef4fb; font-size: 15px; line-height: 1.45; vertical-align: middle; }

        /* 濡絽鍟惃?婵炲瓨绮岄惉鍏碱殽閸モ晙娌柡鍥╁仧绾剧睓I闁荤姳鐒﹀畷姗€顢?*/
        .job-row { cursor: pointer; transition: background-color 0.2s ease; }
        .job-row:hover { background-color: rgba(255, 255, 255, 0.07) !important; }
        .job-row.overdue-job-row td {
            color: rgba(238, 244, 251, 0.52) !important;
            background: rgba(120, 130, 142, 0.16) !important;
            filter: grayscale(0.55);
        }
        .job-row.overdue-job-row + .expand-row td {
            color: rgba(238, 244, 251, 0.58) !important;
            background: rgba(120, 130, 142, 0.12) !important;
            filter: grayscale(0.45);
        }
        .expand-row { display: none; background-color: rgba(255,255,255,0.03); border-bottom: 1px solid rgba(255,255,255,0.06); }
        .expand-row.open { display: table-row; }
        .expand-content { padding: 20px 24px; color: #dce8f5; display: flex; flex-direction: column; gap: 12px; border-left: 3px solid rgba(127,208,255,0.52); }
        .expand-title { font-weight: 700; color: #eef4fb; font-size: 15px; display: block; margin-bottom: 4px; }
        .responsibilities-text { font-size: 14px; line-height: 1.6; background: rgba(255,255,255,0.03); padding: 12px 16px; border-radius: 10px; border: none; }

        .view-btn { display: inline-block; padding: 7px 12px; border-radius: 8px; color: #fff; background: #1e90ff; text-decoration: none; font-size: 13px; border: none; }
        .view-btn:hover { background: #187bcd; }
        .view-btn.closed, .view-btn.overdue { background: #95a5a6; cursor: not-allowed; pointer-events: none; }
        .apply-btn { display: inline-flex; align-items: center; justify-content: center; padding: 7px 16px; border-radius: 10px; color: #ffffff; background: linear-gradient(135deg, #ff9800, #f57c00); text-decoration: none; font-size: 13px; font-weight: 600; border: none; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer; box-shadow: 0 4px 10px rgba(255, 152, 0, 0.25); }
        .apply-btn:hover { background: linear-gradient(135deg, #fb8c00, #ef6c00); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(255, 152, 0, 0.4); }
        .apply-btn.disabled { background: #555555 !important; color: #999999 !important; cursor: not-allowed !important; pointer-events: none; transform: none !important; box-shadow: none !important; opacity: 0.8; }

        .gap-btn { background: linear-gradient(135deg, #8e44ad, #9b59b6); padding: 9px 20px; font-size: 14px; border-radius: 8px; align-self: flex-start; margin-top: 5px; }
        .gap-btn:hover { background: linear-gradient(135deg, #732d91, #8e44ad); box-shadow: 0 6px 15px rgba(142, 68, 173, 0.4); }

        .empty { color: #d8e7f5; margin-top: 10px; font-style: italic; }
        .header-filter { position: fixed; z-index: 9999; min-width: 220px; max-width: 320px; max-height: 300px; overflow: auto; border-radius: 12px; border: none; background: rgba(20,34,54,0.90); box-shadow: 0 16px 30px rgba(0,0,0,0.15); padding: 10px; display: none; }
        .header-filter .filter-title { color: #eef4fb; font-weight: 700; margin-bottom: 8px; font-size: 14px; }
        .filter-option { width: 100%; text-align: left; margin-bottom: 6px; padding: 7px 9px; border-radius: 10px; border: none; background: rgba(255,255,255,0.06); color: #eef4fb; cursor: pointer; font-size: 13px; }
        .filter-option.active { border-color: rgba(31,207,143,0.42); background: rgba(24, 179, 148, 0.1); color: #cffff1; }

        /* 濡絽鍟惃?Gap Report Modal 闂佸搫绉撮崲鑼?*/
        #gapModal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 10000; justify-content: center; align-items: center; opacity: 0; transition: opacity 0.3s ease; }
        #gapModalContent { background: #fff; width: 650px; max-width: 90%; border-radius: 16px; padding: 30px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); transform: translateY(20px); transition: transform 0.3s ease; display: flex; flex-direction: column; }
        #gapModalTitle { margin-top: 0; color: #2c3e50; font-size: 22px; border-bottom: 2px solid #f0f2f5; padding-bottom: 15px; margin-bottom: 15px; }
        #gapModalBody { font-size: 15px; line-height: 1.8; color: #444; max-height: 60vh; overflow-y: auto; padding-right: 10px; }
        #gapModalBody::-webkit-scrollbar { width: 6px; }
        #gapModalBody::-webkit-scrollbar-thumb { background: #ccc; border-radius: 4px; }
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
                    <th style="width: 14%;" data-key="type" data-label="Type">Type<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 16%;" data-key="location" data-label="Location">Location<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 12%;" data-key="deadline" data-label="Deadline">Deadline<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 9%;" data-key="position" data-label="Position">Position<span class="header-caret">&#9662;</span><span class="filter-mark"></span></th>
                    <th style="width: 10%; text-align: center;">AI Match</th>
                    <th style="width: 22%;" class="action-col">Action</th>
                </tr>
                </thead>

                <%
                    // 濡絽鍟惃?闂佸吋鍎抽崲鑼躲亹閸パ屽晠闁肩⒈鍓氶弳銈夋偣閸パ冩Щ闁活厽鐗楅幏鍛吋閸ャ劎鏆犻梺璇″墲椤曆勫閹版澘绫嶉柛鎾茶兌閺屽牏绱?(闂佸憡鑹鹃懟顖烆敆閻旂厧绠甸柟閭︿簽鏉╂棃鏌ｉ妸銉ヮ仼濠殿喗鐩幊?
                    String currentUserId = (String) session.getAttribute("userId");
                    Set<String> appliedJobIds = new HashSet<>();
                    int totalAppliedHours = 0;
                    if (currentUserId != null) {
                        ApplicationDao appDao = new ApplicationDao();
                        appliedJobIds = appDao.getAppliedJobIds(currentUserId);
                        // 缂備線纭搁崹鐗堟叏閻愬樊鍟呴柤纰卞墯閺嗐倝鎮归崶顒夋婵炲牊鍨块獮宥夊焵椤掑嫬瀚夊璺猴功閻撴劕霉閿濆懐肖婵炲牊鍨垮顕€宕奸弴鐔哥槪
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
                        String type = job.getActivityType() == null ? "-" : job.getActivityType();
                        String location = job.getLocation() == null ? "-" : job.getLocation();
                        String deadline = job.getApplicationDeadline() == null ? "-" : job.getApplicationDeadline();
                        int positionsLeft = job.getNumberOfPositions();
                        String creatorName = (job.getCreatorName() == null || job.getCreatorName().isEmpty()) ? "Unknown" : job.getCreatorName();

                        // 濡絽鍟惃?闁荤喐鐟辩徊楣冩倵閸婄喆浜归柟鎯у暱椤ゅ懘鏌ら崡鐐差殭缂傚秴鎳橀幆鍐礋椤愶紕鐭楅梺?(闂佸憡鑹鹃懟顖烆敆閻旂厧绠甸柟閭︿簽鏉╂棃鏌ｉ妸銉ヮ仼濠殿喗鐩幊?
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
                        String typeAttr = type.toLowerCase().replace("\"", "&quot;");
                        String locationAttr = location.toLowerCase().replace("\"", "&quot;");
                        String deadlineAttr = deadline.replace("\"", "&quot;");
                        String positionAttr = String.valueOf(positionsLeft).replace("\"", "&quot;");
                        String creatorAttr = creatorName.toLowerCase().replace("\"", "&quot;");

                        // 濡絽鍟惃?闂佸吋鍎抽崲鑼躲亹閸パ呮殕婵＄偛澧界粔鎾煠閸楃偟鐒烽柣顓燁殜閻涱噣骞嗛悧鍫偖婵?HTML (婵炶揪绲挎慨宄扳枔閹达箑绀夐柣鏃囶嚙閸?
                        String respText = job.getJobResponsibilities() == null || job.getJobResponsibilities().trim().isEmpty()
                                ? "No detailed responsibilities provided by the MO."
                                : job.getJobResponsibilities().replace("\"", "&quot;").replace("\r\n", "<br>").replace("\n", "<br>");
                %>
                <tr class="job-row <%= isOverdue ? "overdue-job-row" : "" %>" data-jobid="<%= job.getJobId() %>"
                    data-course="<%= courseAttr %>"
                    data-title="<%= titleAttr %>"
                    data-type="<%= typeAttr %>"
                    data-location="<%= locationAttr %>"
                    data-deadline="<%= deadlineAttr %>"
                    data-position="<%= positionAttr %>"
                    data-creator="<%= creatorAttr %>"
                    onclick="toggleExpand(this)">

                    <td><%= creatorName %></td>
                    <td><%= course %></td>
                    <td><%= type %></td>
                    <td><%= location %></td>
                    <td><%= deadline %></td>
                    <td><%= positionsLeft %></td>

                    <!-- Ai濠电偛澶囬埀顒€鍟垮▍娆忣熆鐠虹儤鎼愰柕鍫㈡櫕娴滃憡娼忛妸蟺顩抩ading+濠电偛鏈悷锔炬閿熺姵鍎嶉柛鏇ㄥ幖绗戦梺?-->
                    <td class="ai-score-cell" style="text-align: center; font-weight: bold;">
                        <% if (blockView) { %>
                        <span style="color: #95a5a6;">N/A</span>
                        <% } else { %>
                        <span style="color: #1e90ff; font-size: 13px; animation: pulse 1.5s infinite;">Loading...</span>
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

                            <%-- 濡絽鍟惃?闂佸搫绉堕…鍫㈢紦妤ｅ啯鎳氱€广儱鎳忛崐銈夋煟閹邦喗顏熺紒鍙樺嵆濮婂ジ骞撻幒鎴炴珨濠?(婵炶揪绲挎慨宄扳枔? + 婵炵鍋愭繛鈧柍褜鍓氱敮鎺楀箖閹惧灈鍋撳☉鍐差洭婵炲牊鍨垮顒勫级婢跺摜鐭楅梺鍝勫暢濞夋稑顕ｉ鍕瀬?(闂佸憡鑹鹃懟顖烆敆閻斿吋鍎? --%>
                            <a class="apply-btn" href="javascript:void(0);"
                               onclick="event.stopPropagation(); confirmApply('<%= job.getJobId() %>', '<%= title.replace("'", "\\'").replace("\n", " ").replace("\r", " ") %>', event, <%= totalAppliedHours %>, <%= thisJobHours %>)">Apply</a>
                            <% } %>
                        </div>
                    </td>
                </tr>

                <tr class="expand-row" id="expand-<%= job.getJobId() %>">
                    <td colspan="8" style="padding: 0;">
                        <div class="expand-content">
                            <div>
                                <span class="expand-title">Responsibilities / Requirements:</span>
                                <div class="responsibilities-text"><%= respText %></div>
                            </div>
                            <div>
                                <% if (!blockView) { %>
                                <button class="apply-btn gap-btn" type="button" onclick="showGapModal('<%= job.getJobId() %>')">
                                    闂?Review AI Gap Analysis
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
function toggleExpand(row) {
  const expandRow = row.nextElementSibling;
  if (expandRow && expandRow.classList.contains("expand-row")) {
    expandRow.classList.toggle("open");
  }
}

function showGapModal(jobId) {
  const mainRow = document.querySelector("tr.job-row[data-jobid='" + jobId + "']");
  if (!mainRow) return;

  const reason = (mainRow.getAttribute("data-aireason") || "").trim();
  const title = (mainRow.getAttribute("data-title") || "This position").trim();

  if (!reason) {
    alert("AI analysis is not available yet for this job.");
    return;
  }

  const formattedReason = reason
    .replace(/\n/g, "<br><br>")
    .replace(/(Logistics|Technical|Mentoring)\s*:/gi, function(_, label){
      return '<strong style="color:#1e90ff; font-size:16px;">' + label + ':</strong>';
    });

  document.getElementById("gapModalTitle").innerText = title + " - AI Skills Analysis";
  document.getElementById("gapModalBody").innerHTML = formattedReason;

  const modal = document.getElementById("gapModal");
  const modalContent = document.getElementById("gapModalContent");
  modal.style.display = "flex";
  void modal.offsetWidth;
  modal.style.opacity = "1";
  modalContent.style.transform = "translateY(0)";
}

function closeGapModal() {
  const modal = document.getElementById("gapModal");
  const modalContent = document.getElementById("gapModalContent");
  modal.style.opacity = "0";
  modalContent.style.transform = "translateY(20px)";
  setTimeout(function(){ modal.style.display = "none"; }, 300);
}

function confirmApply(jobId, jobTitle, event, totalAppliedHours, thisJobHours) {
  if (event) event.preventDefault();
  const btn = event.currentTarget;
  if (!btn || btn.classList.contains("disabled")) return;

  const currentTotal = parseInt(totalAppliedHours, 10) || 0;
  const adding = parseInt(thisJobHours, 10) || 0;
  const nextTotal = currentTotal + adding;

  let msg = "Are you sure you want to apply for the position:\n[" + jobTitle + "]?";
  if (nextTotal > 20) {
    msg = "WORKLOAD LIMIT WARNING!\n\n" +
      "Your current applied workload is " + currentTotal + "h.\n" +
      "Applying for this " + adding + "h job will bring your total workload to " + nextTotal + "h.\n\n" +
      "This exceeds the 20h limit. The Module Leader may reject your application. Do you still want to proceed?";
  }

  if (!confirm(msg)) return;

  btn.classList.add("disabled");
  btn.innerText = "Processing...";

  fetch("ApplyJobServlet?jobId=" + encodeURIComponent(jobId), {
    headers: { "X-Requested-With": "XMLHttpRequest" }
  })
    .then(function(response){
      if (!response.ok) throw new Error("Apply request failed");
      alert("Applied successfully!");
      btn.classList.add("disabled");
      btn.innerText = "Applied";
      btn.style.background = "#555555";
      btn.style.boxShadow = "none";
      btn.onclick = null;
    })
    .catch(function(){
      alert("Application failed. You may have already applied or the session expired.");
      btn.classList.remove("disabled");
      btn.innerText = "Apply";
    });
}

(function(){
  const table = document.getElementById("jobTable");
  if (!table) return;

  const tbody = table.querySelector("tbody");
  const rows = Array.from(tbody.querySelectorAll("tr.job-row"));
  const searchInput = document.getElementById("jobSearch");
  const btnSearch = document.getElementById("btnSearch");
  const btnClearAll = document.getElementById("btnClearAll");
  const btnNotExpired = document.getElementById("btnNotExpired");
  const filterPopup = document.getElementById("headerFilter");
  const headers = Array.from(table.querySelectorAll("thead th[data-key]"));

  const state = {
    textQuery: "",
    onlyNotExpired: false,
    columnFilters: { creator: "", course: "", type: "", location: "", position: "" },
    deadlineBefore: ""
  };

  function normalize(str){ return (str || "").toString().trim().toLowerCase(); }

  function buildSearchHay(row){
    const visibleCols = [];
    for (let i = 0; i <= 5; i++) {
      const cell = row.cells[i];
      if (cell) visibleCols.push(cell.textContent || "");
    }
    return normalize(visibleCols.join(" "));
  }

  function matchesSearch(hay, query){
    if (!query) return true;
    return query.split(/\s+/).filter(Boolean).every(function(token){ return hay.includes(token); });
  }

  function parseYmdDate(dateStr){
    const v = (dateStr || "").trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) return null;
    const t = Date.parse(v + "T00:00:00");
    return isNaN(t) ? null : t;
  }

  function todayStart(){
    const d = new Date();
    d.setHours(0,0,0,0);
    return d.getTime();
  }

  function refreshHeaderMarks(){
    headers.forEach(function(th){
      const key = th.dataset.key;
      const mark = th.querySelector(".filter-mark");
      if (!mark) return;
      mark.textContent = key === "deadline" ? (state.deadlineBefore ? "*" : "") : (state.columnFilters[key] ? "*" : "");
    });
  }

  function applyFilters(){
    const q = normalize(state.textQuery);
    const today = todayStart();
    const beforeTime = parseYmdDate(state.deadlineBefore);

    rows.forEach(function(row){
      const searchHay = buildSearchHay(row);
      const courseVal = normalize(row.getAttribute("data-course"));
      const typeVal = normalize(row.getAttribute("data-type"));
      const locationVal = normalize(row.getAttribute("data-location"));
      const positionVal = normalize(row.getAttribute("data-position"));
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

      const expandRow = document.getElementById("expand-" + row.getAttribute("data-jobid"));
      if (expandRow && !visible) expandRow.classList.remove("open");
    });

    refreshHeaderMarks();
    btnNotExpired.classList.toggle("active", state.onlyNotExpired);
  }

  function closePopup(){ filterPopup.style.display = "none"; filterPopup.innerHTML = ""; }

  function placePopupNear(th){
    const rect = th.getBoundingClientRect();
    filterPopup.style.top = (rect.bottom + window.scrollY + 6) + "px";
    filterPopup.style.left = Math.max(10, rect.left) + "px";
    filterPopup.style.display = "block";
  }

  function getUniqueValues(key, colIndex){
    const map = new Map();
    rows.forEach(function(row){
      const v = normalize(row.getAttribute("data-" + key));
      const label = (row.cells[colIndex] ? row.cells[colIndex].textContent : "").trim();
      if (v && !map.has(v)) map.set(v, label || v);
    });
    return Array.from(map.entries()).sort(function(a,b){ return a[1].localeCompare(b[1]); });
  }

  function openValueFilter(th){
    const key = th.dataset.key;
    const headerLabel = th.dataset.label || th.textContent.trim();
    const colIndex = { creator: 0, course: 1, type: 2, location: 3, position: 5 }[key];
    const values = getUniqueValues(key, colIndex);

    let html = '<div class="filter-title">Filter ' + headerLabel + '</div>';
    html += '<button class="filter-option ' + (!state.columnFilters[key] ? 'active' : '') + '" data-val="">All</button>';
    values.forEach(function(entry){
      const val = entry[0];
      const label = entry[1];
      const active = state.columnFilters[key] === val ? 'active' : '';
      html += '<button class="filter-option ' + active + '" data-val="' + val.replace(/"/g, '&quot;') + '">' + label + '</button>';
    });
    filterPopup.innerHTML = html;
    placePopupNear(th);

    filterPopup.querySelectorAll(".filter-option").forEach(function(btn){
      btn.addEventListener("click", function(){
        state.columnFilters[key] = normalize(btn.getAttribute("data-val"));
        closePopup();
        applyFilters();
      });
    });
  }

  function openDeadlineFilter(th){
    const safeVal = state.deadlineBefore || "";
    filterPopup.innerHTML = '<div class="filter-title">Deadline Filter</div><div class="deadline-box"><input type="date" id="deadlineFilterInput" value="' + safeVal + '"><div class="hint">On or before selected date.</div><div class="deadline-actions"><button type="button" class="primary" id="deadlineApplyBtn">Apply</button><button type="button" id="deadlineClearBtn">Clear</button></div></div>';
    placePopupNear(th);
    const input = document.getElementById("deadlineFilterInput");
    document.getElementById("deadlineApplyBtn").addEventListener("click", function(){
      state.deadlineBefore = (input.value || "").trim();
      closePopup();
      applyFilters();
    });
    document.getElementById("deadlineClearBtn").addEventListener("click", function(){
      state.deadlineBefore = "";
      closePopup();
      applyFilters();
    });
  }

  function runSearch(){ state.textQuery = searchInput.value || ""; applyFilters(); }

  function sortTableByAiScore(){
    const mainRows = Array.from(tbody.querySelectorAll("tr.job-row"));
    const rowPairs = mainRows.map(function(row){
      return {
        main: row,
        expand: (row.nextElementSibling && row.nextElementSibling.classList.contains("expand-row")) ? row.nextElementSibling : null,
        score: parseInt(row.getAttribute("data-aiscore"), 10) || -1
      };
    });

    rowPairs.sort(function(a,b){ return b.score - a.score; });
    rowPairs.forEach(function(pair){
      tbody.appendChild(pair.main);
      if (pair.expand) tbody.appendChild(pair.expand);
    });
  }

  async function loadAiScores(){
    const contextPath = "<%= request.getContextPath() %>";
    for (const row of rows) {
      let jobId = row.getAttribute("data-jobid");
      if (!jobId || !jobId.trim()) continue;
      jobId = jobId.trim();

      const aiCell = row.querySelector(".ai-score-cell") || row.cells[6];
      if (!aiCell || aiCell.innerText.includes("N/A")) continue;

      try {
        const url = new URL(window.location.origin + contextPath + "/GetAiScoreServlet");
        url.searchParams.append("jobId", jobId);

        const res = await fetch(url.toString(), {
          headers: { "X-Requested-With": "XMLHttpRequest" }
        });
        const text = await res.text();

        let data;
        try { data = JSON.parse(text); }
        catch (e) {
          aiCell.innerHTML = "<span style='color:#e74c3c; font-weight:bold;'>Error</span>";
          continue;
        }

        if (data.success) {
          const finalScore = Number(data.score) || 0;
          const color = finalScore >= 80 ? "#2ecc71" : (finalScore >= 60 ? "#f39c12" : "#e74c3c");
          row.setAttribute("data-aiscore", finalScore);
          row.setAttribute("data-aireason", data.reason || "");
          aiCell.innerHTML = "<span style='color: " + color + "; font-weight: bold; font-size: 16px;'>" + finalScore + "%</span>";
        } else {
          aiCell.innerHTML = "<span style='color: #e74c3c; font-size: 13px;'>" + (data.message || "Error") + "</span>";
        }
      } catch (err) {
        aiCell.innerHTML = "<span style='color: #e74c3c; font-size: 13px;'>Net Err</span>";
      }
    }

    sortTableByAiScore();
    applyFilters();
  }

  searchInput.addEventListener("input", runSearch);
  btnSearch.addEventListener("click", runSearch);
  btnNotExpired.addEventListener("click", function(){
    state.onlyNotExpired = !state.onlyNotExpired;
    applyFilters();
  });
  btnClearAll.addEventListener("click", function(){
    state.textQuery = "";
    state.onlyNotExpired = false;
    state.deadlineBefore = "";
    Object.keys(state.columnFilters).forEach(function(k){ state.columnFilters[k] = ""; });
    searchInput.value = "";
    closePopup();
    applyFilters();
  });

  headers.forEach(function(th){
    th.addEventListener("click", function(e){
      e.stopPropagation();
      const key = th.dataset.key;
      if (!key) return;
      closePopup();
      if (key === "deadline") openDeadlineFilter(th);
      else openValueFilter(th);
    });
  });

  document.addEventListener("click", function(e){
    if (filterPopup.style.display !== "block") return;
    if (!filterPopup.contains(e.target)) closePopup();
  });

  applyFilters();
  loadAiScores();
})();
</script>
</body>
</html>
