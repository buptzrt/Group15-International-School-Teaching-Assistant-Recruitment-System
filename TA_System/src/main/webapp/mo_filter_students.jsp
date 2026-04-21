<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.me.finaldesignproject.dao.JobDao" %>
<%@ page import="com.me.finaldesignproject.model.Job" %>
<%
    // 权限校验
    String currentUserId = (String) session.getAttribute("userId");
    if (session == null || currentUserId == null || !"MO".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 获取当前 MO 发布的岗位，用于下拉列表
    List<Job> myJobs = new ArrayList<>();
    List<Job> allJobs = new JobDao().getAllJobs();
    if (allJobs != null) {
        for (Job j : allJobs) {
            // 根据 CreatorId 过滤自己的岗位
            if (currentUserId.equals(j.getCreatorId()) || currentUserId.equals(j.getCreatorName())) {
                myJobs.add(j);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AI Skill Matcher</title>
    <style>
        /* 🌟 简历双屏对比 Modal 样式 */
        .modal-overlay {
            display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.7);
            z-index: 1000; backdrop-filter: blur(5px); justify-content: center; align-items: center;
        }
        .modal-content {
            width: 90%; max-width: 1200px; height: 85vh; background: #1a2a40;
            border-radius: 16px; border: 1px solid rgba(255,255,255,0.2);
            display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 25px 50px rgba(0,0,0,0.5);
        }
        .modal-header {
            padding: 15px 25px; background: rgba(0,0,0,0.2); border-bottom: 1px solid rgba(255,255,255,0.1);
            display: flex; justify-content: space-between; align-items: center;
        }
        .modal-title { color: #ffd166; font-size: 20px; font-weight: bold; margin: 0; }
        .close-btn { background: none; border: none; color: #fff; font-size: 28px; cursor: pointer; line-height: 1; }
        .close-btn:hover { color: #e74c3c; }

        .modal-body {
            display: flex; flex: 1; overflow: hidden;
        }
        .modal-left-ai {
            width: 40%; padding: 25px; border-right: 1px solid rgba(255,255,255,0.1);
            overflow-y: auto; background: rgba(255,255,255,0.02);
        }
        .modal-right-pdf {
            width: 60%; background: #fff; /* PDF背景一般是白的 */
        }
        iframe.pdf-viewer {
            width: 100%; height: 100%; border: none;
        }

        /* 评语特殊排版 */
        .ai-reason-text { font-size: 16px; line-height: 1.8; color: #f5f9ff; white-space: pre-line; }
        .action-btn { background: #1e90ff; color: #fff; padding: 6px 12px; border-radius: 6px; border: none; cursor: pointer; }
        .action-btn:hover { background: #187bcd; }
        /* 针对 AI 理由单元格的特殊样式，让 \n 变成真正的换行 */
        .reason-cell {
            font-size: 14.5px;
            line-height: 1.7;
            white-space: pre-line; /* 🌟 核心魔法：识别换行符 */
            color: #e2e8f0;
            padding-top: 16px !important;
            padding-bottom: 16px !important;
        }

        /* 🌟 滚动条美化 */
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.25); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.45); }

        body {
            margin: 0; padding: 36px 18px;
            font-family: "Segoe UI", "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
            background-image: url("${pageContext.request.contextPath}/images/bupt_campus_bg.jpg");
            background-size: cover; background-position: center; background-attachment: fixed;
            color: #f4f7fb; min-height: 100vh; position: relative;
        }

        body::before {
            content: ""; position: fixed; inset: 0;
            background: rgba(18, 35, 61, 0.78); z-index: -1;
        }

        .page-container { max-width: 1100px; margin: 0 auto; }

        .panel {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-radius: 18px; padding: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
            backdrop-filter: blur(10px);
        }

        h2 { margin: 0 0 20px; color: #ffd166; font-size: 30px; font-weight: 700; display: flex; align-items: center; gap: 10px; }
        .ai-badge { background: linear-gradient(135deg, #1e90ff, #9bd3ff); color: #fff; font-size: 14px; padding: 4px 10px; border-radius: 8px; font-weight: bold; }

        .toolbar {
            margin-bottom: 25px; display: flex; gap: 12px; align-items: center; flex-wrap: wrap;
            background: rgba(0,0,0,0.15); padding: 20px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1);
        }

        .job-select {
            flex: 1; min-width: 300px; padding: 12px 15px; border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.28); background: rgba(25, 40, 65, 0.9); color: #fff; font-size: 16px; outline: none; cursor: pointer;
        }
        .job-select:focus { border-color: #9bd3ff; box-shadow: 0 0 0 3px rgba(155, 211, 255, 0.22); }

        .btn-run-ai {
            background: #18b394; border: 1px solid #18b394; color: #fff; border-radius: 10px; padding: 12px 24px; cursor: pointer; font-size: 16px; font-weight: bold; transition: 0.3s;
        }
        .btn-run-ai:hover { background: #159e82; box-shadow: 0 4px 15px rgba(24,179,148,0.4); transform: translateY(-2px); }
        .btn-run-ai:disabled { background: #555; border-color: #555; cursor: not-allowed; transform: none; box-shadow: none; }

        .table-wrap { overflow-x: auto; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.18); position: relative; display: none; }

        table { width: 100%; border-collapse: collapse; min-width: 900px; background: rgba(255, 255, 255, 0.05); }
        thead th { text-align: left; color: #ffd166; font-weight: 700; font-size: 15px; padding: 14px; background: rgba(0, 0, 0, 0.2); border-bottom: 1px solid rgba(255, 255, 255, 0.2); }
        tbody td { padding: 14px; border-bottom: 1px solid rgba(255, 255, 255, 0.12); color: #f5f9ff; font-size: 15px; line-height: 1.6; vertical-align: top; }
        tbody tr:hover { background: rgba(255, 255, 255, 0.08); }

        .score-box { display: inline-block; padding: 6px 12px; border-radius: 8px; font-weight: bold; font-size: 18px; text-align: center; min-width: 60px; }
        .score-high { background: rgba(46, 204, 113, 0.2); color: #2ecc71; border: 1px solid #2ecc71; }
        .score-mid { background: rgba(243, 156, 18, 0.2); color: #f39c12; border: 1px solid #f39c12; }
        .score-low { background: rgba(231, 76, 60, 0.2); color: #e74c3c; border: 1px solid #e74c3c; }

        /* Loading 动画特效 */
        .loading-container { display: none; text-align: center; padding: 50px 20px; }
        .loader { border: 4px solid rgba(255,255,255,0.1); border-top: 4px solid #9bd3ff; border-radius: 50%; width: 50px; height: 50px; animation: spin 1s linear infinite; margin: 0 auto 15px auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .loading-text { color: #9bd3ff; font-size: 18px; font-weight: bold; margin-bottom: 8px; animation: pulse 1.5s infinite; }
        .loading-subtext { color: #ffd166; font-size: 14px; }
        @keyframes pulse { 0% { opacity: 0.6; } 50% { opacity: 1; } 100% { opacity: 0.6; } }
    </style>
</head>
<body>
<div class="page-container">
    <div class="panel">
        <h2>AI Candidate Matcher <span class="ai-badge">Powered by Qwen</span></h2>

        <div class="toolbar">
            <select id="jobSelector" class="job-select">
                <option value="">-- Please Select a Posted Vacancy --</option>
                <% for(Job j : myJobs) { %>
                <option value="<%= j.getJobId() %>"><%= j.getCourseName() %> - <%= j.getJobTitle() %></option>
                <% } %>
            </select>
            <button id="runBtn" class="btn-run-ai" onclick="runAiMatch()">🚀 Run AI Match</button>
        </div>

        <div id="loadingArea" class="loading-container">
            <div class="loader"></div>
            <div class="loading-text">🤖 In the in-depth analysis of the resume...</div>
            <div class="loading-subtext">It is estimated to take 15 - 30 seconds. Please be patient and do not refresh the page.</div>
        </div>

        <div id="tableWrapper" class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th style="width: 12%">Candidate Name</th>
                    <th style="width: 12%">Student ID</th>
                    <th style="width: 18%">Major</th>
                    <th style="width: 12%">Match Score</th>
                    <th style="width: 46%">AI Evaluation Reason</th>
                </tr>
                </thead>
                <tbody id="resultBody">
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    let currentAiData = []; // 声明一个全局变量保存结果，方便 Modal 随时读取
    function runAiMatch() {
        const jobId = document.getElementById('jobSelector').value;
        if(!jobId) {
            alert('Please select a job vacancy first!');
            return;
        }

        const runBtn = document.getElementById('runBtn');
        const loadingArea = document.getElementById('loadingArea');
        const tableWrapper = document.getElementById('tableWrapper');
        const tbody = document.getElementById('resultBody');

        // UI 切换到加载状态
        runBtn.disabled = true;
        runBtn.innerText = "Processing...";
        tableWrapper.style.display = 'none';
        loadingArea.style.display = 'block';
        tbody.innerHTML = '';

        // 🌟 设置前端请求超时保护 (60秒)
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 60000);

        fetch('api/ai-match?jobId=' + jobId, { method: 'POST', signal: controller.signal })
            .then(response => response.json())
            .then(data => {
                currentAiData = data; // 🌟 存入全局变量
                if (data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">No applicants found.</td></tr>';
                } else {
                    data.sort((a, b) => b.score - a.score);
                    data.forEach((item, index) => {
                        let scoreClass = 'score-low';
                        if (item.score >= 80) scoreClass = 'score-high';
                        else if (item.score >= 60) scoreClass = 'score-mid';

                        // 增加一列：View Resume 按钮，传入数组索引 index
                        const row = '<tr>' +
                            '<td><strong>' + (item.name || 'Unknown') + '</strong></td>' +
                            '<td style="color: #9bd3ff;">' + item.studentId + '</td>' +
                            '<td style="font-size:14px;">' + (item.major || 'Unknown') + '</td>' +
                            '<td><div class="score-box ' + scoreClass + '">' + item.score + '</div></td>' +
                            '<td class="reason-cell">' + item.reason + '</td>' +
                            '<td><button class="action-btn" onclick="openModal(' + index + ')">👁️ View</button></td>' +
                            '</tr>';
                        tbody.innerHTML += row;
                    });
                }
                loadingArea.style.display = 'none';
                tableWrapper.style.display = 'block';
            })
            .catch(err => {
                clearTimeout(timeoutId);
                console.error(err);

                // 判断是超时还是其他错误
                if (err.name === 'AbortError') {
                    alert('⚠️ Request timeout! The number of applicant resumes is too large or the AI response is too slow. Please try again later.');
                } else {
                    alert('⚠️ AI analysis failed. Please check the console logs. Possible reasons: API Key not configured or network issue.');
                }
                loadingArea.style.display = 'none';
            })
            .finally(() => {
                // 恢复按钮状态
                runBtn.disabled = false;
                runBtn.innerText = "🚀 Run AI Match";
            });
    }
    function openModal(index) {
        const item = currentAiData[index];
        document.getElementById('modalTitle').innerText = item.name + ' (' + item.studentId + ') - AI Analysis';

        // 设置分数样式
        const scoreDiv = document.getElementById('modalScore');
        scoreDiv.innerText = item.score;
        scoreDiv.className = 'score-box ' + (item.score >= 80 ? 'score-high' : (item.score >= 60 ? 'score-mid' : 'score-low'));

        // 设置理由
        document.getElementById('modalReason').innerText = item.reason;

        // 加载 PDF (如果是空路径，给个提示)
        const iframe = document.getElementById('pdfIframe');
        if (item.resumePath) {
            iframe.src = item.resumePath;
        } else {
            iframe.srcdoc = "<div style='display:flex;height:100%;align-items:center;justify-content:center;font-family:sans-serif;color:#666;'>No PDF resume uploaded by this candidate.</div>";
        }

        document.getElementById('resumeModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('resumeModal').style.display = 'none';
        document.getElementById('pdfIframe').src = ""; // 清空，防止下次打开串场
    }
</script>
<div id="resumeModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle" class="modal-title">Candidate Analysis</h3>
            <button class="close-btn" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="modal-left-ai">
                <div style="margin-bottom: 20px;">
                    <span style="color: #9bd3ff; font-size: 14px;">AI Match Score</span>
                    <div id="modalScore" class="score-box" style="font-size: 24px; padding: 10px 20px; display: inline-block; margin-top: 5px;"></div>
                </div>
                <h4 style="color: #ffd166; margin-bottom: 10px; font-size: 18px;">Detailed Evaluation</h4>
                <div id="modalReason" class="ai-reason-text"></div>
            </div>
            <div class="modal-right-pdf">
                <iframe id="pdfIframe" class="pdf-viewer"></iframe>
            </div>
        </div>
    </div>
</div>
</body>
</html>
