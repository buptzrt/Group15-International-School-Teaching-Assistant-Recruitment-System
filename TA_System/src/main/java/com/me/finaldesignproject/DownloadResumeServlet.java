package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class DownloadResumeServlet extends HttpServlet {
    private static final Path RESOURCES_ABSOLUTE_DIR = Paths.get(
            "D:\\Group15_TA_SYSTEM-new\\Group15_TA_SYSTEM-ChenyuZhang-AD-01new\\TA_System\\src\\main\\resources"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enrollmentNo = request.getParameter("enrollment_no");
        if (enrollmentNo == null || enrollmentNo.trim().isEmpty()) {
            response.getWriter().write("Enrollment number is missing.");
            return;
        }

        StudentProfileDao studentProfileDao = new StudentProfileDao();
        StudentProfile profile = studentProfileDao.getByEnrollment(enrollmentNo.trim());

        if (profile == null || profile.getResumePath() == null || profile.getResumePath().trim().isEmpty()) {
            response.getWriter().write("Resume path not found in profile.");
            return;
        }

        String storedPath = profile.getResumePath().trim();
        File file = resolveResumeFile(storedPath);

        if (file == null || !file.exists() || !file.isFile()) {
            response.getWriter().write("Resume file not found on server.");
            return;
        }

        String lowerName = file.getName().toLowerCase();
        if (lowerName.endsWith(".pdf")) {
            response.setContentType("application/pdf");
        } else if (lowerName.endsWith(".doc")) {
            response.setContentType("application/msword");
        } else if (lowerName.endsWith(".docx")) {
            response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
        } else {
            response.setContentType("application/octet-stream");
        }

        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setContentLengthLong(file.length());

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }
    }

    private File resolveResumeFile(String resumePath) {
        String normalized = resumePath.replace("\\", "/");
        if (normalized.startsWith("/")) {
            normalized = normalized.substring(1);
        }

        Path resourcesDir = RESOURCES_ABSOLUTE_DIR.normalize();

        Path candidate = resourcesDir.resolve(normalized).normalize();
        if (candidate.startsWith(resourcesDir) && Files.exists(candidate)) {
            return candidate.toFile();
        }

        // Backward compatibility for old records like uploads/resumes/xxx.pdf.
        if (normalized.startsWith("uploads/")) {
            String withoutUploads = normalized.substring("uploads/".length());
            Path upgraded = resourcesDir.resolve(withoutUploads).normalize();
            if (upgraded.startsWith(resourcesDir) && Files.exists(upgraded)) {
                return upgraded.toFile();
            }
        }

        return null;
    }
}
