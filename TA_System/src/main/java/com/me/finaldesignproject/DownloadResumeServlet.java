package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class DownloadResumeServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enrollmentNo = request.getParameter("enrollment_no");

        if (enrollmentNo == null || enrollmentNo.trim().isEmpty()) {
            response.getWriter().write("Enrollment number is missing.");
            return;
        }

        // 从JSON文件读取简历路径，而不是数据库
        StudentProfileDao studentProfileDao = new StudentProfileDao();
        StudentProfile profile = studentProfileDao.getByEnrollment(enrollmentNo.trim());

        if (profile == null || profile.getResumePath() == null || profile.getResumePath().trim().isEmpty()) {
            response.getWriter().write("Resume path not found in profile.");
            return;
        }

        String resumePath = profile.getResumePath();
        File file = new File(resumePath);

        // Support relative paths stored in JSON, e.g. uploads/resumes/file.pdf
        if (!file.isAbsolute()) {
            String appRoot = getServletContext().getRealPath("");
            String normalizedPath = resumePath.replace("\\", File.separator).replace("/", File.separator);
            file = new File(appRoot, normalizedPath);
        }

        // Fallback to project root uploads folder
        if (!file.exists()) {
            String projectRoot = System.getProperty("user.dir");
            String relativePath = resumePath.startsWith("uploads/") ? resumePath.substring("uploads/".length()) : resumePath;
            file = new File(projectRoot, "uploads" + File.separator + "resumes" + File.separator + relativePath);
        }

        // Final fallback: try from app root
        if (!file.exists()) {
            String appRoot = getServletContext().getRealPath("");
            if (appRoot != null && !appRoot.trim().isEmpty()) {
                file = new File(appRoot, resumePath);
            }
        }

        if (!file.exists()) {
            response.getWriter().write("Resume file not found at: " + resumePath);
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + "\"");

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error downloading file: " + e.getMessage());
        }
    }
}
