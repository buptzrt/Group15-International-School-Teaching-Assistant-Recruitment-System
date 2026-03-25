package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// 如果你在 web.xml 里配置了路由，这行可以删掉；如果没配，务必保留这行注解
//@WebServlet("/StudentRegisterServlet")
public class StudentRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. 获取精简后的表单参数 (注意这些名字要和 JSP 里的 name 属性对上)
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password"); // 新增的确认密码
        String enrollmentNo = request.getParameter("enrollment_no");

        // 2. 校验两次密码是否一致
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("student_register.jsp").forward(request, response);
            return;
        }

        UserDao userDao = new UserDao();

        // 3. 检查是否已经存在相同学号或邮箱
        if (userDao.userExists(enrollmentNo, email)) {
            request.setAttribute("error", "Student ID or Email already exists.");
            request.getRequestDispatcher("student_register.jsp").forward(request, response);
            return;
        }

        // 4. 组装新用户 (只填最基础的信息)
        User newUser = new User();
        newUser.setEnrollmentNo(enrollmentNo);
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setPassword(password);
        newUser.setRole("Student"); // 默认角色写死为学生

        // 5. 写入 JSON
        if (userDao.addUser(newUser)) {
            // 注册成功，跳回登录页
            response.sendRedirect("student_login.jsp?registered=success");
        } else {
            // 写入失败
            request.setAttribute("error", "Registration failed (System Error). Please try again.");
            request.getRequestDispatcher("student_register.jsp").forward(request, response);
        }
    }
}
