//package com.me.finaldesignproject;
//
//import com.me.finaldesignproject.dao.StudentProfileDao;
//import com.me.finaldesignproject.model.StudentProfile;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//
//import java.io.File;
//import java.io.FileInputStream;
//import java.io.IOException;
//import java.io.OutputStream;
//import java.nio.file.Files;
//import java.nio.file.Path;
//import java.nio.file.Paths;
//
//public class DownloadResumeServlet extends HttpServlet {
//
//    // 鉁?绉婚櫎鍘熸湰鍐欐鐨勯潤鎬?Path锛屾敼涓哄湪 doGet 鍐呴儴鍔ㄦ€佽В鏋?
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        String enrollmentNo = request.getParameter("enrollment_no");
//        if (enrollmentNo == null || enrollmentNo.trim().isEmpty()) {
//            response.getWriter().write("Enrollment number is missing.");
//            return;
//        }
//
//        StudentProfileDao studentProfileDao = new StudentProfileDao();
//        StudentProfile profile = studentProfileDao.getByEnrollment(enrollmentNo.trim());
//
//        if (profile == null || profile.getResumePath() == null || profile.getResumePath().trim().isEmpty()) {
//            response.getWriter().write("Resume path not found in profile.");
//            return;
//        }
//
//        String storedPath = profile.getResumePath().trim();
//
//        // 鉁?鏍稿績淇敼鐐癸細鍔ㄦ€佽幏鍙?resources 鐩綍鐨勭浉瀵硅矾寰?
//        // 瀹冧細鑷姩鏍规嵁 Tomcat 閮ㄧ讲浣嶇疆鎵惧埌姝ｇ‘鐨?resources 鏂囦欢澶?
//        String baseDir = getServletContext().getRealPath("/WEB-INF/classes/");
//        Path resourcesDir = Paths.get(baseDir);
//
//        File file = resolveResumeFile(storedPath, resourcesDir);
//
//        if (file == null || !file.exists() || !file.isFile()) {
//            response.getWriter().write("Resume file not found on server.");
//            return;
//        }
//
//        String lowerName = file.getName().toLowerCase();
//        if (lowerName.endsWith(".pdf")) {
//            response.setContentType("application/pdf");
//        } else if (lowerName.endsWith(".doc")) {
//            response.setContentType("application/msword");
//        } else if (lowerName.endsWith(".docx")) {
//            response.setContentType("application/vnd.openxmlformats-officedocument.wordprocessingml.document");
//        } else {
//            response.setContentType("application/octet-stream");
//        }
//
//        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
//        response.setContentLengthLong(file.length());
//
//        try (FileInputStream fis = new FileInputStream(file);
//             OutputStream os = response.getOutputStream()) {
//            byte[] buffer = new byte[8192];
//            int bytesRead;
//            while ((bytesRead = fis.read(buffer)) != -1) {
//                os.write(buffer, 0, bytesRead);
//            }
//            os.flush();
//        }
//    }
//
//    // 鉁?鏍稿績淇敼鐐癸細浼犲叆鍔ㄦ€佽幏鍙栫殑 resourcesDir
//    private File resolveResumeFile(String resumePath, Path resourcesDir) {
//        String normalized = resumePath.replace("\\", "/");
//        if (normalized.startsWith("/")) {
//            normalized = normalized.substring(1);
//        }
//
//        Path resourcesDirNormalized = resourcesDir.normalize();
//
//        Path candidate = resourcesDirNormalized.resolve(normalized).normalize();
//        if (candidate.startsWith(resourcesDirNormalized) && Files.exists(candidate)) {
//            return candidate.toFile();
//        }
//
//        // Backward compatibility for old records like uploads/resumes/xxx.pdf.
//        if (normalized.startsWith("uploads/")) {
//            String withoutUploads = normalized.substring("uploads/".length());
//            Path upgraded = resourcesDirNormalized.resolve(withoutUploads).normalize();
//            if (upgraded.startsWith(resourcesDirNormalized) && Files.exists(upgraded)) {
//                return upgraded.toFile();
//            }
//        }
//
//        return null;
//    }
//}

package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet that streams an uploaded student resume to the client.
 */
public class DownloadResumeServlet extends HttpServlet {

    /**
     * Validates the requested resume and streams the stored file to the browser.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 鑾峰彇瑕佹煡鐪嬬殑瀛﹀彿
        String enrollmentNo = request.getParameter("enrollment_no");
        if (enrollmentNo == null || enrollmentNo.trim().isEmpty()) {
            response.getWriter().write("Enrollment number is missing.");
            return;
        }

        // 2. 鏌ユ暟鎹簱锛岃幏鍙栫畝鍘嗙浉瀵硅矾寰?
        StudentProfileDao studentProfileDao = new StudentProfileDao();
        StudentProfile profile = studentProfileDao.getByEnrollment(enrollmentNo.trim());

        if (profile == null || profile.getResumePath() == null || profile.getResumePath().trim().isEmpty()) {
            response.getWriter().write("Resume path not found in profile.");
            return;
        }

        // 鉁?鏍稿績淇敼鐐癸細鍥犱负鏂囦欢鐜板湪鏄叕寮€鐨勯潤鎬佽祫婧愶紝鐩存帴閲嶅畾鍚戝埌璇ユ枃浠剁殑 URL 鍗冲彲锛?
        // 褰诲簳鎶涘純绻佺悙鐨?FileInputStream 鍜屽悇绉嶅ご鏂囦欢璁剧疆锛屾湇鍔″櫒鐬棿鍑忚礋锛?
        String resumeUrl = request.getContextPath() + "/" + profile.getResumePath().trim();
        response.sendRedirect(resumeUrl);
    }
}

