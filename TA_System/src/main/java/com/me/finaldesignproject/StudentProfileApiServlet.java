package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * REST-style servlet for reading and saving the logged-in student's profile data.
 */
public class StudentProfileApiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new Gson();

    /**
     * Returns the current student's profile as JSON.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        prepareJsonResponse(response);

        try {
            String cookieHeader = request.getHeader("Cookie");
            System.out.println("[StudentProfileApiServlet GET] Cookie header: " + cookieHeader);

            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("[StudentProfileApiServlet GET] No active session.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                response.flushBuffer();
                return;
            }

            System.out.println("[StudentProfileApiServlet GET] Session ID: " + session.getId());

            String enrollmentNo = resolveEnrollmentNo(session);
            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                System.err.println("[StudentProfileApiServlet GET] Missing enrollment number in session.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                response.flushBuffer();
                return;
            }

            StudentProfileDao profileDao = new StudentProfileDao();
            StudentProfile studentProfile = profileDao.getByEnrollment(enrollmentNo);
            if (studentProfile == null) {
                studentProfile = new StudentProfile();
                studentProfile.setEnrollmentNo(enrollmentNo);
            }

            response.getWriter().write(GSON.toJson(studentProfile));
            response.flushBuffer();
            System.out.println("[StudentProfileApiServlet GET] Returned profile for " + enrollmentNo);
        } catch (Exception e) {
            System.err.println("[StudentProfileApiServlet GET] Error: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(
                    new ApiResponse(false, "Error loading profile: " + e.getMessage())));
            safeFlush(response, "GET");
        }
    }

    /**
     * Delegates first-time profile submissions to the shared save logic.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        saveProfile(request, response);
    }

    /**
     * Delegates profile updates to the shared save logic.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        saveProfile(request, response);
    }

    /**
     * Saves a profile payload received from either a POST or PUT request.
     */
    private void saveProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        prepareJsonResponse(response);

        try {
            String cookieHeader = request.getHeader("Cookie");
            System.out.println("[StudentProfileApiServlet SAVE] Cookie header: " + cookieHeader);

            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("[StudentProfileApiServlet SAVE] No active session.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                response.flushBuffer();
                return;
            }

            System.out.println("[StudentProfileApiServlet SAVE] Session ID: " + session.getId());

            User user = (User) session.getAttribute("user");
            String enrollmentNo = resolveEnrollmentNo(session);
            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                System.err.println("[StudentProfileApiServlet SAVE] Missing enrollment number in session.");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                response.flushBuffer();
                return;
            }

            StudentProfile studentProfile = parseRequest(request);
            if (studentProfile == null) {
                System.err.println("[StudentProfileApiServlet SAVE] Invalid request body.");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Invalid request data")));
                response.flushBuffer();
                return;
            }

            studentProfile.setEnrollmentNo(enrollmentNo);

            String validationError = validateProfile(studentProfile);
            if (validationError != null) {
                response.getWriter().write(GSON.toJson(new ApiResponse(false, validationError)));
                response.flushBuffer();
                return;
            }

            StudentProfileDao profileDao = new StudentProfileDao();
            if (profileDao.save(studentProfile)) {
                session.setAttribute("__keep_alive__", System.currentTimeMillis());
                if (user != null) {
                    session.setAttribute("user", user);
                }
                session.setMaxInactiveInterval(3600);

                HttpSession finalSession = request.getSession(false);
                if (finalSession != null) {
                    System.out.println("[StudentProfileApiServlet SAVE] Final session ID: "
                            + finalSession.getId());
                } else {
                    System.out.println("[StudentProfileApiServlet SAVE] Warning: session missing after save.");
                }

                response.getWriter().write(
                        GSON.toJson(new ApiResponse(true, "Profile saved successfully")));
                response.flushBuffer();
                System.out.println("[StudentProfileApiServlet SAVE] Saved profile for " + enrollmentNo);
            } else {
                System.err.println("[StudentProfileApiServlet SAVE] Failed to persist profile.");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Failed to save profile")));
                response.flushBuffer();
            }
        } catch (Exception e) {
            System.err.println("[StudentProfileApiServlet SAVE] Error: " + e.getMessage());
            e.printStackTrace();
            try {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(
                        GSON.toJson(new ApiResponse(false, "Error saving profile: " + e.getMessage())));
                response.flushBuffer();
                System.err.println("[StudentProfileApiServlet SAVE] Error response sent.");
            } catch (Exception flushException) {
                System.err.println("[StudentProfileApiServlet SAVE] Failed to flush error response: "
                        + flushException.getMessage());
            }
        }
    }

    /**
     * Parses the JSON request body into a {@link StudentProfile}.
     *
     * @param request the incoming HTTP request
     * @return the parsed profile, or {@code null} when the body is empty or invalid
     */
    private StudentProfile parseRequest(HttpServletRequest request) {
        try {
            request.setCharacterEncoding("UTF-8");
            String json = request.getReader().lines().reduce("", (acc, actual) -> acc + actual);
            if (json == null || json.isEmpty()) {
                return null;
            }
            return GSON.fromJson(json, StudentProfile.class);
        } catch (Exception e) {
            System.err.println("[StudentProfileApiServlet] parseRequest error: " + e.getMessage());
            return null;
        }
    }

    /**
     * Validates the minimum required profile fields before persistence.
     *
     * @param profile the profile to validate
     * @return {@code null} when valid, otherwise a user-facing validation message
     */
    private String validateProfile(StudentProfile profile) {
        if (profile == null) {
            return "Profile is null";
        }
        if (profile.getFullName() == null || profile.getFullName().trim().isEmpty()) {
            return "Name is required";
        }
        if (profile.getQmId() == null || profile.getQmId().trim().isEmpty()) {
            return "QM ID is required";
        }
        if (profile.getBuptId() == null || profile.getBuptId().trim().isEmpty()) {
            return "BUPT ID is required";
        }
        if (profile.getMajorProgramme() == null || profile.getMajorProgramme().trim().isEmpty()) {
            return "Major/Programme is required";
        }
        if (profile.getGrade() == null || profile.getGrade().trim().isEmpty()) {
            return "Grade is required";
        }
        return null;
    }

    private void prepareJsonResponse(HttpServletResponse response) {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }

    private String resolveEnrollmentNo(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user != null && user.getEnrollmentNo() != null && !user.getEnrollmentNo().trim().isEmpty()) {
            return user.getEnrollmentNo().trim();
        }

        String enrollmentNo = (String) session.getAttribute("enrollment_no");
        return enrollmentNo == null ? null : enrollmentNo.trim();
    }

    private void safeFlush(HttpServletResponse response, String operation) {
        try {
            response.flushBuffer();
        } catch (Exception flushException) {
            System.err.println("[StudentProfileApiServlet " + operation + "] Flush failed: "
                    + flushException.getMessage());
        }
    }

    /**
     * Small JSON payload used for success and error responses.
     */
    static class ApiResponse {
        boolean success;
        String message;

        ApiResponse(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
}
