package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class StudentResumeUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new Gson();
    private static final String RESUME_RELATIVE_DIR = "resumes";
    private static final Path RESOURCES_ABSOLUTE_DIR = Paths.get(
            "D:\\Group15_TA_SYSTEM-new\\Group15_TA_SYSTEM-ChenyuZhang-AD-01new\\TA_System\\src\\main\\resources"
    );

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                return;
            }

            User user = (User) session.getAttribute("user");
            String enrollmentNo = null;
            if (user != null && user.getEnrollmentNo() != null && !user.getEnrollmentNo().trim().isEmpty()) {
                enrollmentNo = user.getEnrollmentNo().trim();
            } else {
                enrollmentNo = (String) session.getAttribute("enrollment_no");
                if (enrollmentNo != null) {
                    enrollmentNo = enrollmentNo.trim();
                }
            }

            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                return;
            }

            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "No file selected")));
                return;
            }

            String fileName = extractFileName(filePart);
            String contentType = filePart.getContentType();
            long fileSize = filePart.getSize();

            if (!isValidFileType(fileName, contentType)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Only PDF/DOC/DOCX files are allowed")));
                return;
            }

            if (fileSize > 10 * 1024 * 1024) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "File too large (max 10MB)")));
                return;
            }

            Path resumeDir = RESOURCES_ABSOLUTE_DIR.resolve(RESUME_RELATIVE_DIR).normalize();
            Files.createDirectories(resumeDir);

            String fileExtension = getFileExtension(fileName);
            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;
            Path target = resumeDir.resolve(uniqueFileName).normalize();

            if (!target.startsWith(resumeDir)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Invalid file path")));
                return;
            }

            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            StudentProfileDao profileDao = new StudentProfileDao();
            StudentProfile studentProfile = profileDao.getByEnrollment(enrollmentNo);
            if (studentProfile == null) {
                studentProfile = new StudentProfile();
                studentProfile.setEnrollmentNo(enrollmentNo);
            }

            String resumePath = RESUME_RELATIVE_DIR + "/" + uniqueFileName;
            studentProfile.setResumePath(resumePath);

            if (profileDao.save(studentProfile)) {
                response.getWriter().write(GSON.toJson(new ApiResponse(true, "File uploaded successfully", resumePath)));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Failed to update profile")));
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ApiResponse(false, "Upload error: " + e.getMessage())));
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return "upload_" + System.currentTimeMillis();
        }

        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "upload_" + System.currentTimeMillis();
    }

    private String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "bin";
        }
        return fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    }

    private boolean isValidFileType(String fileName, String contentType) {
        String[] allowedMimeTypes = {
                "application/pdf",
                "application/msword",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "application/vnd.ms-word.document.macroEnabled.12"
        };

        if (contentType != null) {
            for (String mimeType : allowedMimeTypes) {
                if (mimeType.equals(contentType)) {
                    return true;
                }
            }
        }

        if (fileName != null) {
            String extension = getFileExtension(fileName);
            return extension.equals("pdf") || extension.equals("doc") || extension.equals("docx");
        }

        return false;
    }

    static class ApiResponse {
        boolean success;
        String message;
        String path;

        ApiResponse(boolean success, String message) {
            this.success = success;
            this.message = message;
            this.path = null;
        }

        ApiResponse(boolean success, String message, String path) {
            this.success = success;
            this.message = message;
            this.path = path;
        }
    }
}
