package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;
import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");

        com.me.finaldesignproject.dao.UserDao userDao = new com.me.finaldesignproject.dao.UserDao();
        User loggedInAdmin = userDao.login(loginId, password);

        if (loggedInAdmin != null && "Admin".equalsIgnoreCase(loggedInAdmin.getRole())) {
            HttpSession session = request.getSession();
            session.setAttribute("admin_email", loggedInAdmin.getEmail());
            session.setAttribute("admin_name", loggedInAdmin.getFullName());
            session.setAttribute("admin_id", loggedInAdmin.getEnrollmentNo());
            session.setAttribute("role", "Admin");
            response.sendRedirect("admin_home.jsp");
            return;
        }

        if (loggedInAdmin != null) {
            request.setAttribute("error", "Access Denied: You are not an authorized Admin.");
        } else {
            request.setAttribute("error", "Invalid ID/Email or Password");
        }

        RequestDispatcher rd = request.getRequestDispatcher("admin_login.jsp");
        rd.forward(request, response);
    }
}