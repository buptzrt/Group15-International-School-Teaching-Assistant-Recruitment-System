package com.me.finaldesignproject;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.testing.TestSupport;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetAiScoreServletTest {
    @TempDir
    Path tempDir;

    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    HttpSession session;

    @AfterEach
    void tearDown() {
        AiMatchEngine.resetMatchEvaluatorForTesting();
    }

    @Test
    void returnsErrorWhenSessionIsMissing() throws Exception {
        StringWriter buffer = new StringWriter();
        when(request.getSession(false)).thenReturn(null);
        when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

        new GetAiScoreServlet().doGet(request, response);

        JsonObject json = JsonParser.parseString(buffer.toString()).getAsJsonObject();
        assertFalse(json.get("success").getAsBoolean());
        assertEquals("Session expired. Please log in again.", json.get("message").getAsString());
    }

    @Test
    void returnsErrorWhenJobIdIsMissing() throws Exception {
        StringWriter buffer = new StringWriter();
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn("2023213001");
        when(request.getParameter("jobId")).thenReturn(" ");
        when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

        new GetAiScoreServlet().doGet(request, response);

        JsonObject json = JsonParser.parseString(buffer.toString()).getAsJsonObject();
        assertFalse(json.get("success").getAsBoolean());
        assertEquals("Missing jobId.", json.get("message").getAsString());
    }

    @Test
    void returnsErrorWhenJobIsNotFound() throws Exception {
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

            when(request.getSession(false)).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("2023213001");
            when(request.getParameter("jobId")).thenReturn("J-404");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new GetAiScoreServlet().doGet(request, response);

            JsonObject json = JsonParser.parseString(buffer.toString()).getAsJsonObject();
            assertFalse(json.get("success").getAsBoolean());
            assertEquals("Job not found.", json.get("message").getAsString());
        }
    }

    @Test
    void returnsErrorWhenProfileIsNotFound() throws Exception {
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
            support.write(applicationsFile, "");

            when(request.getSession(false)).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("2023213001");
            when(request.getParameter("jobId")).thenReturn("J-1");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new GetAiScoreServlet().doGet(request, response);

            JsonObject json = JsonParser.parseString(buffer.toString()).getAsJsonObject();
            assertFalse(json.get("success").getAsBoolean());
            assertEquals("Student profile not found.", json.get("message").getAsString());
        }
    }

    @Test
    void returnsAiScoreWhenJobAndProfileExist() throws Exception {
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
                        "majorProgramme": "Computer Science"
                      }
                    }
                    """);
            support.write(applicationsFile, "");

            AiMatchEngine.setMatchEvaluatorForTesting((job, profile, pdf) ->
                    new AiMatchEngine.MatchResult(83, "Strong technical fit", System.currentTimeMillis()));

            when(request.getSession(false)).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("2023213001");
            when(request.getParameter("jobId")).thenReturn("J-1");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new GetAiScoreServlet().doGet(request, response);

            JsonObject json = JsonParser.parseString(buffer.toString()).getAsJsonObject();
            assertTrue(json.get("success").getAsBoolean());
            assertEquals(83, json.get("score").getAsInt());
            assertEquals("Strong technical fit", json.get("reason").getAsString());
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
