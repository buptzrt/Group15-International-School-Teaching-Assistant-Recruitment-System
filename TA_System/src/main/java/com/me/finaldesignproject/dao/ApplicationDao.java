package com.me.finaldesignproject.dao;

import java.io.*;
import java.text.SimpleDateFormat;
import java.nio.charset.StandardCharsets;
import java.util.*;

import com.me.finaldesignproject.model.Job;

public class ApplicationDao {
    private static final String FILE_PATH = "D:/ta-final/Group15_TA_SYSTEM-wji-modifyfinal/TA_System/src/main/resources/applications.json";

    public static String getFilePath() {
        return FILE_PATH;
    }

    public boolean saveApplication(String studentId, String jobId) {
        File file = new File(FILE_PATH);
        try {
            if (!file.exists()) {
                File parent = file.getParentFile();
                if (parent != null) {
                    parent.mkdirs();
                }
                file.createNewFile();
            }

            String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
            String jsonEntry = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId
                    + "\", \"date\":\"" + currentTime
                    + "\", \"status\":\"Pending\", \"ignoreOvertime\":\"false\"}";

            synchronized (this) {
                List<String> validLines = new ArrayList<>();
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        if (!line.isEmpty() && line.startsWith("{")) {
                            validLines.add(line);
                        }
                    }
                }

                validLines.add(jsonEntry);

                try (BufferedWriter bw = new BufferedWriter(
                        new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
                    for (int i = 0; i < validLines.size(); i++) {
                        bw.write(validLines.get(i));
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

    public boolean updateApplicationStatus(String studentId, String jobId, String newStatus, String ignoreOvertime) {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            return false;
        }

        System.out.println("\n====== [ApplicationDao] updateApplicationStatus ======");
        System.out.println(">>> studentId=" + studentId + ", jobId=" + jobId + ", status=" + newStatus + ", ignoreOvertime=" + ignoreOvertime);

        List<String> fileContent = new ArrayList<>();
        boolean found = false;

        synchronized (this) {
            try {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        line = line.trim();
                        if (line.isEmpty() || !line.startsWith("{")) {
                            continue;
                        }

                        if (line.contains("\"studentId\":\"" + studentId + "\"")
                                && line.contains("\"jobId\":\"" + jobId + "\"")) {
                            String dateVal = "";
                            if (line.contains("\"date\":\"")) {
                                dateVal = line.split("\\\"date\\\":\\\"")[1].split("\\\"")[0];
                            }

                            String finalIgnore = ignoreOvertime;
                            if (finalIgnore == null || finalIgnore.isEmpty()) {
                                finalIgnore = line.contains("\"ignoreOvertime\":\"true\"") ? "true" : "false";
                            }

                            line = "{\"studentId\":\"" + studentId + "\", \"jobId\":\"" + jobId
                                    + "\", \"date\":\"" + dateVal
                                    + "\", \"status\":\"" + newStatus
                                    + "\", \"ignoreOvertime\":\"" + finalIgnore + "\"}";
                            found = true;
                            System.out.println(">>> updated: " + line);
                        }
                        fileContent.add(line);
                    }
                }

                if (!found) {
                    System.out.println(">>> no target application found");
                    return false;
                }

                try (BufferedWriter bw = new BufferedWriter(
                        new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
                    for (int i = 0; i < fileContent.size(); i++) {
                        bw.write(fileContent.get(i));
                        if (i < fileContent.size() - 1) {
                            bw.newLine();
                        }
                    }
                }
                System.out.println("====== [ApplicationDao] write success ======\n");
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

    public Set<String> getAppliedJobIds(String studentId) {
        Set<String> appliedIds = new HashSet<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            return appliedIds;
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.contains("\"studentId\":\"" + studentId + "\"")) {
                    String jId = line.split("\\\"jobId\\\":\\\"")[1].split("\\\"")[0];
                    appliedIds.add(jId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appliedIds;
    }

    public int getAppliedTotalHours(String studentId) {
        int totalHours = 0;
        if (studentId == null) {
            return 0;
        }

        Set<String> appliedJobIds = getAppliedJobIds(studentId);
        if (appliedJobIds.isEmpty()) {
            return 0;
        }

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

    public int getTotalApplicationCount(String studentId) {
        int count = 0;
        if (studentId == null) {
            return 0;
        }

        File file = new File(FILE_PATH);
        if (!file.exists() || !file.isFile()) {
            return 0;
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            String searchPattern = "\"studentId\":\"" + studentId + "\"";
            while ((line = br.readLine()) != null) {
                if (line.replace(" ", "").contains(searchPattern.replace(" ", ""))) {
                    count++;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean hasApplicationsForJob(String jobId) {
        if (jobId == null || jobId.trim().isEmpty()) {
            return false;
        }
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            return false;
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
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

    private List<String> getAllApplicationLines() {
        List<String> lines = new ArrayList<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            return lines;
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().startsWith("{")) {
                    lines.add(line);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lines;
    }

    public int getTotalWorkingHours(String studentId, String statusFilter) {
        int totalHours = 0;
        if (studentId == null || statusFilter == null) {
            return 0;
        }

        List<String> lines = getAllApplicationLines();
        JobDao jobDao = new JobDao();
        List<Job> allJobs = jobDao.getAllJobs();

        for (String line : lines) {
            String searchId = "\"studentId\":\"" + studentId + "\"";
            String searchStatus = "\"status\":\"" + statusFilter + "\"";

            if (line.replace(" ", "").contains(searchId.replace(" ", ""))
                    && line.replace(" ", "").contains(searchStatus.replace(" ", ""))) {
                try {
                    String jId = line.split("\\\"jobId\\\":\\\"")[1].split("\\\"")[0];
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
                } catch (Exception ignored) {
                }
            }
        }
        return totalHours;
    }
}
