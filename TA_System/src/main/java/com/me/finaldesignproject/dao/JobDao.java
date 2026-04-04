package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.Job;

import java.io.*;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class JobDao {
    // 💡 确保根目录有 data 文件夹
    private static final String FILE_PATH = "D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/jobs.json";
    private Gson gson = new GsonBuilder().setPrettyPrinting().create();

    public List<Job> getAllJobs() {
        File file = new File(FILE_PATH);
        if (!file.exists() || file.length() == 0) return new ArrayList<>();
        try (Reader reader = new FileReader(file)) {
            Type listType = new TypeToken<ArrayList<Job>>(){}.getType();
            List<Job> jobs = gson.fromJson(reader, listType);
            return jobs == null ? new ArrayList<>() : jobs;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // ⚠️ 【核心修改】：这里的 moId 必须是 String 类型！
    public List<Job> getJobsByMoId(String moId) {
        return getAllJobs().stream()
                // 💡 因为是 String，所以用 .equals() 判断是否是当前 MO 创建的职位
                .filter(job -> job.getCreatorId() != null && job.getCreatorId().equals(moId))
                .collect(Collectors.toList());
    }

    public boolean addJob(Job newJob) {
        List<Job> jobs = getAllJobs();
        jobs.add(newJob);
        return saveToFile(jobs);
    }

    public boolean updateJob(Job updatedJob) {
        List<Job> jobs = getAllJobs();
        for (int i = 0; i < jobs.size(); i++) {
            if (jobs.get(i).getJobId().equals(updatedJob.getJobId())) {
                jobs.set(i, updatedJob);
                return saveToFile(jobs);
            }
        }
        return false;
    }

    public boolean deleteJob(String jobId) {
        List<Job> jobs = getAllJobs();
        boolean removed = jobs.removeIf(job -> job.getJobId().equals(jobId));
        if (removed) saveToFile(jobs);
        return removed;
    }

    private boolean saveToFile(List<Job> jobs) {
        File file = new File(FILE_PATH);
        try {
            if (!file.getParentFile().exists()) file.getParentFile().mkdirs();
            try (Writer writer = new FileWriter(file)) {
                gson.toJson(jobs, writer);
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}
