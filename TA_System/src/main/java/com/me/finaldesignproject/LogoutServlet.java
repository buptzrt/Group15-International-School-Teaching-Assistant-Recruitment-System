package com.me.finaldesignproject;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

/**
 * Servlet that ends the current user session.
 */
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Invalidates the current session and redirects the user to the login page.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Invalidate the current session
        HttpSession session = request.getSession(false); // avoid creating a new session
        if (session != null) {
            session.invalidate();
        }

        // Redirect to index.html
        response.sendRedirect("index.html");
    }

    // Optional: also handle POST if needed
    /**
     * Delegates logout requests submitted with POST to the GET handler.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
