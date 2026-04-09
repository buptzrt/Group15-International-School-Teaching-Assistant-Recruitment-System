package com.me.finaldesignproject.dao;

import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import java.nio.charset.StandardCharsets;

public class ApplicationDao {
    // ✅ 核心路径：读写都锁定这个源码位置，解决同步延迟问题
    private static final String FILE_PATH = "E:\\Group15_TA_SYSTEM\\TA_System\\src\\main\\resources\\applications.json";

    /**
     * 学生端：保存新申请 (自动维护标准 JSON 数组格式)
     */
    public boolean saveApplication(String studentId, String jobId) {
        synchronized (this) {
            // 1. 先从源码路径读出所有现有的 JSON 行
            List<String> allLines = readAllLinesRaw();

            // 2. 构造新的申请条目
            String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            String newEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId + "\", \"date\":\"" + currentTime + "\", \"status\":\"Pending\"}";

            // 3. 加入列表并整体写回源码路径
            allLines.add(newEntry);
            return writeAllLinesRaw(allLines);
        }
    }

    /**
     * MO端：更新申请状态 (Pass/Reject)
     */
    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus) {
        synchronized (this) {
            List<String> allLines = readAllLinesRaw();
            boolean found = false;

            for (int i = 0; i < allLines.size(); i++) {
                String line = allLines.get(i);
                // 匹配 studentId 和 jobId
                if (line.contains("\"studentId\":\"" + studentId + "\"") && line.contains("\"jobId\":\"" + jobId + "\"")) {
                    // 替换状态值
                    allLines.set(i, line.replaceAll("\"status\":\"[^\"]+\"", "\"status\":\"" + newStatus + "\""));
                    found = true;
                }
            }

            if (!found) return false;

            // 写回源码路径文件
            return writeAllLinesRaw(allLines);
        }
    }

    /**
     * 获取学生已申请的 ID 集合
     */
    public Set<String> getAppliedJobIds(String studentId) {
        Set<String> appliedIds = new HashSet<>();
        List<String> lines = readAllLinesRaw();
        for (String line : lines) {
            if (line.contains("\"studentId\":\"" + studentId + "\"")) {
                try {
                    String jId = line.split("\"jobId\":\"")[1].split("\"")[0];
                    appliedIds.add(jId);
                } catch (Exception e) {
                    // 忽略格式异常的行
                }
            }
        }
        return appliedIds;
    }

    // ================= 核心工具方法：手动维护 [ ] 和逗号 =================

    /**
     * 读取文件，自动剥离外层的 [ ] 和行末逗号
     * ✅ 核心点：强制读取源码路径文件
     */
    private List<String> readAllLinesRaw() {
        List<String> lines = new ArrayList<>();
        // 强制使用 E 盘绝对路径，避开 target 的缓存和延迟
        File file = new File(FILE_PATH);
        if (!file.exists() || file.length() == 0) return lines;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                String trimmed = line.trim();
                // 过滤掉 JSON 数组的边界符和空行
                if (trimmed.equals("[") || trimmed.equals("]") || trimmed.isEmpty()) continue;

                // 如果行末有逗号，去掉它
                if (trimmed.endsWith(",")) {
                    trimmed = trimmed.substring(0, trimmed.length() - 1);
                }
                lines.add(trimmed);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return lines;
    }

    /**
     * 将数据包装在 [ ] 中，并自动为每行添加逗号
     * ✅ 核心点：覆盖写入源码路径文件
     */
    private boolean writeAllLinesRaw(List<String> lines) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                if (file.getParentFile() != null) file.getParentFile().mkdirs();
                file.createNewFile();
            }

            // 使用 false 覆盖写入 E 盘文件
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
                bw.write("[");
                bw.newLine();
                for (int i = 0; i < lines.size(); i++) {
                    bw.write("  " + lines.get(i));
                    // 只要不是最后一行，就加逗号
                    if (i < lines.size() - 1) {
                        bw.write(",");
                    }
                    bw.newLine();
                }
                bw.write("]");
            }
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}