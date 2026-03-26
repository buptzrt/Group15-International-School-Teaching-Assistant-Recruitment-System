package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class MORegisterServlet extends HttpServlet {

    private String generateNextMoId(UserDao userDao) {
        List<User> users = userDao.getAllUsers();
        int max = 0;

        for (User u : users) {
            if (u.getRole() == null || !"MO".equalsIgnoreCase(u.getRole())) {
                continue;
            }
            String id = u.getEnrollmentNo();
            if (id == null || !id.toUpperCase().startsWith("MO")) {
                continue;
            }
            String numberPart = id.substring(2).replaceAll("[^0-9]", "");
            if (!numberPart.isEmpty()) {
                try {
                    int value = Integer.parseInt(numberPart);
                    if (value > max) {
                        max = value;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }

        return String.format("MO%03d", max + 1);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String moName = request.getParameter("company_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String moId = request.getParameter("enrollment_no");

        if (moName == null || moName.trim().isEmpty() || email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please fill all required fields.");
            request.getRequestDispatcher("mo_register.jsp").forward(request, response);
            return;
        }

        if (confirmPassword != null && !confirmPassword.equals(password)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("mo_register.jsp").forward(request, response);
            return;
        }

        com.me.finaldesignproject.dao.UserDao userDao = new com.me.finaldesignproject.dao.UserDao();

        if (moId == null || moId.trim().isEmpty()) {
            moId = generateNextMoId(userDao);
        }

        if (userDao.userExists(moId, email)) {
            request.setAttribute("error", "MO ID or Email already exists.");
            request.getRequestDispatcher("mo_register.jsp").forward(request, response);
            return;
        }

        User newMo = new User();
        newMo.setEnrollmentNo(moId.trim());
        newMo.setFullName(moName.trim());
        newMo.setEmail(email.trim());
        newMo.setPassword(password);
        newMo.setRole("MO");

        if (userDao.addUser(newMo)) {
            response.sendRedirect("mo_login.jsp?registered=success");
        } else {
            request.setAttribute("error", "Registration failed (System Error).");
            RequestDispatcher rd = request.getRequestDispatcher("mo_register.jsp");
            rd.forward(request, response);
        }
    }
}
