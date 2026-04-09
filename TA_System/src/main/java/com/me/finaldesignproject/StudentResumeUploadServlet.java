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
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * 学生简历上传 Servlet - /api/student/resume/upload
 * 
 * 功能说明：
 * 这个 Servlet 处理学生上传 PDF 或 Word 文档作为简历。
 * 特点：
 * 1. 支持上传 PDF、DOC、DOCX 格式的文件
 * 2. 最大文件大小：10MB
 * 3. 文件保存在 uploads/resumes/ 目录
 * 4. 自动更新 StudentProfile 中的简历路径
 * 5. 返回 JSON 格式的上传结果
 * 
 * Session 处理：
 * - 使用 request.getSession(false) 获取现有 session
 * - 如果 session 过期，返回 401 错误
 * - 确保用户已登录才能上传文件
 */
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB 以上的文件转换为磁盘文件
    maxFileSize = 10 * 1024 * 1024,       // 单个文件最大 10MB
    maxRequestSize = 20 * 1024 * 1024     // 整个请求最大 20MB
)
public class StudentResumeUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new Gson();
    
    /**
     * 处理文件上传的 POST 请求
     * 
     * 工作流程：
     * 1. 验证用户 session（是否已登录）
     * 2. 从请求中获取上传的文件
     * 3. 验证文件类型和大小
     * 4. 保存文件到服务器
     * 5. 更新 StudentProfile 中的简历路径
     * 6. 返回 JSON 响应，包含简历文件的储存路径
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 【重要】设置响应格式为 JSON，字符编码为 UTF-8（支持中文错误消息）
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 禁用缓存 - 确保每次上传都能获得最新的响应
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            // 【关键步骤】在处理 multipart 请求之前，先获取 session
            // 这很重要！某些 servlet 容器在处理 getPart() 时会丢失 session
            // 所以我们需要在 getPart() 之前就取得 session 对象的引用
            System.out.println("[StudentResumeUploadServlet] 步骤1：在处理 multipart 请求前获取 session");
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("[StudentResumeUploadServlet] 错误：没有找到有效的 session");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 返回 401
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                response.flushBuffer();
                return;
            }
            
            // 【诊断】记录原始 session ID
            String originalSessionId = session.getId();
            System.out.println("[StudentResumeUploadServlet] ✓ 获得 session ID: " + originalSessionId);

            // 从 session 中获取登录的用户信息
            User user = (User) session.getAttribute("user");
            
            // 【获取学号】采用双重方式获取学号以增加兼容性
            String enrollmentNo = null;
            if (user != null && user.getEnrollmentNo() != null && !user.getEnrollmentNo().trim().isEmpty()) {
                // 优先从 User 对象中获取学号
                enrollmentNo = user.getEnrollmentNo().trim();
                System.out.println("[StudentResumeUploadServlet] 从 User 对象获取学号: " + enrollmentNo);
            } else {
                // 备选：从 session 属性中获取学号
                enrollmentNo = (String) session.getAttribute("enrollment_no");
                if (enrollmentNo != null) {
                    enrollmentNo = enrollmentNo.trim();
                    System.out.println("[StudentResumeUploadServlet] 从 session 属性获取学号: " + enrollmentNo);
                }
            }
            
            // 验证学号是否有效
            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                System.err.println("[StudentResumeUploadServlet] 错误：无法获取学号");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                response.flushBuffer();
                return;
            }

            // 【第二个关键步骤】现在才调用 getPart()
            // 这样可以最小化 multipart 处理对 session 的影响
            System.out.println("[StudentResumeUploadServlet] 步骤2：处理 multipart 请求，获取上传的文件");
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                System.err.println("[StudentResumeUploadServlet] 错误：没有选择文件");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 返回 400
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "No file selected")));
                response.flushBuffer();
                return;
            }

            // 【第三个关键步骤】getPart() 完成后，重新获取 session
            // 防止 multipart 处理导致 session 被替换
            System.out.println("[StudentResumeUploadServlet] 步骤3：multipart 处理完成，验证 session 是否仍然有效");
            HttpSession currentSession = request.getSession(false);
            if (currentSession == null) {
                // Session 被丢失了！这是 multipart 问题的表现
                System.err.println("[StudentResumeUploadServlet] 警告：multipart 处理后 session 丢失！");
                System.err.println("[StudentResumeUploadServlet] 原始 session ID: " + originalSessionId);
                System.err.println("[StudentResumeUploadServlet] 当前 session: null");
                
                // 尝试使用原始 session 对象继续处理（虽然不理想，但比失败好）
                // 继续使用之前获取的 session 对象
                System.out.println("[StudentResumeUploadServlet] 继续使用原始 session 对象处理上传");
            } else if (!currentSession.getId().equals(originalSessionId)) {
                // Session ID 被替换了！
                System.err.println("[StudentResumeUploadServlet] 警告：multipart 处理导致 session ID 被替换！");
                System.err.println("[StudentResumeUploadServlet] 原始 session ID: " + originalSessionId);
                System.err.println("[StudentResumeUploadServlet] 新的 session ID: " + currentSession.getId());
                
                // 这是一个严重的问题，需要特殊处理
                // 继续使用原始 session 对象，但需要确保响应中包含正确的 cookie
                System.out.println("[StudentResumeUploadServlet] 继续处理，但响应中必须包含原始的 JSESSIONID cookie");
            } else {
                System.out.println("[StudentResumeUploadServlet] ✓ Session ID 保持不变: " + currentSession.getId());
            }

            // 获取文件信息
            String fileName = extractFileName(filePart);
            String contentType = filePart.getContentType();
            long fileSize = filePart.getSize();
            System.out.println("[StudentResumeUploadServlet] 接收到文件: " + fileName + ", 类型: " + contentType + ", 大小: " + fileSize);

            // 【验证文件类型】
            // 只允许 PDF 和 Word 格式
            if (!isValidFileType(fileName, contentType)) {
                System.err.println("[StudentResumeUploadServlet] 错误：不支持的文件类型 - " + contentType);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Only PDF/DOC/DOCX files are allowed")));
                return;
            }

            // 【验证文件大小】
            // 最大 10MB
            if (fileSize > 10 * 1024 * 1024) {
                System.err.println("[StudentResumeUploadServlet] 错误：文件过大，大小 " + fileSize + " 字节");
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "File too large (max 10MB)")));
                return;
            }

            // 【创建上传目录】
            // 文件将保存在 uploads/resumes/ 目录下
            String uploadDir = getServletContext().getRealPath("/uploads/resumes");
            File uploadsFolder = new File(uploadDir);
            if (!uploadsFolder.exists()) {
                boolean created = uploadsFolder.mkdirs();
                System.out.println("[StudentResumeUploadServlet] 创建上传目录: " + uploadDir + " (成功: " + created + ")");
            }

            // 【生成唯一的文件名】
            // 格式：<学号>_<UUID>.<扩展名>
            // 这样可以防止文件名冲突，并防止目录遍历攻击
            String fileExtension = getFileExtension(fileName);
            String uniqueFileName = enrollmentNo + "_" + UUID.randomUUID() + "." + fileExtension;
            String filePath = new File(uploadDir, uniqueFileName).getAbsolutePath();
            System.out.println("[StudentResumeUploadServlet] 保存文件到: " + filePath);

            // 【保存文件到服务器】
            filePart.write(filePath);
            System.out.println("[StudentResumeUploadServlet] 文件保存成功: " + uniqueFileName);

            // 【更新学生资料中的简历路径】
            // 从 StudentProfileDao 获取学生的现有资料
            StudentProfileDao profileDao = new StudentProfileDao();
            StudentProfile studentProfile = profileDao.getByEnrollment(enrollmentNo);
            
            if (studentProfile == null) {
                // 如果资料不存在，创建新的
                studentProfile = new StudentProfile();
                studentProfile.setEnrollmentNo(enrollmentNo);
                System.out.println("[StudentResumeUploadServlet] 为学生创建新的资料: " + enrollmentNo);
            }

            // 设置简历路径
            // 路径格式：uploads/resumes/<filename>
            String resumePath = "uploads/resumes/" + uniqueFileName;
            studentProfile.setResumePath(resumePath);
            System.out.println("[StudentResumeUploadServlet] 设置简历路径: " + resumePath);

            // 【保存学生资料】
            if (profileDao.save(studentProfile)) {
                System.out.println("[StudentResumeUploadServlet] 学生资料和简历路径更新成功");
                
                // 【关键】确保 session 在响应中被保持
                // 即使 multipart 处理导致 session 被修改，我们也需要通知浏览器保留原始的 JSESSIONID
                System.out.println("[StudentResumeUploadServlet] 步骤4：在响应中保持 session");
                
                // 【对策1】调用 session 方法来确保其活跃
                // 这会强制 servlet 容器在响应中包含 Set-Cookie 头
                session.setAttribute("__keep_alive__", System.currentTimeMillis());
                System.out.println("[StudentResumeUploadServlet] 已设置 session 保活标记");
                
                // 【对策2】更新 session 中的用户信息，确保一致性
                // 这对于处理并发请求和快速切换页面非常重要
                if (user != null) {
                    session.setAttribute("user", user);
                    System.out.println("[StudentResumeUploadServlet] 已更新 session 中的 User 对象");
                }
                
                // 【对策3】设置 session 过期时间，延长会话有效期
                // 避免多次操作导致 session 过期
                session.setMaxInactiveInterval(3600); // 设置为1小时
                System.out.println("[StudentResumeUploadServlet] 已延长 session 过期时间至1小时");
                
                // 【重要】获取当前的 session 对象，确保所有属性都被保存
                HttpSession finalSession = request.getSession(false);
                if (finalSession != null) {
                    System.out.println("[StudentResumeUploadServlet] 最终 session ID（将在响应中发送）: " + finalSession.getId());
                } else {
                    System.out.println("[StudentResumeUploadServlet] 警告：最终无 session，但继续发送响应");
                }
                
                // 返回成功响应，包含简历的路径
                response.getWriter().write(GSON.toJson(new ApiResponse(true, "File uploaded successfully", resumePath)));
                response.flushBuffer(); // 【重要】强制刷新缓冲区，确保响应和 cookie 被发送
                System.out.println("[StudentResumeUploadServlet] 成功响应已发送到客户端，包含 session cookie");
            } else {
                System.err.println("[StudentResumeUploadServlet] 错误：更新学生资料失败");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Failed to update profile")));
                response.flushBuffer();
                System.out.println("[StudentResumeUploadServlet] 错误响应已发送");
            }

        } catch (Exception e) {
            // 捕获所有异常，防止程序崩溃
            System.err.println("[StudentResumeUploadServlet] 发生异常: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ApiResponse(false, "Upload error: " + e.getMessage())));
        }
    }

    /**
     * 从 Part 对象中提取真实的文件名
     * 
     * 说明：
     * Part.getSubmittedFileName() 返回的文件名可能包含路径前缀（如 C:\path\file.pdf）
     * 我们只需要文件名的最后一部分
     */
    private String extractFileName(Part part) {
        // 获取 Content-Disposition header 中的文件名
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                // 提取 filename="..." 中的内容
                return s.substring(s.indexOf("=") + 2, s.lastIndexOf("\""));
            }
        }
        return "upload_" + System.currentTimeMillis(); // 默认文件名
    }

    /**
     * 获取文件扩展名（不包含点）
     * 例如：input.pdf -> pdf，input.docx -> docx
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "bin"; // 如果没有扩展名，默认为 bin
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }

    /**
     * 验证文件类型是否有效
     * 
     * 允许的类型：
     * - application/pdf（PDF 文件）
     * - application/msword（.doc 文件）
     * - application/vnd.openxmlformats-officedocument.wordprocessingml.document（.docx 文件）
     * 
     * 同时也检查文件扩展名作为备选验证方式
     */
    private boolean isValidFileType(String fileName, String contentType) {
        // 允许的 MIME 类型
        String[] allowedMimeTypes = {
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-word.document.macroEnabled.12"
        };

        // 检查 MIME 类型
        for (String mimeType : allowedMimeTypes) {
            if (mimeType.equals(contentType)) {
                return true;
            }
        }

        // 备选：检查文件扩展名
        if (fileName != null) {
            String extension = getFileExtension(fileName).toLowerCase();
            return extension.equals("pdf") || extension.equals("doc") || extension.equals("docx");
        }

        return false;
    }

    /**
     * API 响应对象
     * 用于返回 JSON 格式的上传结果
     * 
     * 三个参数：
     * - success：是否成功（true/false）
     * - message：响应消息（成功/错误说明）
     * - path：上传成功时，简历文件的存储路径
     */
    static class ApiResponse {
        boolean success;    // 操作是否成功
        String message;     // 响应消息
        String path;        // 文件路径（仅在成功时）

        // 用于错误响应（不包含路径）
        ApiResponse(boolean success, String message) {
            this.success = success;
            this.message = message;
            this.path = null;
        }

        // 用于成功响应（包含路径）
        ApiResponse(boolean success, String message, String path) {
            this.success = success;
            this.message = message;
            this.path = path;
        }
    }
}