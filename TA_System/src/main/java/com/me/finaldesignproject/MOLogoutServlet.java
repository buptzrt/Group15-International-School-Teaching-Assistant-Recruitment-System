package com.me.finaldesignproject;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Servlet that logs a module organizer out by invalidating the current session.
 */
public class MOLogoutServlet extends HttpServlet {

    /**
     * Invalidates the current session and redirects the top window to the landing page.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.setContentType("text/html");
        response.getWriter().println("<html><body>");
        response.getWriter().println("<script>window.top.location.href = 'index.html';</script>");
        response.getWriter().println("</body></html>");
    }

    /**
     * Delegates POST logout requests to {@link #doGet(HttpServletRequest, HttpServletResponse)}.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
