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

        // 从JSON文件读取简历路径
        StudentProfileDao studentProfileDao = new StudentProfileDao();
        StudentProfile profile = studentProfileDao.getByEnrollment(enrollmentNo.trim());

        if (profile == null || profile.getResumePath() == null || profile.getResumePath().trim().isEmpty()) {
            response.getWriter().write("Resume path not found in profile.");
            return;
        }

        String resumePath = profile.getResumePath();
        File file = null;

        // ✅ 核心修改点：优先从 Tomcat 部署目录（target/webapp）获取文件
        String appRoot = getServletContext().getRealPath("/");
        if (appRoot != null) {
            String normalizedPath = resumePath.replace("\\", File.separator).replace("/", File.separator);
            file = new File(appRoot, normalizedPath);
        }

        // ✅ 核心修改点：如果 target 下没找到，再尝试 project 物理路径作为备份
        if (file == null || !file.exists()) {
            String backupPath = "E:\\Group15_TA_SYSTEM\\TA_System\\src\\main\\webapp\\" + resumePath;
            file = new File(backupPath);
        }

        if (!file.exists()) {
            response.getWriter().write("Resume file not found on server.");
            return;
        }

        // ✅ 核心修改点：将 Content-Disposition 改为 inline，这样点击链接会直接在浏览器预览 PDF 而不是下载
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        response.setContentLength((int) file.length());

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error downloading file: " + e.getMessage());
        }
    }
}