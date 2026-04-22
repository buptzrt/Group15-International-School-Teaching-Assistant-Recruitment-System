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

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        super.doGet(request, response);
    }

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

//            // ✅ 核心修改点：彻底移除 E:\ 绝对路径，改用双路同步
//            List<Path> uploadPaths = new ArrayList<>();
//
//            // 1. 获取 Target 路径（Tomcat 运行时的路径，保证点击即开）
//            String baseDir = getServletContext().getRealPath("/WEB-INF/classes/");
//            if (baseDir != null) {
//                uploadPaths.add(Paths.get(baseDir).resolve(RESUME_RELATIVE_DIR).normalize());
//            }
//
//            // 2. 获取 Src 路径（动态获取当前项目源码位置，保证数据永久保存）
//            String projectRoot = System.getProperty("user.dir");
//            if (projectRoot != null) {
//                // 自动判断是在根目录运行还是子模块运行
//                File srcFile = new File(projectRoot, "TA_System/src/main/resources/" + RESUME_RELATIVE_DIR);
//                if (!srcFile.getParentFile().exists()) {
//                    srcFile = new File(projectRoot, "src/main/resources/" + RESUME_RELATIVE_DIR);
//                }
//                uploadPaths.add(srcFile.toPath().normalize());
//            }
//
//            String fileExtension = getFileExtension(fileName);
//            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;
//
//            // 执行多路径同步保存
//            for (Path resumeDir : uploadPaths) {
//                if (!Files.exists(resumeDir)) {
//                    Files.createDirectories(resumeDir);
//                }
//                Path targetFile = resumeDir.resolve(uniqueFileName).normalize();
//
//                try (InputStream in = filePart.getInputStream()) {
//                    Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
//                }
//            }

//            // ✅ 核心修改点：改用 webapp 目录，并且开启双路同步写入 (Dual-Save)
//            List<Path> uploadPaths = new ArrayList<>();
//
//            // ---------------------------------------------------------
//            // 路径 1：Tomcat 运行时路径 (对应你看到的 target 目录)
//            // 作用：解决"实时更新"，上传完立刻在网页上点击 View 就能看到，不报 404
//            // ---------------------------------------------------------
//            String runtimeBaseDir = getServletContext().getRealPath("/");
//            if (runtimeBaseDir != null) {
//                uploadPaths.add(Paths.get(runtimeBaseDir).resolve(RESUME_RELATIVE_DIR).normalize());
//            }
//
//            // ---------------------------------------------------------
//            // 路径 2：项目源码相对路径 (对应你电脑上的 src 目录)
//            // 作用：解决"Git同步"，别人拉代码不会丢失，重启 Tomcat 也不丢失
//            // ---------------------------------------------------------
//            String projectRoot = System.getProperty("user.dir"); // 动态获取当前项目的根目录
//            if (projectRoot != null) {
//                // 标准相对路径
//                File srcFolder = new File(projectRoot, "src/main/webapp/" + RESUME_RELATIVE_DIR);
//
//                // 兼容你的单层嵌套 (如果IDEA打开的外层目录)
//                if (!srcFolder.getParentFile().exists()) {
//                    srcFolder = new File(projectRoot, "TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
//                }
//
//                // 兼容你的双层嵌套 (TA_System/TA_System)
//                if (!srcFolder.getParentFile().exists()) {
//                    srcFolder = new File(projectRoot, "TA_System/TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
//                }
//
//                uploadPaths.add(srcFolder.toPath().normalize());
//            }
//
//            String fileExtension = getFileExtension(fileName);
//            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;
//
//            // ---------------------------------------------------------
//            // 执行双路同步保存
//            // ---------------------------------------------------------
//            for (Path resumeDir : uploadPaths) {
//                // 如果 resumes 文件夹不存在，自动创建它
//                if (!Files.exists(resumeDir)) {
//                    Files.createDirectories(resumeDir);
//                }
//
//                Path targetFile = resumeDir.resolve(uniqueFileName).normalize();
//
//                // 将用户上传的 PDF 复制到目标路径
//                try (InputStream in = filePart.getInputStream()) {
//                    Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
//                }
//                System.out.println("[ResumeUpload] 成功保存简历至: " + targetFile.toAbsolutePath());
//            }

// ✅ 核心修改点：改用 webapp 目录，并且开启双路同步写入 (Dual-Save)
            List<Path> uploadPaths = new ArrayList<>();

            // ---------------------------------------------------------
            // 路径 1：Tomcat 运行时路径 (对应 IDEA 的 out/artifacts 目录)
            // 作用：解决"实时更新"，上传完立刻在网页上点击 View 就能看到
            // ---------------------------------------------------------
            String runtimeBaseDir = getServletContext().getRealPath("/");
            if (runtimeBaseDir != null) {
                uploadPaths.add(Paths.get(runtimeBaseDir).resolve(RESUME_RELATIVE_DIR).normalize());

                // ---------------------------------------------------------
                // 路径 2：项目源码相对路径 (顺藤摸瓜找 src)
                // 作用：解决"Git同步"，存入 D 盘源码，别人拉代码不丢失
                // ---------------------------------------------------------
                // 兼容 Maven 的 target 目录
                int targetIndex = runtimeBaseDir.indexOf(File.separator + "target" + File.separator);
                if (targetIndex == -1) targetIndex = runtimeBaseDir.indexOf("/target/");

                // 兼容 IDEA 的 out/artifacts 目录
                int outIndex = runtimeBaseDir.indexOf(File.separator + "out" + File.separator + "artifacts");
                if (outIndex == -1) outIndex = runtimeBaseDir.indexOf("/out/artifacts");

                String projectRootPath = null;
                if (targetIndex != -1) {
                    projectRootPath = runtimeBaseDir.substring(0, targetIndex);
                } else if (outIndex != -1) {
                    projectRootPath = runtimeBaseDir.substring(0, outIndex);
                }

                if (projectRootPath != null) {
                    // 精准拼接回你心心念念的 src 目录！
                    File srcFolder = new File(projectRootPath, "src/main/webapp/" + RESUME_RELATIVE_DIR);

                    // 兼容你的单层嵌套
                    if (!srcFolder.getParentFile().exists()) {
                        srcFolder = new File(projectRootPath, "TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
                    }
                    // 兼容你的双层嵌套
                    if (!srcFolder.getParentFile().exists()) {
                        srcFolder = new File(projectRootPath, "TA_System/TA_System/src/main/webapp/" + RESUME_RELATIVE_DIR);
                    }

                    uploadPaths.add(srcFolder.toPath().normalize());
                    System.out.println("[ResumeUpload] 成功锁定源码目录: " + srcFolder.getAbsolutePath());
                } else {
                    System.err.println("[ResumeUpload] 警告：无法在运行路径中找到 target 或 out/artifacts 目录，源码同步可能失败！");
                }
            }

            String fileExtension = getFileExtension(fileName);
            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;

            // ---------------------------------------------------------
            // 执行双路同步保存
            // ---------------------------------------------------------
            for (Path resumeDir : uploadPaths) {
                if (!Files.exists(resumeDir)) {
                    Files.createDirectories(resumeDir);
                }

                Path targetFile = resumeDir.resolve(uniqueFileName).normalize();

                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, targetFile, StandardCopyOption.REPLACE_EXISTING);
                }
                System.out.println("[ResumeUpload] 成功保存简历至: " + targetFile.toAbsolutePath());
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
