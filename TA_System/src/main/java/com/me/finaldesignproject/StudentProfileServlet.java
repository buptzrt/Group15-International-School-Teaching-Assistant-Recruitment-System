package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.TaProfileDao;
import com.me.finaldesignproject.model.TaProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class StudentProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        request.setAttribute("userProfile", user);

        String role = user.getRole() == null ? "" : user.getRole().trim();
        if ("TA".equalsIgnoreCase(role) || "Student".equalsIgnoreCase(role)) {
            TaProfile taProfile = new TaProfileDao().getByEnrollment(user.getEnrollmentNo());
            request.setAttribute("taProfile", taProfile);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("view_profile.jsp");
        dispatcher.forward(request, response);
    }
}
