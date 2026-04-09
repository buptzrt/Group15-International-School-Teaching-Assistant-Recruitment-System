package com.me.finaldesignproject;

import com.google.gson.Gson;
import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Student Profile API Servlet - 学生资料 API 处理器
 * 
 * 此 Servlet 处理学生个人资料的读写操作，支持多次修改和平台（提供RESTful API接口）
 * 
 * 功能说明：
 * 1. GET /api/student/profile - 获取当前学生的个人资料（包括姓名、邮箱、技能等）
 * 2. POST/PUT /api/student/profile - 保存/更新当前学生的个人资料
 * 
 * Session 处理原理：
 * - 使用 request.getSession(false) 获取现有 session，不创建新的 session
 * - 这样可以确保多次修改时 session 保持一致
 * - 如果 session 为 null 说明用户未登录或登录已过期
 */
public class StudentProfileApiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Gson GSON = new Gson(); // JSON 序列化工具

    /**
     * 处理 GET 请求 - 获取学生资料
     * 
     * 流程：
     * 1. 获取用户的 session（不创建新的）
     * 2. 从 session 中获取用户信息和学号
     * 3. 从 StudentProfileDao 读取该学生的完整资料
     * 4. 返回 JSON 格式的资料给前端
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 设置响应格式为 JSON
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 禁用浏览器缓存 - 这样每次都能获取最新的学生资料
        // 如果不禁用缓存，第二次修改后可能显示的还是旧数据
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            // 【诊断】打印请求中的 JSESSIONID
            String jsessionid = request.getHeader("Cookie");
            System.out.println("[StudentProfileApiServlet GET] 请求 Cookie 头: " + jsessionid);
            
            // 【关键步骤】获取当前登录用户的 session
            // getSession(false) 表示：获取现有的 session，如果没有就返回 null（不创建新的）
            // 这很重要！如果用 getSession(true) 会自动创建新的 session，导致之前的 session 丢失
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("[StudentProfileApiServlet GET] ERROR: 无法获取 session，尝试了 getSession(false)，返回 null");
                System.err.println("[StudentProfileApiServlet GET] 这说明：用户未登录或 session 已在服务器端过期或被清理");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 返回 401 Unauthorized
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                response.flushBuffer(); // 强制刷新响应缓冲区
                return;
            }
            
            // 【诊断】打印 session ID
            System.out.println("[StudentProfileApiServlet GET] 获得 session ID: " + session.getId());

            // 从 session 中获取 User 对象（登录时保存的）
            User user = (User) session.getAttribute("user");
            
            // 获取学号 - 采用两种方式获取学号以增加兼容性
            // 方式1：从 User 对象中获取（推荐，因为 User 对象是登录时保存的）
            // 方式2：直接从 session 的 enrollment_no 属性获取（备选方案）
            String enrollmentNo = null;
            if (user != null && user.getEnrollmentNo() != null && !user.getEnrollmentNo().trim().isEmpty()) {
                // 优先使用 User 对象中的学号
                enrollmentNo = user.getEnrollmentNo().trim();
            } else {
                // 如果 User 对象不存在或学号为空，尝试从 session 属性获取
                enrollmentNo = (String) session.getAttribute("enrollment_no");
                if (enrollmentNo != null) {
                    enrollmentNo = enrollmentNo.trim();
                }
            }
            
            // 验证：学号不能为空，否则无法查询资料
            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                System.err.println("[StudentProfileApiServlet GET] ERROR: 学号为空，User 对象: " + (user != null) + ", enrollment_no: " + enrollmentNo);
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                response.flushBuffer();
                return;
            }

            System.out.println("[StudentProfileApiServlet GET] 准备读取学生资料，学号: " + enrollmentNo);
            // 【从数据库读取资料】
            // StudentProfileDao 负责从 student_profiles.json 文件读取该学生的资料
            StudentProfileDao profileDao = new StudentProfileDao();
            StudentProfile studentProfile = profileDao.getByEnrollment(enrollmentNo);

            // 如果资料不存在（比如是新学生还没填过资料），创建一个空的资料对象
            if (studentProfile == null) {
                System.out.println("[StudentProfileApiServlet GET] 数据库中没有该学生的资料，创建新对象");
                studentProfile = new StudentProfile();
                studentProfile.setEnrollmentNo(enrollmentNo);
            }

            // 将学生资料转换为 JSON 并返回给前端
            response.getWriter().write(GSON.toJson(studentProfile));
            response.flushBuffer(); // 强制刷新响应缓冲区
            System.out.println("[StudentProfileApiServlet GET] 成功返回学生资料，学号: " + enrollmentNo);
            
        } catch (Exception e) {
            System.err.println("[StudentProfileApiServlet GET] 发生异常: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(new ApiResponse(false, "Error loading profile: " + e.getMessage())));
            try {
                response.flushBuffer();
            } catch (Exception flush_e) {
                System.err.println("[StudentProfileApiServlet GET] 刷新响应时出错: " + flush_e.getMessage());
            }
        }
    }

    /**
     * 处理 POST 请求 - 保存学生资料（第一次提交时）
     * 就是把 POST 请求转发给 saveProfile 方法处理
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        saveProfile(request, response);
    }

    /**
     * 处理 PUT 请求 - 更新学生资料（修改已存在的资料时）
     * 就是把 PUT 请求转发给 saveProfile 方法处理
     * 
     * 为什么要同时支持 POST 和 PUT？
     * - POST：通常用于创建新资源
     * - PUT：通常用于更新已存在的资源
     * - 在我们的系统中，两者的处理逻辑相同，所以都转发给 saveProfile
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        saveProfile(request, response);
    }

    /**
     * 保存学生资料的通用方法 - 处理 POST 和 PUT 两种请求
     * 这是解决"多次修改时 session 过期"问题的关键方法
     * 
     * 流程：
     * 1. 获取用户的 session（验证用户是否登录）
     * 2. 从请求体读取前端发送的 JSON 数据
     * 3. 验证数据是否完整和有效
     * 4. 保存到 student_profiles.json 文件
     * 5. 返回成功/失败的消息
     */
    private void saveProfile(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 设置响应格式为 JSON，字符编码为 UTF-8（支持中文）
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 【重要】禁用缓存，确保每次都获取最新的数据
        // 如果不禁用，浏览器可能会缓存上一次的响应，导致修改后看不到效果
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            // 【诊断】打印请求中的 JSESSIONID
            String jsessionid = request.getHeader("Cookie");
            System.out.println("[StudentProfileApiServlet SAVE] 请求 Cookie 头: " + jsessionid);
            
            // 【关键步骤】获取当前用户的 session
            // 这里是 session 过期问题的重点：
            // - getSession(false) 获取现有的 session
            // - 如果用户已登录，session 应该存在
            // - 如果 session 为 null，说明登录已过期或从未登录
            HttpSession session = request.getSession(false);
            if (session == null) {
                System.err.println("[StudentProfileApiServlet SAVE] 错误：无法获取 session，尝试了 getSession(false)，返回 null");
                System.err.println("[StudentProfileApiServlet SAVE] 这说明：用户未登录或 session 在服务器端被清理或过期");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 返回 401
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Session expired")));
                response.flushBuffer(); // 强制刷新缓冲区
                return;
            }
            
            // 【诊断】打印 session ID
            System.out.println("[StudentProfileApiServlet SAVE] 成功获得 session ID: " + session.getId());

            // 从 session 中获取 User 对象
            User user = (User) session.getAttribute("user");
            
            // 【重点】获取学号 - 支持两种方式
            // 这是为了兼容不同的登录实现方式
            String enrollmentNo = null;
            if (user != null && user.getEnrollmentNo() != null && !user.getEnrollmentNo().trim().isEmpty()) {
                // 优先从 User 对象获取
                enrollmentNo = user.getEnrollmentNo().trim();
                System.out.println("[StudentProfileApiServlet SAVE] 从 User 对象中获取学号: " + enrollmentNo);
            } else {
                // 备选：从 session 属性中获取
                enrollmentNo = (String) session.getAttribute("enrollment_no");
                if (enrollmentNo != null) {
                    enrollmentNo = enrollmentNo.trim();
                    System.out.println("[StudentProfileApiServlet SAVE] 从 session 属性中获取学号: " + enrollmentNo);
                }
            }
            
            // 验证学号是否有效
            if (enrollmentNo == null || enrollmentNo.isEmpty()) {
                System.err.println("[StudentProfileApiServlet SAVE] 错误：无法获取学号，User 对象: " + (user != null) + ", enrollment_no: " + enrollmentNo);
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "User not authenticated")));
                response.flushBuffer();
                return;
            }

            // 【从前端请求中解析 JSON 数据】
            // parseRequest() 方法会读取请求体中的 JSON，并转换为 StudentProfile 对象
            System.out.println("[StudentProfileApiServlet SAVE] 开始解析请求中的 JSON 数据...");
            StudentProfile studentProfile = parseRequest(request);
            if (studentProfile == null) {
                System.err.println("[StudentProfileApiServlet SAVE] 错误：无法解析请求数据，parseRequest() 返回 null");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 返回 400
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Invalid request data")));
                response.flushBuffer();
                return;
            }
            System.out.println("[StudentProfileApiServlet SAVE] 成功解析 JSON，准备保存...");

            // 【安全检查】确保学号一致
            // 这样可以防止用户修改他人的资料（即使前端伪造请求也没用）
            studentProfile.setEnrollmentNo(enrollmentNo);

            // 【验证数据完整性】检查必填字段
            String validationError = validateProfile(studentProfile);
            if (validationError != null) {
                System.out.println("[StudentProfileApiServlet SAVE] 数据验证失败: " + validationError);
                // 返回验证错误，让前端显示错误提示
                response.getWriter().write(GSON.toJson(new ApiResponse(false, validationError)));
                response.flushBuffer();
                return;
            }
            System.out.println("[StudentProfileApiServlet SAVE] 数据验证成功，所有必填字段都已填写");

            // 【保存到文件】
            // StudentProfileDao.save() 会把资料写入 student_profiles.json 文件
            System.out.println("[StudentProfileApiServlet SAVE] 调用 StudentProfileDao 保存资料到文件...");
            StudentProfileDao profileDao = new StudentProfileDao();
            if (profileDao.save(studentProfile)) {
                System.out.println("[StudentProfileApiServlet SAVE] 资料保存成功: " + enrollmentNo);
                
                // 【关键】确保 session 在响应中被保持
                // 即使处理过程中 session 状态发生变化，也要确保浏览器保留原始的 JSESSIONID
                System.out.println("[StudentProfileApiServlet SAVE] 保持 session 活跃");
                
                // 【对策1】调用 session 方法来确保其活跃
                // 这会强制 servlet 容器在响应中包含 Set-Cookie 头
                session.setAttribute("__keep_alive__", System.currentTimeMillis());
                System.out.println("[StudentProfileApiServlet SAVE] 已设置 session 保活标记");
                
                // 【对策2】更新 session 中的用户信息，确保一致性
                // 这对于处理并发请求和快速切换页面非常重要
                if (user != null) {
                    session.setAttribute("user", user);
                    System.out.println("[StudentProfileApiServlet SAVE] 已更新 session 中的 User 对象");
                }
                
                // 【对策3】设置 session 过期时间，延长会话有效期
                // 避免多次操作导致 session 过期
                session.setMaxInactiveInterval(3600); // 设置为1小时
                System.out.println("[StudentProfileApiServlet SAVE] 已延长 session 过期时间至1小时");
                
                // 【重要】获取当前的 session 对象，确保所有属性都被保存
                HttpSession finalSession = request.getSession(false);
                if (finalSession != null) {
                    System.out.println("[StudentProfileApiServlet SAVE] 最终 session ID（将在响应中发送）: " + finalSession.getId());
                } else {
                    System.out.println("[StudentProfileApiServlet SAVE] 警告：最终无 session，但继续发送响应");
                }
                
                // 返回成功消息
                response.getWriter().write(GSON.toJson(new ApiResponse(true, "Profile saved successfully")));
                response.flushBuffer(); // 强制刷新缓冲区，确保响应和 cookie 被发送
                System.out.println("[StudentProfileApiServlet SAVE] 响应已刷新到客户端，包含 session cookie");
            } else {
                System.err.println("[StudentProfileApiServlet SAVE] 错误：保存到文件失败");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Failed to save profile")));
                response.flushBuffer();
            }
            
        } catch (Exception e) {
            // 捕获所有异常，防止程序崩溃
            System.err.println("[StudentProfileApiServlet SAVE] 发生异常: " + e.getMessage());
            e.printStackTrace();
            try {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(GSON.toJson(new ApiResponse(false, "Error saving profile: " + e.getMessage())));
                response.flushBuffer(); // 确保错误响应被发送
                System.err.println("[StudentProfileApiServlet SAVE] 错误响应已刷新到客户端");
            } catch (Exception flush_e) {
                System.err.println("[StudentProfileApiServlet SAVE] 发送错误响应时出错: " + flush_e.getMessage());
            }
        }
    }

    /**
     * 从 HTTP 请求体中解析 JSON 数据
     * 
     * 工作原理：
     * 1. 设置字符编码为 UTF-8（支持中文）
     * 2. 读取请求的输入流（request body 中的 JSON）
     * 3. 使用 GSON 库解析 JSON，转换为 StudentProfile 对象
     * 4. 返回对象，如果出错返回 null
     */
    private StudentProfile parseRequest(HttpServletRequest request) {
        try {
            // 设置字符編码，确保中文正确处理
            request.setCharacterEncoding("UTF-8");
            
            // 读取请求体中的所有数据（通常是 JSON 字符串）
            String json = request.getReader().lines()
                    .reduce("", (acc, actual) -> acc + actual);
            
            // 检查 JSON 是否为空
            if (json == null || json.isEmpty()) {
                return null;
            }

            // 使用 GSON 将 JSON 字符串转换为 StudentProfile 对象
            return GSON.fromJson(json, StudentProfile.class);
        } catch (Exception e) {
            System.err.println("parseRequest 错误: " + e.getMessage());
            return null;
        }
    }

    /**
     * 验证学生资料的必填字段
     * 
     * 必填字段检查：
     * - fullName：学生姓名
     * - qmId：QM ID
     * - buptId：BUPT 学号
     * - majorProgramme：专业/课程
     * - grade：年级
     * 
     * @return 如果验证通过返回 null，否则返回错误信息
     */
    private String validateProfile(StudentProfile profile) {
        if (profile == null) return "Profile is null"; // 资料对象本身不能为空
        if (profile.getFullName() == null || profile.getFullName().trim().isEmpty()) 
            return "Name is required"; // 姓名不能为空
        if (profile.getQmId() == null || profile.getQmId().trim().isEmpty()) 
            return "QM ID is required"; // QM ID 不能为空
        if (profile.getBuptId() == null || profile.getBuptId().trim().isEmpty()) 
            return "BUPT ID is required"; // BUPT ID 不能为空
        if (profile.getMajorProgramme() == null || profile.getMajorProgramme().trim().isEmpty()) 
            return "Major/Programme is required"; // 专业不能为空
        if (profile.getGrade() == null || profile.getGrade().trim().isEmpty()) 
            return "Grade is required"; // 年级不能为空
        return null; // 所有检查都通过
    }

    /**
     * 简单的 API 响应对象
     * 用于返回 JSON 格式的响应，包含成功标志和消息
     * 
     * 例如：
     * {"success": true, "message": "Profile saved successfully"}
     * {"success": false, "message": "Name is required"}
     */
    static class ApiResponse {
        boolean success; // 操作是否成功：true 或 false
        String message;  // 返回的消息：成功/失败原因

        ApiResponse(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
}