package com.me.finaldesignproject.dao;

import com.google.gson.GsonBuilder;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.testing.TestSupport;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ApplicationDaoTest {
    @TempDir
    Path tempDir;

    @Test
    void saveApplicationAppendsPendingRecord() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, """
                    {"studentId":"S-1", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Pending", "ignoreOvertime":"false"}
                    """);

            assertTrue(new ApplicationDao().saveApplication("S-2", "J-2"));

            String content = support.read(applicationsFile);
            assertTrue(content.contains("\"studentId\":\"S-2\""));
            assertTrue(content.contains("\"status\":\"Pending\""));
        }
    }

    @Test
    void updateApplicationStatusPreservesDateAndExistingIgnoreFlag() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, """
                    {"studentId":"S-1", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Pending", "ignoreOvertime":"true"}
                    """);

            ApplicationDao dao = new ApplicationDao();
            assertTrue(dao.updateApplicationStatus("S-1", "J-1", "Accepted"));

            String content = support.read(applicationsFile);
            assertTrue(content.contains("\"date\":\"2026-05-01 09:00\""));
            assertTrue(content.contains("\"status\":\"Accepted\""));
            assertTrue(content.contains("\"ignoreOvertime\":\"true\""));
        }
    }

    @Test
    void updateApplicationStatusReturnsFalseWhenTargetDoesNotExist() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile);
            support.write(applicationsFile, """
                    {"studentId":"S-1", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Pending", "ignoreOvertime":"false"}
                    """);

            assertFalse(new ApplicationDao().updateApplicationStatus("S-9", "J-9", "Accepted"));
        }
    }

    @Test
    void aggregateMethodsCombineApplicationsAndJobs() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, """
                    {"studentId":"S-1", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Accepted", "ignoreOvertime":"false"}
                    {"studentId":"S-1", "jobId":"J-2", "date":"2026-05-01 09:10", "status":"Pending", "ignoreOvertime":"false"}
                    {"studentId":"S-2", "jobId":"J-1", "date":"2026-05-01 09:20", "status":"Pending", "ignoreOvertime":"false"}
                    """);
            support.write(jobsFile, toJson(buildJob("J-1", "5 hours"), buildJob("J-2", "10 hours")));

            ApplicationDao dao = new ApplicationDao();
            Set<String> appliedJobIds = dao.getAppliedJobIds("S-1");

            assertEquals(Set.of("J-1", "J-2"), appliedJobIds);
            assertEquals(15, dao.getAppliedTotalHours("S-1"));
            assertEquals(2, dao.getTotalApplicationCount("S-1"));
            assertEquals(5, dao.getTotalWorkingHours("S-1", "Accepted"));
            assertTrue(dao.hasApplicationsForJob("J-2"));
            assertFalse(dao.hasApplicationsForJob(" "));
        }
    }

    private static Job buildJob(String jobId, String workingHours) {
        Job job = new Job();
        job.setJobId(jobId);
        job.setCreatorId("MO-1");
        job.setCreatorRole("MO");
        job.setCourseName("Software Engineering");
        job.setModuleCode("SE101");
        job.setJobTitle("Teaching Assistant");
        job.setNumberOfPositions(3);
        job.setApplicationDeadline("2099-06-30");
        job.setRequiredSkills("Java");
        job.setJobResponsibilities("Tutorial support");
        job.setWorkingHours(workingHours);
        job.setLocation("Main Campus");
        job.setActivityType("Lab");
        job.setSemester("Fall");
        job.setCgpaRequired(3.0);
        job.setPreferredMajor("CS");
        job.setContactEmail("mo@example.com");
        job.setContactPhone("123456789");
        job.setStatus("Open");
        job.setPostedDate("2026-05-01");
        job.setLastUpdatedDate("2026-05-01");
        job.setLastModifiedBy("MO-1");
        job.setLastModifiedRole("MO");
        job.setDeleted(false);
        job.setApplicationsReceived(0);
        job.setApplicationsAccepted(0);
        job.setStudentCanApply(true);
        job.setEditable(true);
        job.setDeletable(true);
        job.setApprovalStatus("Approved");
        return job;
    }

    private static String toJson(Job... jobs) {
        return new GsonBuilder().setPrettyPrinting().create().toJson(jobs);
    }
}
