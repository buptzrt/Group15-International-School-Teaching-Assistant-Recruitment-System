package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class StudentRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String fullName = request.getParameter("full_name");
        String enrollmentNo = request.getParameter("enrollment_no");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");

        if (fullName == null || fullName.trim().isEmpty() ||
            enrollmentNo == null || enrollmentNo.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        UserDao userDao = new UserDao();
        if (userDao.userExists(email, enrollmentNo)) {
            request.setAttribute("error", "Email or ID already exists.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
            return;
        }

        User user = new User(enrollmentNo.trim(), email.trim(), password.trim(), fullName.trim(), "", "Student");
        boolean saved = userDao.saveUser(user);

        if (saved) {
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("error", "Registration failed. Please try again later.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
            dispatcher.forward(request, response);
        }
    }
}
