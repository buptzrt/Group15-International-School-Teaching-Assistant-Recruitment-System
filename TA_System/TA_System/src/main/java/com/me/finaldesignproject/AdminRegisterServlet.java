package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class AdminRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String enrollmentNo = request.getParameter("enrollment_no");

        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        com.me.finaldesignproject.dao.UserDao userDao = new com.me.finaldesignproject.dao.UserDao();

        if (userDao.userExists(enrollmentNo, email)) {
            request.setAttribute("error", "Admin ID or Email already exists.");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
            return;
        }

        User newAdmin = new User();
        newAdmin.setEnrollmentNo(enrollmentNo);
        newAdmin.setFullName(fullName);
        newAdmin.setEmail(email);
        newAdmin.setPassword(password);
        newAdmin.setRole("Admin");

        if (userDao.addUser(newAdmin)) {
            response.sendRedirect("admin_login.jsp?registered=success");
        } else {
            request.setAttribute("error", "Registration failed (System Error).");
            request.getRequestDispatcher("admin_register.jsp").forward(request, response);
        }
    }
}