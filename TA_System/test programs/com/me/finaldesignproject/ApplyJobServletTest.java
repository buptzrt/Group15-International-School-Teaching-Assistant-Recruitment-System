package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.testing.TestSupport;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ApplyJobServletTest {
    @TempDir
    Path tempDir;

    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    HttpSession session;

    @Test
    void rejectsMissingLoginOrJobId() throws Exception {
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(null);
        when(request.getParameter("jobId")).thenReturn("J-1");

        new ApplyJobServlet().doGet(request, response);

        verify(response).sendError(HttpServletResponse.SC_FORBIDDEN, "Login required.");
    }

    @Test
    void rejectsUnavailableJob() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, "");
            support.write(jobsFile, """
                    [{"jobId":"J-1","creatorId":"MO-1","creatorRole":"MO","courseName":"SE","moduleCode":"SE101","jobTitle":"TA","numberOfPositions":0,"applicationDeadline":"2099-06-30","requiredSkills":"Java","jobResponsibilities":"Help","workingHours":"5","location":"Main","activityType":"Lab","semester":"Fall","cgpaRequired":3.0,"preferredMajor":"CS","contactEmail":"mo@example.com","contactPhone":"123","status":"Closed","postedDate":"2026-05-01","lastUpdatedDate":"2026-05-01","lastModifiedBy":"MO-1","lastModifiedRole":"MO","deleted":false,"applicationsReceived":0,"applicationsAccepted":0,"studentCanApply":false,"editable":true,"deletable":true,"approvalStatus":"Approved"}]
                    """);

            when(request.getSession()).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("S-1");
            when(request.getParameter("jobId")).thenReturn("J-1");

            new ApplyJobServlet().doGet(request, response);

            verify(response).sendError(HttpServletResponse.SC_CONFLICT, "Job no longer available.");
        }
    }

    @Test
    void ajaxApplicationReturnsWarningWhenCountLimitIsReached() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");
        StringWriter buffer = new StringWriter();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, buildApplications(19));
            support.write(jobsFile, openJobJson("J-20"));
            when(request.getSession()).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("S-1");
            when(request.getParameter("jobId")).thenReturn("J-20");
            when(request.getHeader("X-Requested-With")).thenReturn("XMLHttpRequest");
            when(response.getWriter()).thenReturn(new PrintWriter(buffer, true));

            new ApplyJobServlet().doGet(request, response);

            verify(response).setStatus(HttpServletResponse.SC_OK);
            assertTrue(buffer.toString().contains("WARNING_COUNT_LIMIT"));
            assertTrue(support.read(applicationsFile).contains("\"jobId\":\"J-20\""));
        }
    }

    @Test
    void normalApplicationRedirectsToStudentJobServlet() throws Exception {
        Path applicationsFile = tempDir.resolve("applications.json");
        Path jobsFile = tempDir.resolve("jobs.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(ApplicationDao.APPLICATION_JSON_PATH_PROPERTY, applicationsFile)
                    .withProperty(JobDao.JOB_JSON_PATH_PROPERTY, jobsFile);
            support.write(applicationsFile, "");
            support.write(jobsFile, openJobJson("J-1"));
            when(request.getSession()).thenReturn(session);
            when(session.getAttribute("userId")).thenReturn("S-1");
            when(request.getParameter("jobId")).thenReturn("J-1");
            when(request.getHeader("X-Requested-With")).thenReturn(null);

            new ApplyJobServlet().doGet(request, response);

            verify(response).sendRedirect("StudentJobServlet");
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

    private static String buildApplications(int count) {
        StringBuilder builder = new StringBuilder();
        for (int i = 1; i <= count; i++) {
            builder.append("{\"studentId\":\"S-1\", \"jobId\":\"J-")
                    .append(i)
                    .append("\", \"date\":\"2026-05-01 09:00\", \"status\":\"Pending\", \"ignoreOvertime\":\"false\"}");
            if (i < count) {
                builder.append(System.lineSeparator());
            }
        }
        return builder.toString();
    }
}
