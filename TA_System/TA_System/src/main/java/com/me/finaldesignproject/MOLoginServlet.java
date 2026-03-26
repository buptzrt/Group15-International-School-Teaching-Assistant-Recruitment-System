package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;

import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class MOLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginId = request.getParameter("loginId");
        if (loginId == null || loginId.trim().isEmpty()) {
            loginId = request.getParameter("email");
        }
        String password = request.getParameter("password");

        com.me.finaldesignproject.dao.UserDao userDao = new com.me.finaldesignproject.dao.UserDao();
        User loggedInMo = userDao.login(loginId, password);

        if (loggedInMo != null && "MO".equalsIgnoreCase(loggedInMo.getRole())) {
            HttpSession session = request.getSession();

            int derivedCompanyId = 0;
            try {
                String digits = loggedInMo.getEnrollmentNo().replaceAll("[^0-9]", "");
                if (!digits.isEmpty()) {
                    derivedCompanyId = Integer.parseInt(digits);
                }
            } catch (Exception ignored) {
                derivedCompanyId = 0;
            }

            // Keep compatibility with existing company-based pages
            session.setAttribute("company_id", derivedCompanyId);
            session.setAttribute("company_name", loggedInMo.getFullName());
            session.setAttribute("company_email", loggedInMo.getEmail());

            // New MO session attributes
            session.setAttribute("mo_id", loggedInMo.getEnrollmentNo());
            session.setAttribute("mo_name", loggedInMo.getFullName());
            session.setAttribute("mo_email", loggedInMo.getEmail());
            session.setAttribute("role", "MO");

            response.sendRedirect("mo_home.jsp");
            return;
        }

        if (loggedInMo != null) {
            request.setAttribute("error", "Access Denied: This account is not an MO account.");
        } else {
            request.setAttribute("error", "Invalid MO ID/Email or Password.");
        }

        RequestDispatcher rd = request.getRequestDispatcher("mo_login.jsp");
        rd.forward(request, response);
    }
}
