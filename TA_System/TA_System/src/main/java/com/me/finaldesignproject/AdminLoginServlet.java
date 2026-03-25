package com.me.finaldesignproject;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

// 引入模型和 DAO 工具
import com.me.finaldesignproject.model.User;
import com.me.finaldesignproject.dao.UserDao;

@WebServlet("/AdminLoginServlet") // 确保这个路径和 admin_login.jsp 的 <form action="..."> 一致
public class AdminLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 接收前端传来的登录账号（支持邮箱或工号）和密码
        // 注意：这里的 getParameter("...") 里的名字要和 JSP 表单 input 的 name 属性对上
        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");

        // 2. 调用通用的 UserDao 逻辑
        UserDao userDao = new UserDao();
        User loggedInAdmin = userDao.login(loginId, password);

        // 3. 判断是否查到了用户，并且其角色确实是 "Admin"
        if (loggedInAdmin != null && "Admin".equalsIgnoreCase(loggedInAdmin.getRole())) {

            // ✅ 登录成功：把管理员信息存入 Session
            HttpSession session = request.getSession();

            // 存入 Session 的属性名，建议和你的 admin_home.jsp 页面调用的名称保持一致
            session.setAttribute("admin_email", loggedInAdmin.getEmail());
            session.setAttribute("admin_name", loggedInAdmin.getFullName());
            session.setAttribute("admin_id", loggedInAdmin.getEnrollmentNo()); // 存入 AD001 等工号
            session.setAttribute("role", "Admin");

            // 跳转到管理员主页
            response.sendRedirect("admin_home.jsp");

        } else if (loggedInAdmin != null && !"Admin".equalsIgnoreCase(loggedInAdmin.getRole())) {
            // ❌ 账号密码对，但不是管理员（角色不对）
            request.setAttribute("error", "Access Denied: You are not an authorized Admin.");
            request.getRequestDispatcher("admin_login.jsp").forward(request, response);

        } else {
            // ❌ 登录失败：账号或密码错误
            request.setAttribute("error", "Invalid ID/Email or Password");
            request.getRequestDispatcher("admin_login.jsp").forward(request, response);
        }
    }
}