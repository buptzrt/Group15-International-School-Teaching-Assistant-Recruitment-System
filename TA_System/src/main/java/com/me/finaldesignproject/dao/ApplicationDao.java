package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import java.nio.charset.StandardCharsets;
import com.me.finaldesignproject.model.Job;

public class ApplicationDao {
    // 统一源码路径，确保全项目同步
    private static final String FILE_PATH = "D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/applications.json";

    public static String getFilePath() {
        return FILE_PATH;
    }

    /**
     * 学生端：保存新申请 (🌟 融合版：UTF-8 防乱码 + 新增 ignoreOvertime + 彻底杜绝空行)
     */
    public boolean saveApplication(String studentId, String jobId) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
            String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            // 🌟 默认增加 ignoreOvertime 字段，初始为 false
            String jsonEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + currentTime + "\", \"status\":\"Pending\", \"ignoreOvertime\":\"false\"}";

            synchronized (this) {
                // 1. 先读取并清洗现有数据 (解决报错：重新加上 validLines 的声明和读取逻辑)
                List<String> validLines = new ArrayList<>();
                try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
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

                // 3. 统一重写文件，精准控制换行 (使用 UTF-8 编码)
                try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
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
     * MO端：更新申请状态及忽略超标标志 (🌟 融合版：附带清洗功能)
     */
    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus, String ignoreOvertime) {
        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        System.out.println("\n====== [ApplicationDao] 准备更新申请状态 ======");
        System.out.println(">>> 目标学生: " + studentId + ", 目标职位: " + jobId + ", 新状态: " + newStatus + ", 忽略超标: " + ignoreOvertime);

        List<String> fileContent = new ArrayList<>();
        boolean found = false;

        synchronized (this) {
            try {
                // 1. 读取并清洗文件
                try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        // 🌟 源头防爆盾：抛弃一切空行和非 JSON 行！
                        if (line.isEmpty() || !line.startsWith("{")) continue;

                        if (line.contains("\"studentId\":\"" + studentId + "\"") && line.contains("\"jobId\":\"" + jobId + "\"")) {
                            String dateVal = "";
                            if (line.contains("\"date\":\"")) {
                                dateVal = line.split("\"date\":\"")[1].split("\"")[0];
                            }

                            String finalIgnore = ignoreOvertime;
                            if (finalIgnore == null || finalIgnore.isEmpty()) {
                                if (line.contains("\"ignoreOvertime\":\"true\"")) {
                                    finalIgnore = "true";
                                } else {
                                    finalIgnore = "false";
                                }
                            }

                            line = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + dateVal + "\", \"status\":\"" + newStatus + "\", \"ignoreOvertime\":\"" + finalIgnore + "\"}";
                            found = true;
                            System.out.println(">>> 成功生成全新数据行: " + line);
                        }
                        fileContent.add(line);
                    }
                }

                if (!found) {
                    System.out.println(">>> 失败：未找到对应的申请记录！");
                    return false;
                }

                // 2. 干净利落地写回文件
                try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
                    for (int i = 0; i < fileContent.size(); i++) {
                        bw.write(fileContent.get(i));
                        if (i < fileContent.size() - 1) bw.newLine();
                    }
                }
                System.out.println("====== [ApplicationDao] 文件写入成功！======\n");
                return true;
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
    }

    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus) {
        return updateApplicationStatus(studentId, jobId, newStatus, null);
    }

    /**
     * 获取学生已申请的 ID 集合
     */
    public Set<String> getAppliedJobIds(String studentId) {
        Set<String> appliedIds = new HashSet<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return appliedIds;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
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

    /**
     * 🌟 核心配合方法：计算该学生已申请岗位（所有状态）的总累积工时
     * 用于学生端申请岗位时的超过 20h 弹窗警告
     */
    public int getAppliedTotalHours(String studentId) {
        int totalHours = 0;
        if (studentId == null) return 0;

        Set<String> appliedJobIds = getAppliedJobIds(studentId);
        if (appliedJobIds.isEmpty()) return 0;

        JobDao jobDao = new JobDao();
        List<Job> allJobs = jobDao.getAllJobs();

        for (String jId : appliedJobIds) {
            for (Job job : allJobs) {
                if (job.getJobId() != null && job.getJobId().equals(jId)) {
                    String hoursStr = job.getWorkingHours();
                    if (hoursStr != null && !hoursStr.trim().isEmpty()) {
                        String cleanHours = hoursStr.replaceAll("[^0-9]", "");
                        if (!cleanHours.isEmpty()) {
                            totalHours += Integer.parseInt(cleanHours);
                        }
                    }
                    break;
                }
            }
        }
        System.out.println("[DEBUG] Student [" + studentId + "] total APPLIED hours: " + totalHours);
        return totalHours;
    }

    /**
     * 计算特定学生申请的职位总条数
     */
    public int getTotalApplicationCount(String studentId) {
        int count = 0;
        if (studentId == null) return 0;

        File file = new File(FILE_PATH);
        if (!file.exists() || !file.isFile()) return 0;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            String searchPattern = "\"studentId\":\"" + studentId + "\"";
            while ((line = br.readLine()) != null) {
                if (line.replace(" ", "").contains(searchPattern.replace(" ", ""))) {
                    count++;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }

    public boolean hasApplicationsForJob(String jobId) {
        if (jobId == null || jobId.trim().isEmpty()) return false;
        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.contains("\"jobId\":\"" + jobId + "\"")) return true;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    private List<String> getAllApplicationLines() {
        List<String> lines = new ArrayList<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return lines;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().startsWith("{")) lines.add(line);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lines;
    }

    /**
     * 计算特定学生的总工作时长 (仅统计 Accepted 状态)
     * 用于 MO 审批界面显示该学生的实际负载
     */
    public int getTotalWorkingHours(String studentId, String statusFilter) {
        int totalHours = 0;
        if (studentId == null || statusFilter == null) return 0;

        List<String> lines = getAllApplicationLines();
        JobDao jobDao = new JobDao();
        List<com.me.finaldesignproject.model.Job> allJobs = jobDao.getAllJobs();

        for (String line : lines) {
            String searchId = "\"studentId\":\"" + studentId + "\"";
            String searchStatus = "\"status\":\"" + statusFilter + "\"";

            if (line.replace(" ", "").contains(searchId.replace(" ", "")) &&
                    line.replace(" ", "").contains(searchStatus.replace(" ", ""))) {

                try {
                    String jId = line.split("\"jobId\":\"")[1].split("\"")[0];
                    for (com.me.finaldesignproject.model.Job job : allJobs) {
                        if (job.getJobId() != null && job.getJobId().equals(jId)) {
                            String hoursStr = job.getWorkingHours();
                            if (hoursStr != null && !hoursStr.trim().isEmpty()) {
                                String cleanHours = hoursStr.replaceAll("[^0-9]", "");
                                if (!cleanHours.isEmpty()) {
                                    totalHours += Integer.parseInt(cleanHours);
                                }
                            }
                            break;
                        }
                    }
                } catch (Exception e) {}
            }
        }
        return totalHours;
    }
}
