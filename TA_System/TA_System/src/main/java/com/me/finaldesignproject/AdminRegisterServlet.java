package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * 管理员注册处理类
 * 模仿 StudentRegisterServlet 编写
 */
//@WebServlet("/AdminRegisterServlet") // 如果 web.xml 配过了，这行可以注释掉
public class AdminRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 设置编码，防止中文乱码
        request.setCharacterEncoding("UTF-8");

        // 1. 获取表单参数 (对应 admin_register.jsp 中的 name 属性)
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String enrollmentNo = request.getParameter("enrollment_no"); // 管理员工号

        // 2. 校验两次密码是否一致
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        UserDao userDao = new UserDao();

        // 3. 检查是否已经存在相同工号(ID)或邮箱
        // 这一步会去 users.json 里全局查重
        if (userDao.userExists(enrollmentNo, email)) {
            request.setAttribute("error", "Admin ID or Email already exists.");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        // 4. 组装新管理员对象 (使用你那个带 fullName 和 role 的 User 模型)
        User newAdmin = new User();
        newAdmin.setEnrollmentNo(enrollmentNo); // 比如存入 AD001
        newAdmin.setFullName(fullName);
        newAdmin.setEmail(email);
        newAdmin.setPassword(password);
        newAdmin.setRole("Admin"); // 🚨 关键点：设置为 Admin 角色

        // 5. 写入 JSON (统一调用之前写好的 addUser 方法)
        if (userDao.addUser(newAdmin)) {
            // 注册成功，重定向到管理员登录页
            response.sendRedirect("admin_login.jsp?registered=success");
        } else {
            // 写入失败（如文件路径错误或权限问题）
            request.setAttribute("error", "Registration failed (System Error).");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
        }
    }
}