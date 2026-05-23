package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.Job;
import com.me.finaldesignproject.model.StudentProfile;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet that calculates or retrieves the AI match score for a student and job.
 */
@WebServlet("/GetAiScoreServlet")
public class GetAiScoreServlet extends HttpServlet {
    private static final Gson GSON = new Gson();

    /**
     * Builds the student and job context, invokes the AI matcher, and returns the score as JSON.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        JsonObject json = new JsonObject();

        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                writeError(response, "Session expired. Please log in again.");
                return;
            }

            String studentId = (String) session.getAttribute("userId");
            if (studentId == null || studentId.trim().isEmpty()) {
                studentId = (String) session.getAttribute("enrollment_no");
            }

            if (studentId == null || studentId.trim().isEmpty()) {
                writeError(response, "Student ID not found in session.");
                return;
            }

            String jobId = request.getParameter("jobId");
            if (jobId == null || jobId.trim().isEmpty()) {
                writeError(response, "Missing jobId.");
                return;
            }
            jobId = jobId.trim();
            Job targetJob = null;
            for (Job job : new JobDao().getAllJobs()) {
                if (jobId.equals(job.getJobId())) {
                    targetJob = job;
                    break;
                }
            }

            if (targetJob == null) {
                writeError(response, "Job not found.");
                return;
            }

            StudentProfile profile = new StudentProfileDao().getByEnrollment(studentId);
            if (profile == null) {
                writeError(response, "Student profile not found.");
                return;
            }

            AiMatchEngine.MatchResult result = AiMatchEngine.evaluate(targetJob, profile, "");
            if (result == null) {
                writeError(response, "AI engine returned no result.");
                return;
            }

            json.addProperty("success", true);
            json.addProperty("score", result.score);
            json.addProperty("reason", result.reason == null ? "" : result.reason);
            response.getWriter().write(GSON.toJson(json));
        } catch (Exception e) {
            e.printStackTrace();
            writeError(response, "Failed to get AI score.");
        }
    }

    private void writeError(HttpServletResponse response, String message) throws IOException {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        response.getWriter().write(GSON.toJson(json));
    }
}

