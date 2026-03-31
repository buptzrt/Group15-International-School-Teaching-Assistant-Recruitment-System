package com.me.finaldesignproject;

import com.google.gson.JsonObject;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Objects;

@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10 MB
public class TaResumeUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss", Locale.ENGLISH);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = requireStudentOrTa(req, resp);
        if (user == null) {
            return;
        }

        Part filePart = req.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            error(resp, 400, "No file uploaded.");
            return;
        }
        String contentType = filePart.getContentType();
        String submitted = Objects.toString(filePart.getSubmittedFileName(), "");
        String lower = submitted.toLowerCase(Locale.ROOT);
        boolean extOk = lower.endsWith(".pdf") || lower.endsWith(".doc") || lower.endsWith(".docx");
        boolean typeOk = "application/pdf".equalsIgnoreCase(contentType)
                || "application/msword".equalsIgnoreCase(contentType)
                || "application/vnd.openxmlformats-officedocument.wordprocessingml.document".equalsIgnoreCase(contentType);
        if (!extOk && !typeOk) {
            error(resp, 400, "Only PDF or Word files are allowed.");
            return;
        }

        String baseDir = resolveUploadDir(req);
        Files.createDirectories(Paths.get(baseDir));

        String original = Paths.get(submitted.isEmpty() ? "resume.pdf" : submitted).getFileName().toString();
        String safeName = original.replaceAll("[^a-zA-Z0-9_.-]", "_");
        String filename = user.getEnrollmentNo() + "_" + FORMAT.format(LocalDateTime.now()) + "_" + safeName;
        Path target = Paths.get(baseDir, filename);

        filePart.write(target.toString());

        JsonObject ok = new JsonObject();
        ok.addProperty("success", true);
        ok.addProperty("message", "Upload succeeded.");
        ok.addProperty("path", "uploads/resumes/" + filename);
        resp.getWriter().write(ok.toString());
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
        if (user == null || user.getEnrollmentNo() == null) {
            error(resp, 401, "Session is invalid.");
            return null;
        }
        return user;
    }

    private String resolveUploadDir(HttpServletRequest req) {
        // Prefer an external writable folder to avoid writing inside packed WAR.
        String root = System.getProperty("user.dir");
        return Paths.get(root, "uploads", "resumes").toString();
    }

    private void error(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setStatus(status);
        JsonObject o = new JsonObject();
        o.addProperty("success", false);
        o.addProperty("message", msg);
        resp.getWriter().write(o.toString());
    }
}
