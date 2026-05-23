package com.me.finaldesignproject;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.testing.TestSupport;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AiMatchEngineTest {
    @TempDir
    Path tempDir;

    @AfterEach
    void tearDown() {
        AiMatchEngine.resetMatchEvaluatorForTesting();
    }

    @Test
    void returnsCachedResultWhenCacheIsStillValid() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");
        Path cacheFile = tempDir.resolve("ai_match_cache.json");

        Job job = buildJob("J-1");
        StudentProfile profile = buildProfile("2023213001", "S-1");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile)
                    .withProperty(AiMatchEngine.AI_CACHE_PATH_PROPERTY, cacheFile);
            support.write(applicationsFile, "");
            support.write(jobsFile, "[]");
            support.write(profilesFile, "{}");

            long validTimestamp = System.currentTimeMillis() + 10_000;
            support.write(cacheFile, """
                    {
                      "J-1_S-1": {
                        "score": 88,
                        "reason": "cached result",
                        "timestamp": %d
                      }
                    }
                    """.formatted(validTimestamp));

            AiMatchEngine.setMatchEvaluatorForTesting((j, p, pdf) -> {
                throw new IllegalStateException("Evaluator should not be used when cache is valid");
            });

            AiMatchEngine.MatchResult result = AiMatchEngine.evaluate(job, profile, "");

            assertEquals(88, result.score);
            assertEquals("cached result", result.reason);
        }
    }

    @Test
    void evaluatesAndWritesFreshCacheWhenCacheIsMissing() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");
        Path cacheFile = tempDir.resolve("ai_match_cache.json");

        Job job = buildJob("J-2");
        StudentProfile profile = buildProfile("2023213002", "S-2");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile)
                    .withProperty(AiMatchEngine.AI_CACHE_PATH_PROPERTY, cacheFile);
            support.write(applicationsFile, "");
            support.write(jobsFile, "[]");
            support.write(profilesFile, "{}");

            AiMatchEngine.setMatchEvaluatorForTesting((j, p, pdf) ->
                    new AiMatchEngine.MatchResult(91, "fresh result", System.currentTimeMillis()));

            AiMatchEngine.MatchResult result = AiMatchEngine.evaluate(job, profile, "");

            assertEquals(91, result.score);
            JsonObject cacheJson = JsonParser.parseString(support.read(cacheFile)).getAsJsonObject();
            assertTrue(cacheJson.has("J-2_S-2"));
            assertEquals(91, cacheJson.getAsJsonObject("J-2_S-2").get("score").getAsInt());
        }
    }

    @Test
    void returnsFallbackWhenEvaluatorThrows() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");

        Job job = buildJob("J-3");
        StudentProfile profile = buildProfile("2023213003", "S-3");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile);
            support.write(applicationsFile, "");
            support.write(jobsFile, "[]");
            support.write(profilesFile, "{}");

            AiMatchEngine.setMatchEvaluatorForTesting((j, p, pdf) -> {
                throw new RuntimeException("boom");
            });

            AiMatchEngine.MatchResult result = AiMatchEngine.evaluate(job, profile, "");

            assertEquals(0, result.score);
            assertTrue(result.reason.contains("AI Analysis Error"));
        }
    }

    private static Job buildJob(String jobId) {
        Job job = new Job();
        job.setJobId(jobId);
        job.setJobTitle("Teaching Assistant");
        job.setLocation("Main Campus");
        job.setWorkingHours("5");
        job.setPreferredMajor("CS");
        job.setRequiredSkills("Java");
        return job;
    }

    private static StudentProfile buildProfile(String enrollmentNo, String studentId) {
        StudentProfile profile = new StudentProfile();
        profile.setEnrollmentNo(enrollmentNo);
        profile.setStudentId(studentId);
        profile.setCampusPreference("Both");
        profile.setAvailability("All semester");
        profile.setMajorProgramme("Computer Science");
        profile.setGrade("A");
        profile.setSkills("Java");
        profile.setProjectExperience("Portal project");
        profile.setTaExperience("Lab helper");
        profile.setSelfEvaluation("Careful");
        return profile;
    }
}
