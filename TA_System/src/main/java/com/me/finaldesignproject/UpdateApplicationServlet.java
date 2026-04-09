package com.me.finaldesignproject.controller;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/UpdateApplicationServlet")
public class UpdateApplicationServlet extends HttpServlet {

    private final ApplicationDao appDao = new ApplicationDao();
    private final JobDao jobDao = new JobDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String jobId = request.getParameter("jobId");
        String status = request.getParameter("status");

        if (studentId == null || jobId == null || status == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters.");
            return;
        }

        boolean isAccepted = "Accepted".equalsIgnoreCase(status) || "Pass".equalsIgnoreCase(status);
        String normalizedStatus = isAccepted ? "Accepted" : status;

        boolean isSuccess = appDao.updateApplicationStatus(studentId, jobId, normalizedStatus);

        if (isSuccess && isAccepted) {
            boolean jobUpdated = jobDao.decreasePosition(jobId);
            if (!jobUpdated) {
                System.err.println("[UpdateApplicationServlet] Warning: application accepted but position count update failed for JobID: " + jobId);
            }
        }

        if (isSuccess) {
            response.sendRedirect("view_applications.jsp");
        } else {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<script>alert('Update failed! Record might not exist.'); history.back();</script>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
