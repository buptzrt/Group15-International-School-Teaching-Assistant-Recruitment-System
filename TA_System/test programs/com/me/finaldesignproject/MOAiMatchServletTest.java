package com.me.finaldesignproject;

import com.google.gson.JsonArray;
import com.google.gson.JsonParser;
import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.testing.TestSupport;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MOAiMatchServletTest {
    @TempDir
    Path tempDir;

    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @AfterEach
    void tearDown() {
        AiMatchEngine.resetMatchEvaluatorForTesting();
    }

    @Test
    void returnsEmptyArrayWhenJobDoesNotExist() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");
        Path applicationsFile = tempDir.resolve("applications.json");
        StringWriter buffer = new StringWriter();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile)
                    .withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile);
            support.write(jobsFile, "[]");
            support.write(profilesFile, "{}");
            support.write(applicationsFile, "");

            when(request.getParameter("jobId")).thenReturn("J-404");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new MOAiMatchServlet().doPost(request, response);

            assertEquals("[]", buffer.toString());
        }
    }

    @Test
    void returnsEmptyArrayWhenNoPendingApplicantsExist() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");
        Path applicationsFile = tempDir.resolve("applications.json");
        StringWriter buffer = new StringWriter();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile)
                    .withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile);
            support.write(jobsFile, openJobJson("J-1"));
            support.write(profilesFile, "{}");
            support.write(applicationsFile, """
                    {"studentId":"2023213001", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Accepted", "ignoreOvertime":"false"}
                    """);

            when(request.getParameter("jobId")).thenReturn("J-1");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new MOAiMatchServlet().doPost(request, response);

            assertEquals("[]", buffer.toString());
        }
    }

    @Test
    void returnsAiResultsForPendingApplicants() throws Exception {
        Path jobsFile = tempDir.resolve("jobs.json");
        Path profilesFile = tempDir.resolve("student_profiles.json");
        Path applicationsFile = tempDir.resolve("applications.json");
        StringWriter buffer = new StringWriter();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile)
                    .withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile)
                    .withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile);
            support.write(jobsFile, openJobJson("J-1"));
            support.write(profilesFile, """
                    {
                      "2023213001": {
                        "enrollmentNo": "2023213001",
                        "studentId": "S-1",
                        "fullName": "Alice Student",
                        "majorProgramme": "Computer Science",
                        "resumePath": ""
                      },
                      "2023213002": {
                        "enrollmentNo": "2023213002",
                        "studentId": "S-2",
                        "fullName": "Bob Student",
                        "majorProgramme": "Software Engineering",
                        "resumePath": ""
                      }
                    }
                    """);
            support.write(applicationsFile, """
                    {"studentId":"2023213001", "jobId":"J-1", "date":"2026-05-01 09:00", "status":"Pending", "ignoreOvertime":"false"}
                    {"studentId":"2023213002", "jobId":"J-1", "date":"2026-05-01 09:10", "status":"Rejected", "ignoreOvertime":"false"}
                    """);

            AiMatchEngine.setMatchEvaluatorForTesting((job, profile, pdf) ->
                    new AiMatchEngine.MatchResult(79, "AI matched", System.currentTimeMillis()));

            when(request.getParameter("jobId")).thenReturn("J-1");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new MOAiMatchServlet().doPost(request, response);

            JsonArray array = JsonParser.parseString(buffer.toString()).getAsJsonArray();
            assertEquals(1, array.size());
            assertEquals("2023213001", array.get(0).getAsJsonObject().get("studentId").getAsString());
            assertEquals(79, array.get(0).getAsJsonObject().get("score").getAsInt());
            assertTrue(array.get(0).getAsJsonObject().get("reason").getAsString().contains("AI matched"));
        }
    }

    private static String openJobJson(String jobId) {
        return """
                [{
                  "jobId":"%s",
                  "creatorId":"MO-1",
                  "creatorRole":"MO",
                  "courseName":"SE",
                  "moduleCode":"SE101",
                  "jobTitle":"TA",
                  "numberOfPositions":3,
                  "applicationDeadline":"2099-06-30",
                  "requiredSkills":"Java",
                  "jobResponsibilities":"Help",
                  "workingHours":"5",
                  "location":"Main",
                  "activityType":"Lab",
                  "semester":"Fall",
                  "cgpaRequired":3.0,
                  "preferredMajor":"CS",
                  "contactEmail":"mo@example.com",
                  "contactPhone":"123",
                  "status":"Open",
                  "postedDate":"2026-05-01",
                  "lastUpdatedDate":"2026-05-01",
                  "lastModifiedBy":"MO-1",
                  "lastModifiedRole":"MO",
                  "deleted":false,
                  "applicationsReceived":0,
                  "applicationsAccepted":0,
                  "studentCanApply":true,
                  "editable":true,
                  "deletable":true,
                  "approvalStatus":"Approved"
                }]
                """.formatted(jobId);
    }
}
