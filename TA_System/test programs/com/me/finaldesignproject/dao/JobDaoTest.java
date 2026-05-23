package com.me.finaldesignproject.dao;

import com.google.gson.GsonBuilder;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.testing.TestSupport;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JobDaoTest {
    @TempDir
    Path tempDir;

    @Test
    void getAllJobsCanReadSingleObjectJson() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(jobsFile, new GsonBuilder().create().toJson(buildJob("J-1", "MO-1", 2, "Open", false, true)));

            List<Job> jobs = new JobDao().getAllJobs();

            assertEquals(1, jobs.size());
            assertEquals("J-1", jobs.get(0).getJobId());
        }
    }

    @Test
    void addUpdateAndDeleteJobPersistChanges() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(jobsFile, "[]");
            JobDao dao = new JobDao();
            Job job = buildJob("J-1", "MO-1", 2, "Open", false, true);

            assertTrue(dao.addJob(job));
            job.setJobTitle("Updated Title");
            assertTrue(dao.updateJob(job));
            assertTrue(dao.deleteJob("J-1"));
            assertTrue(dao.getAllJobs().isEmpty());
        }
    }

    @Test
    void getJobsByMoIdIgnoresDeletedRecords() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(jobsFile, toJson(
                    buildJob("J-1", "MO-1", 2, "Open", false, true),
                    buildJob("J-2", "MO-1", 2, "Open", true, true),
                    buildJob("J-3", "MO-2", 2, "Open", false, true)
            ));

            List<Job> jobs = new JobDao().getJobsByMoId("MO-1");

            assertEquals(1, jobs.size());
            assertEquals("J-1", jobs.get(0).getJobId());
        }
    }

    @Test
    void decreasePositionClosesJobAtZero() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(jobsFile, toJson(buildJob("J-1", "MO-1", 1, "Open", false, true)));

            JobDao dao = new JobDao();
            assertTrue(dao.decreasePosition("J-1"));

            Job updated = dao.getAllJobs().get(0);
            assertEquals(0, updated.getNumberOfPositions());
            assertEquals("Closed", updated.getStatus());
            assertFalse(updated.isStudentCanApply());
        }
    }

    @Test
    void increasePositionReopensClosedJob() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            Job job = buildJob("J-1", "MO-1", 0, "Closed", false, false);
            job.setApplicationsAccepted(2);
            support.write(jobsFile, toJson(job));

            JobDao dao = new JobDao();
            assertTrue(dao.increasePosition("J-1"));

            Job updated = dao.getAllJobs().get(0);
            assertEquals(1, updated.getNumberOfPositions());
            assertEquals(1, updated.getApplicationsAccepted());
            assertEquals("Open", updated.getStatus());
            assertTrue(updated.isStudentCanApply());
        }
    }

    @Test
    void isVisibleInHallChecksOpenStatusDeadlineAndFlags() {
        JobDao dao = new JobDao();
        LocalDate today = LocalDate.of(2026, 5, 23);

        assertTrue(dao.isVisibleInHall(buildJob("J-1", "MO-1", 2, "Open", false, true), today));
        assertFalse(dao.isVisibleInHall(buildJob("J-2", "MO-1", 0, "Open", false, true), today));

        Job expired = buildJob("J-3", "MO-1", 2, "Open", false, true);
        expired.setApplicationDeadline("2026-05-22");
        assertFalse(dao.isVisibleInHall(expired, today));
    }

    private static Job buildJob(String jobId, String creatorId, int positions, String status,
                                boolean deleted, boolean studentCanApply) {
        Job job = new Job();
        job.setJobId(jobId);
        job.setCreatorId(creatorId);
        job.setCreatorRole("MO");
        job.setCourseName("Software Engineering");
        job.setModuleCode("SE101");
        job.setJobTitle("Teaching Assistant");
        job.setNumberOfPositions(positions);
        job.setApplicationDeadline("2099-06-30");
        job.setRequiredSkills("Java");
        job.setJobResponsibilities("Tutorial support");
        job.setWorkingHours("5 hours");
        job.setLocation("Main Campus");
        job.setActivityType("Lab");
        job.setSemester("Fall");
        job.setCgpaRequired(3.2);
        job.setPreferredMajor("CS");
        job.setContactEmail("mo@example.com");
        job.setContactPhone("123456789");
        job.setStatus(status);
        job.setPostedDate("2026-05-01");
        job.setLastUpdatedDate("2026-05-01");
        job.setLastModifiedBy("MO-1");
        job.setLastModifiedRole("MO");
        job.setDeleted(deleted);
        job.setApplicationsReceived(0);
        job.setApplicationsAccepted(0);
        job.setStudentCanApply(studentCanApply);
        job.setEditable(true);
        job.setDeletable(true);
        job.setApprovalStatus("Approved");
        return job;
    }

    private static String toJson(Job... jobs) {
        return new GsonBuilder().setPrettyPrinting().create().toJson(jobs);
    }
}
