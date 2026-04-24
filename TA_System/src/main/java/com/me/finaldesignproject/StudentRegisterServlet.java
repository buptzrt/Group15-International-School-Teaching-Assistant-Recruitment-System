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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String fullName = trim(request.getParameter("full_name"));
        String enrollmentNo = trim(request.getParameter("enrollment_no"));
        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirm_password"));

        if (isBlank(fullName) || isBlank(enrollmentNo) || isBlank(email)
                || isBlank(password) || isBlank(confirmPassword)) {
            forwardWithError(request, response, "All fields are required.");
            return;
        }

        if (!RegistrationRules.isValidPublicEnrollmentNo(enrollmentNo)) {
            forwardWithError(request, response, RegistrationRules.PUBLIC_ID_RULE_TEXT);
            return;
        }

        if (!password.equals(confirmPassword)) {
            forwardWithError(request, response, "Passwords do not match.");
            return;
        }

        UserDao userDao = new UserDao();
        if (userDao.userExists(email, enrollmentNo)) {
            forwardWithError(request, response, "Email or ID already exists.");
            return;
        }

        User user = new User(enrollmentNo, email, password, fullName, null, "Student");
        boolean saved = userDao.saveUser(user);

        if (saved) {
            response.sendRedirect("login.jsp");
        } else {
            forwardWithError(request, response, "Registration failed. Please try again later.");
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        RequestDispatcher dispatcher = request.getRequestDispatcher("student_register.jsp");
        dispatcher.forward(request, response);
    }

    private boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
