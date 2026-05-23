package com.me.finaldesignproject;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLIntegrityConstraintViolationException;
import java.time.LocalDate;

/**
 * Servlet that processes company application submissions.
 */
public class ApplyCompanyServlet extends HttpServlet {

    /**
     * Processes the company-side application submission workflow.
     *
     * @param request the incoming HTTP request
     * @param response the outgoing HTTP response
     * @throws ServletException if servlet processing fails
     * @throws IOException if an input or output error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String enrollmentNo = request.getParameter("enrollment_no");
        String companyIdStr = request.getParameter("company_id");
        String cgpaStr = request.getParameter("cgpa");

        if (enrollmentNo == null || companyIdStr == null
                || enrollmentNo.isEmpty() || companyIdStr.isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }

        int companyId = Integer.parseInt(companyIdStr);
        double cgpa;
        try {
            cgpa = Double.parseDouble(cgpaStr);
            if (cgpa < 0 || cgpa > 10) {
                throw new NumberFormatException("Invalid CGPA range");
            }
        } catch (Exception e) {
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("<html><head><script>");
            out.println("alert('Please enter a valid CGPA between 0 and 10.');");
            out.println("window.history.back();");
            out.println("</script></head><body></body></html>");
            return;
        }

        boolean isSuccess = false;
        boolean isDuplicate = false;
        Connection conn = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/design_engineering_portal", "root", "root");

            PreparedStatement updateStudent = conn.prepareStatement(
                    "UPDATE students SET cgpa = ? WHERE enrollment_no = ?");
            updateStudent.setDouble(1, cgpa);
            updateStudent.setString(2, enrollmentNo);
            updateStudent.executeUpdate();
            updateStudent.close();

            PreparedStatement pstmt = conn.prepareStatement(
                    "INSERT INTO applications (enrollment_no, company_id, application_date) "
                            + "VALUES (?, ?, ?)");
            pstmt.setString(1, enrollmentNo);
            pstmt.setInt(2, companyId);
            pstmt.setDate(3, Date.valueOf(LocalDate.now()));

            int rows = pstmt.executeUpdate();
            isSuccess = rows > 0;
            pstmt.close();
        } catch (SQLIntegrityConstraintViolationException dup) {
            isDuplicate = true;
        } catch (Exception e) {
            isSuccess = false;
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><head><script>");

        if (isDuplicate) {
            out.println("alert('You have already applied to this company.');");
        } else if (isSuccess) {
            out.println("alert('Application submitted successfully!');");
        } else {
            out.println("alert('Failed to submit application.');");
        }

        out.println("if (window.opener && window.opener.opener) {");
        out.println("    window.opener.opener.location.reload();");
        out.println("    window.opener.close();");
        out.println("}");
        out.println("window.close();");
        out.println("</script></head><body></body></html>");
    }
}
