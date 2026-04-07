package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.Job;

import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class JobDao {
    // Ensure read/write uses only one absolute path
    private static final String FILE_PATH = "E:/Group15_TA_SYSTEM/TA_System/src/main/resources/jobs.json";

    private static final Type JOB_LIST_TYPE = new TypeToken<ArrayList<Job>>() {}.getType();
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    public List<Job> getAllJobs() {
        return readJobsFromPath(FILE_PATH);
    }

    public List<Job> getJobsByMoId(String moId) {
        return getAllJobs().stream()
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
        if (removed) {
            saveToFile(jobs);
        }
        return removed;
    }

    private boolean saveToFile(List<Job> jobs) {
        return writeJobsToPath(FILE_PATH, jobs);
    }

    private List<Job> readJobsFromPath(String filePath) {
        List<Job> empty = new ArrayList<>();
        try {
            Path path = Paths.get(filePath);
            if (!Files.exists(path)) {
                return empty;
            }

            String json = Files.readString(path, StandardCharsets.UTF_8).trim();
            if (json.isEmpty()) {
                return empty;
            }

            if (json.startsWith("[")) {
                List<Job> jobs = gson.fromJson(json, JOB_LIST_TYPE);
                return jobs == null ? empty : jobs;
            }

            if (json.startsWith("{")) {
                Job single = gson.fromJson(json, Job.class);
                if (single == null) {
                    return empty;
                }
                List<Job> jobs = new ArrayList<>();
                jobs.add(single);
                return jobs;
            }

            return empty;
        } catch (Exception e) {
            System.err.println("JobDao: error reading jobs.json from " + filePath);
            e.printStackTrace();
            return empty;
        }
    }

    private boolean writeJobsToPath(String filePath, List<Job> jobs) {
        try {
            Path path = Paths.get(filePath);
            Path parent = path.getParent();
            if (parent != null && !Files.exists(parent)) {
                Files.createDirectories(parent);
            }

            String output = gson.toJson(jobs == null ? new ArrayList<>() : jobs);
            Files.writeString(path, output, StandardCharsets.UTF_8);
            return true;
        } catch (Exception e) {
            System.err.println("JobDao: error writing jobs.json to " + filePath);
            e.printStackTrace();
            return false;
        }
    }
}
