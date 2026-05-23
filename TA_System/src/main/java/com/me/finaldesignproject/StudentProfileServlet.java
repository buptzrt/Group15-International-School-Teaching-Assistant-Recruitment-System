package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet that loads the profile page for either the current student or a selected student record.
 */
public class StudentProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Resolves the target profile and forwards the populated data to {@code view_profile.jsp}.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("========== [StudentProfileServlet] GET request started ==========");

        String targetId = request.getParameter("studentId");
        if (targetId == null || targetId.trim().isEmpty()) {
            targetId = request.getParameter("userId");
        }

        User displayUser = null;
        StudentProfile studentProfile = null;

        if (targetId != null && !targetId.trim().isEmpty()) {
            System.out.println("[StudentProfileServlet] Loading read-only profile for ID: " + targetId);
            displayUser = new UserDao().getUserByEnrollment(targetId);
            studentProfile = new StudentProfileDao().getByEnrollment(targetId);
            request.setAttribute("isReadOnly", true);
        } else {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                System.out.println("[StudentProfileServlet] No authenticated user. Redirecting to login.");
                response.sendRedirect("login.jsp");
                return;
            }

            displayUser = (User) session.getAttribute("user");
            if (displayUser != null) {
                studentProfile = new StudentProfileDao().getByEnrollment(displayUser.getEnrollmentNo());
            }
        }

        if (displayUser == null) {
            System.err.println("[StudentProfileServlet] User record not found.");
            response.sendRedirect("login.jsp");
            return;
        }

        request.setAttribute("userProfile", displayUser);
        request.setAttribute("studentProfile", studentProfile);

        System.out.println("[StudentProfileServlet] Forwarding populated profile data.");
        RequestDispatcher dispatcher = request.getRequestDispatcher("view_profile.jsp");
        dispatcher.forward(request, response);
        System.out.println("========== [StudentProfileServlet] GET request finished ==========");
    }
}
