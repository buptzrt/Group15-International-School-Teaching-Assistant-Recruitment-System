package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import com.me.finaldesignproject.model.Job; // 确保导入了 Job 模型

public class ApplicationDao {
    // �?统一源码路径，确保全项目同步
    private static final String FILE_PATH = "E:\\study\\software engineer\\newdebug\\newdebug\\TA_System\\src\\main\\resources\\applications.json";

    public static String getFilePath() {
        return FILE_PATH;
    }

    /**
     * 学生端：保存新申请
     */
    public boolean saveApplication(String studentId, String jobId) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
            String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            // 默认状态为 Pending
            String jsonEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + currentTime + "\", \"status\":\"Pending\"}";

            synchronized (this) {
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
                    if (file.length() > 0) bw.newLine();
                    bw.write(jsonEntry);
                    return true;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * MO端：更新申请状态 (Pass/Reject)
     */
    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus) {
        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        System.out.println("\n====== [ApplicationDao] 准备更新申请状态 ======");
        System.out.println(">>> 目标学生: " + studentId + ", 目标职位: " + jobId + ", 新状态: " + newStatus);

        List<String> fileContent = new ArrayList<>();
        boolean found = false;
        boolean alreadyUpdated = false;

        synchronized (this) {
            try {
                // 1. 读取文件
                try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        // 只要精准匹配到了学号和职位ID
                        if (line.contains("\"studentId\":\"" + studentId + "\"") && line.contains("\"jobId\":\"" + jobId + "\"")) {

                            // 防御性拦截：如果已经是这个状态了，千万别再改了（防止重复扣除名额）
                            if (line.contains("\"status\":\"" + newStatus + "\"")) {
                                System.out.println(">>> 拦截：该申请已经是 [" + newStatus + "] 状态，无需重复修改！");
                                alreadyUpdated = true;
                                found = true;
                            } else {
                                // 🌟 终极必杀技：提取旧日期，彻底粉碎并重新拼接标准的 JSON 字符串！
                                String dateVal = "";
                                if (line.contains("\"date\":\"")) {
                                    dateVal = line.split("\"date\":\"")[1].split("\"")[0];
                                }
                                line = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + dateVal + "\", \"status\":\"" + newStatus + "\"}";
                                found = true;
                                System.out.println(">>> 成功生成全新数据行: " + line);
                            }
                        }
                        fileContent.add(line);
                    }
                }

                if (!found) {
                    System.out.println(">>> 失败：未找到对应的申请记录！");
                    return false;
                }

                // 如果是重复点击，返回 false 让外层的 Servlet 停止扣减库存
                if (alreadyUpdated) return false;

                // 2. 写回文件
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
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
