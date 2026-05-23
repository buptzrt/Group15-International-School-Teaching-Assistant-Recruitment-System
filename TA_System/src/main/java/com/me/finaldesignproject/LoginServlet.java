package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;
import java.io.IOException;
import java.util.Collections;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet that authenticates users and starts the appropriate web session.
 */
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Authenticates the submitted credentials, initializes the session, and redirects to the
     * role-specific landing page.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        UserDao userDao = new UserDao();
        User user = userDao.login(loginId, password);
        System.out.println("LoginServlet: loginId=" + loginId
                + ", password=" + password
                + ", user=" + (user == null ? "null" : user));

        if (user != null) {
            HttpSession session = request.getSession(true);
            System.out.println("========================================");
            System.out.println("[LoginServlet] Login succeeded. Created new session.");
            System.out.println("[LoginServlet] Session ID: " + session.getId());
            System.out.println("[LoginServlet] Session creation time: " + session.getCreationTime());
            System.out.println("[LoginServlet] Session last accessed: " + session.getLastAccessedTime());
            System.out.println("[LoginServlet] Session timeout: " + session.getMaxInactiveInterval()
                    + " seconds (" + (session.getMaxInactiveInterval() / 60) + " minutes)");

            session.setAttribute("user", user);
            session.setAttribute("userId", user.getEnrollmentNo());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("role", user.getRole());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("enrollment_no", user.getEnrollmentNo());

            System.out.println("[LoginServlet] Saved session attributes:");
            System.out.println("  - user: " + user.getEnrollmentNo());
            System.out.println("  - userId: " + user.getEnrollmentNo());
            System.out.println("  - userRole: " + user.getRole());
            System.out.println("  - enrollment_no: " + user.getEnrollmentNo());
            System.out.println("[LoginServlet] Session attribute count: "
                    + Collections.list(session.getAttributeNames()).size());

            HttpSession testSession = request.getSession(false);
            if (testSession != null && testSession.getId().equals(session.getId())) {
                System.out.println("[LoginServlet] Session verification succeeded.");
            } else {
                System.err.println("[LoginServlet] Warning: getSession(false) could not read the new session.");
            }

            if ("on".equals(remember) || "true".equals(remember)) {
                Cookie cookie = new Cookie("saved_login_id", loginId);
                cookie.setMaxAge(7 * 24 * 60 * 60);
                cookie.setPath("/");
                response.addCookie(cookie);
                System.out.println("[LoginServlet] Added saved_login_id cookie.");
            } else {
                Cookie cookie = new Cookie("saved_login_id", "");
                cookie.setMaxAge(0);
                cookie.setPath("/");
                response.addCookie(cookie);
                System.out.println("[LoginServlet] Cleared saved_login_id cookie.");
            }

            String role = user.getRole();
            String redirectPage = "student_home.jsp";
            if (role != null) {
                role = role.trim().toLowerCase();
                if ("mo".equals(role)) {
                    redirectPage = "mo_home.jsp";
                } else if ("admin".equals(role)) {
                    redirectPage = "admin_home.jsp";
                } else if ("student".equals(role) || "ta".equals(role)) {
                    redirectPage = "student_home.jsp";
                }
            }

            System.out.println("[LoginServlet] Role: " + user.getRole() + ", redirecting to " + redirectPage);
            System.out.println("[LoginServlet] Redirect URL: " + request.getContextPath() + "/" + redirectPage);
            System.out.println("[LoginServlet] Expected JSESSIONID in response: " + session.getId());
            System.out.println("========================================");
            response.sendRedirect(request.getContextPath() + "/" + redirectPage);
            return;
        }

        request.setAttribute("error", "invalid email or password");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }
}
