package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.me.finaldesignproject.dao.TaProfileDao;
import com.me.finaldesignproject.model.TaProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

public class TaProfileApiServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();
    private final TaProfileDao dao = new TaProfileDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("application/json;charset=UTF-8");

        User user = requireStudentOrTa(req, resp);
        if (user == null) {
            return;
        }

        String enrollmentNo = user.getEnrollmentNo();
        TaProfile profile = dao.getByEnrollment(enrollmentNo);
        if (profile == null) {
            profile = new TaProfile();
            profile.setEnrollmentNo(enrollmentNo);
            profile.setFullName(user.getFullName());
            profile.setBuptId(enrollmentNo);
            profile.setStudentId(enrollmentNo); // compatibility field
        }
        gson.toJson(profile, resp.getWriter());
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("application/json;charset=UTF-8");

        User user = requireStudentOrTa(req, resp);
        if (user == null) {
            return;
        }

        String body;
        try (Scanner scanner = new Scanner(req.getInputStream(), StandardCharsets.UTF_8).useDelimiter("\\A")) {
            body = scanner.hasNext() ? scanner.next() : "";
        }

        TaProfile incoming = gson.fromJson(body, TaProfile.class);
        if (incoming == null) {
            error(resp, 400, "Invalid request body.");
            return;
        }

        String enrollmentNo = user.getEnrollmentNo();
        incoming.setEnrollmentNo(enrollmentNo);
        if (incoming.getBuptId() == null || incoming.getBuptId().isBlank()) {
            incoming.setBuptId(enrollmentNo);
        }
        if (incoming.getStudentId() == null || incoming.getStudentId().isBlank()) {
            incoming.setStudentId(enrollmentNo);
        }

        String validationError = validate(incoming);
        if (validationError != null) {
            error(resp, 400, validationError);
            return;
        }

        if (!dao.save(incoming)) {
            error(resp, 500, "Failed to save profile data.");
            return;
        }

        JsonObject ok = new JsonObject();
        ok.addProperty("success", true);
        ok.addProperty("message", "Profile saved successfully.");
        gson.toJson(ok, resp.getWriter());
    }

    private User requireStudentOrTa(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            error(resp, 401, "Please log in first.");
            return null;
        }

        String role = (String) session.getAttribute("role");
        boolean ok = role != null && ("TA".equalsIgnoreCase(role.trim()) || "Student".equalsIgnoreCase(role.trim()));
        if (!ok) {
            error(resp, 403, "Student or TA access is required.");
            return null;
        }

        User user = (User) session.getAttribute("user");
        if (user == null || user.getEnrollmentNo() == null || user.getEnrollmentNo().isBlank()) {
            error(resp, 401, "Session is invalid.");
            return null;
        }
        return user;
    }

    private String validate(TaProfile profile) {
        if (isBlank(profile.getFullName())) return "Name is required.";
        if (isBlank(profile.getEmail())) return "Email is required.";
        if (isBlank(profile.getBuptId())) return "BUPT ID is required.";
        if (isBlank(profile.getQmId())) return "QM ID is required.";
        if (isBlank(profile.getMajorProgramme())) return "Major / Programme is required.";
        if (isBlank(profile.getGrade())) return "Grade is required.";
        return null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void error(HttpServletResponse resp, int statusCode, String message) throws IOException {
        resp.setStatus(statusCode);
        JsonObject payload = new JsonObject();
        payload.addProperty("success", false);
        payload.addProperty("message", message);
        gson.toJson(payload, resp.getWriter());
    }
}
