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

    // ✅ 移除原本写死的静态 Path，改为在 doGet 内部动态解析

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

        // ✅ 核心修改点：动态获取 resources 目录的相对路径
        // 它会自动根据 Tomcat 部署位置找到正确的 resources 文件夹
        String baseDir = getServletContext().getRealPath("/WEB-INF/classes/");
        Path resourcesDir = Paths.get(baseDir);

        File file = resolveResumeFile(storedPath, resourcesDir);

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

    // ✅ 核心修改点：传入动态获取的 resourcesDir
    private File resolveResumeFile(String resumePath, Path resourcesDir) {
        String normalized = resumePath.replace("\\", "/");
        if (normalized.startsWith("/")) {
            normalized = normalized.substring(1);
        }

        Path resourcesDirNormalized = resourcesDir.normalize();

        Path candidate = resourcesDirNormalized.resolve(normalized).normalize();
        if (candidate.startsWith(resourcesDirNormalized) && Files.exists(candidate)) {
            return candidate.toFile();
        }

        // Backward compatibility for old records like uploads/resumes/xxx.pdf.
        if (normalized.startsWith("uploads/")) {
            String withoutUploads = normalized.substring("uploads/".length());
            Path upgraded = resourcesDirNormalized.resolve(withoutUploads).normalize();
            if (upgraded.startsWith(resourcesDirNormalized) && Files.exists(upgraded)) {
                return upgraded.toFile();
            }
        }

        return null;
    }
}