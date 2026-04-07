package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;

public class ApplicationDao {
    // ✅ 统一存放路径，修改这一处，全项目生效
    private static final String FILE_PATH = "E:\\Group15_TA_SYSTEM\\TA_System\\src\\main\\resources\\applications.json";

    /**
     * 保存申请记录
     */
    public boolean saveApplication(String studentId, String jobId) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
            String currentTime = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            String jsonEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + currentTime + "\"}";

            try (BufferedWriter bw = new BufferedWriter(new FileWriter(file, true))) {
                if (file.length() > 0) bw.newLine();
                bw.write(jsonEntry);
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 获取指定学生已申请的所有 JobId (用于 Job List 按钮变灰)
     */
    public Set<String> getAppliedJobIds(String studentId) {
        Set<String> appliedIds = new HashSet<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return appliedIds;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.contains("\"studentId\":\"" + studentId + "\"")) {
                    // 简单提取 jobId
                    String jobId = line.split("\"jobId\":\"")[1].split("\"")[0];
                    appliedIds.add(jobId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appliedIds;
    }
}