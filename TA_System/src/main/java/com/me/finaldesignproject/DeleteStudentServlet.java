package com.me.finaldesignproject;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

/**
 * Servlet that removes a student record.
 */
public class DeleteStudentServlet extends HttpServlet {

    // Change this from doGet to doPost
    /**
     * Deletes the selected student record and redirects back to the management page.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enrollmentNo = request.getParameter("enrollment_no");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/design_engineering_portal", "root", "root");

            String sql = "DELETE FROM students WHERE enrollment_no = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, enrollmentNo);

            int result = ps.executeUpdate();

            ps.close();
            conn.close();

            if (result > 0) {
                request.setAttribute("message", "Student deleted successfully.");
            } else {
                request.setAttribute("message", "Student not found or could not be deleted.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        RequestDispatcher rd = request.getRequestDispatcher("admin_student_details.jsp");
        rd.forward(request, response);
    }
}
