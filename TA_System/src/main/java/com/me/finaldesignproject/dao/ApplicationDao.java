package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;

public class ApplicationDao {
    // �?统一源码路径，确保全项目同步
    private static final String FILE_PATH = "D:\\Group15_TA_SYSTEM-new\\Group15_TA_SYSTEM-ChenyuZhang-AD-01new\\TA_System\\src\\main\\resources\\applications.json";

    public static String getFilePath() {
        return FILE_PATH;
    }

    /**
     * 学生端：保存新申�?     */
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
     * MO端：更新申请状�?(Pass/Reject)
     */
    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus) {
        File file = new File(FILE_PATH);
        if (!file.exists()) return false;

        List<String> fileContent = new ArrayList<>();
        boolean found = false;

        synchronized (this) {
            try {
                // 1. 读取并寻找匹配项
                try (BufferedReader br = new BufferedReader(new FileReader(file))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        if (line.contains("\"studentId\":\"" + studentId + "\"") && line.contains("\"jobId\":\"" + jobId + "\"")) {
                            // 替换状态�?                            line = line.replaceAll("\"status\":\"[^\"]+\"", "\"status\":\"" + newStatus + "\"");
                            found = true;
                        }
                        fileContent.add(line);
                    }
                }

                if (!found) return false;

                // 2. 写回文件
                try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
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
}
