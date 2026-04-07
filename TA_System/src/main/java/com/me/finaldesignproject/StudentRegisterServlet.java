package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * 学生注册Servlet
 * 
 * 负责处理学生用户的注册请求，包括：
 * 1. 接收并验证注册表单数据
 * 2. 验证密码一致性
 * 3. 检查用户是否已存在
 * 4. 保存新用户信息到json文件（模拟数据库）
 * 
 * @author Team
 * @version 1.0
 */
public class StudentRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * 处理POST请求，处理学生注册逻辑
     * 
     * @param request HTTP请求对象，包含注册表单数据
     * @param response HTTP响应对象
     * @throws ServletException servlet异常
     * @throws IOException IO异常
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 设置请求字符编码为UTF-8，支持中文
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 获取注册表单中的参数
        String fullName = request.getParameter("full_name");
        String enrollmentNo = request.getParameter("enrollment_no");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");

        // 验证所有必填字段是否为空
        if (fullName == null || fullName.trim().isEmpty() ||
            enrollmentNo == null || enrollmentNo.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            // 如果字段为空，返回错误信息
            request.setAttribute("error", "All fields are required.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // 验证两次输入的密码是否一致
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // 检查用户是否已存在（邮箱或学号重复）
        UserDao userDao = new UserDao();
        if (userDao.userExists(email, enrollmentNo)) {
            request.setAttribute("error", "Email or ID already exists.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        // 创建新学生对象，角色为"Student"
        User user = new User(enrollmentNo.trim(), email.trim(), password.trim(), fullName.trim(), null, "Student");
        // 保存用户到json文件（模拟数据库）
        boolean saved = userDao.saveUser(user);

        // 注册成功后重定向到登录页面
        if (saved) {
            response.sendRedirect("login.jsp");
        } else {
            // 注册失败显示错误信息
            request.setAttribute("error", "Registration failed. Please try again later.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
        }
    }
}
