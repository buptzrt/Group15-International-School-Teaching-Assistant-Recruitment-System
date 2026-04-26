package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import com.me.finaldesignproject.model.Job; // 确保导入了 Job 模型

public class ApplicationDao {
    // �?统一源码路径，确保全项目同步
    private static final String FILE_PATH = "D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/applications.json";

    public static String getFilePath() {
        return FILE_PATH;
    }

    /**
     * 学生端：保存新申请 (🌟 已重构：先清洗后重写，彻底杜绝空行)
     */
    public boolean saveApplication(String studentId, String jobId) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
            String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            String jsonEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + currentTime + "\", \"status\":\"Pending\"}";

            synchronized (this) {
                // 1. 先读取并清洗现有数据
                List<String> validLines = new ArrayList<>();
                try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        // 🌟 源头防爆盾：不要空行，不要非 JSON 数据！
                        if (!line.isEmpty() && line.startsWith("{")) {
                            validLines.add(line);
                        }
                    }
                }

                // 2. 加入新申请的数据
                validLines.add(jsonEntry);

                // 3. 统一重写文件，精准控制换行
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) { // false 代表覆盖写入
                    for (int i = 0; i < validLines.size(); i++) {
                        bw.write(validLines.get(i));
                        // 🌟 只有当前行不是最后一行时才换行，保证文件末尾绝对干干净净！
                        if (i < validLines.size() - 1) {
                            bw.newLine();
                        }
                    }
                }
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * MO端：更新申请状态 (🌟 已重构：附带清洗功能)
     */
    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus) {
        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        List<String> fileContent = new ArrayList<>();
        boolean found = false;
        boolean alreadyUpdated = false;

        synchronized (this) {
            try {
                // 1. 读取并清洗文件
                try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        // 🌟 源头防爆盾：抛弃一切空行和非 JSON 行！
                        if (line.isEmpty() || !line.startsWith("{")) continue;

                        if (line.contains("\"studentId\":\"" + studentId + "\"") && line.contains("\"jobId\":\"" + jobId + "\"")) {
                            if (line.contains("\"status\":\"" + newStatus + "\"")) {
                                alreadyUpdated = true;
                                found = true;
                            } else {
                                String dateVal = "";
                                if (line.contains("\"date\":\"")) {
                                    dateVal = line.split("\"date\":\"")[1].split("\"")[0];
                                }
                                line = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + dateVal + "\", \"status\":\"" + newStatus + "\"}";
                                found = true;
                            }
                        }
                        fileContent.add(line);
                    }
                }

                if (!found || alreadyUpdated) return false;

                // 2. 干净利落地写回文件
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, false))) {
                    for (int i = 0; i < fileContent.size(); i++) {
                        bw.write(fileContent.get(i));
                        if (i < fileContent.size() - 1) bw.newLine();
                    }
                }
                return true;
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    /**
     * 获取学生已申请的 ID 集合
     */
    public Set<String> getAppliedJobIds(String studentId) {
        Set<String> appliedIds = new HashSet<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return appliedIds;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.contains("\"studentId\":\"" + studentId + "\"")) {
                    String jId = line.split("\"jobId\":\"")[1].split("\"")[0];
                    appliedIds.add(jId);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return appliedIds;
    }

    public boolean hasApplicationsForJob(String jobId) {
        if (jobId == null || jobId.trim().isEmpty()) return false;

        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.contains("\"jobId\":\"" + jobId + "\"")) {
                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============================================================
    // ✅ 辅助逻辑：获取所有申请的原始字符串行
    // ============================================================

    private List<String> getAllApplicationLines() {
        List<String> lines = new ArrayList<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return lines;
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().startsWith("{")) lines.add(line);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lines;
    }

    /**
     * ✅ 核心修复方法：计算特定学生的总工作时长
     * 增强点：通过正则清洗字符串，确保 "19"、"19h" 或带空格引号的工时都能被正确解析。
     */
    public int getTotalWorkingHours(String studentId, String statusFilter) {
        int totalHours = 0;
        if (studentId == null || statusFilter == null) return 0;

        List<String> lines = getAllApplicationLines();
        JobDao jobDao = new JobDao();
        List<com.me.finaldesignproject.model.Job> allJobs = jobDao.getAllJobs();

        for (String line : lines) {
            // 确保 studentId 和 status 同时匹配
            if (line.contains("\"studentId\":\"" + studentId + "\"") &&
                    line.contains("\"status\":\"" + statusFilter + "\"")) {

                try {
                    String jId = line.split("\"jobId\":\"")[1].split("\"")[0];

                    for (com.me.finaldesignproject.model.Job job : allJobs) {
                        if (job.getJobId() != null && job.getJobId().equals(jId)) {
                            String hoursStr = job.getWorkingHours();
                            if (hoursStr != null && !hoursStr.trim().isEmpty()) {
                                // 🌟 核心修复：只保留数字字符，防止 NumberFormatException
                                String cleanHours = hoursStr.replaceAll("[^0-9]", "");
                                if (!cleanHours.isEmpty()) {
                                    totalHours += Integer.parseInt(cleanHours);
                                }
                            }
                            break;
                        }
                    }
                } catch (Exception e) {
                    // 解析异常时跳过当前行
                }
            }
        }
        return totalHours;
    }
}
