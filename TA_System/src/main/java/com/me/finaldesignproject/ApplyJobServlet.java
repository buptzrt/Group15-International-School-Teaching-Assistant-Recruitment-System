package com.me.finaldesignproject.controller;

import com.me.finaldesignproject.dao.ApplicationDao;
import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.model.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

    private final ApplicationDao appDao = new ApplicationDao();
    private final JobDao jobDao = new JobDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String jobId = request.getParameter("jobId");

        if (userId == null || jobId == null) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Job targetJob = null;
        List<Job> allJobs = jobDao.getAllJobs();
        for (Job job : allJobs) {
            if (jobId.equals(job.getJobId())) {
                targetJob = job;
                break;
            }
        }
        if (!jobDao.isVisibleInHall(targetJob, LocalDate.now())) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            return;
        }

        boolean success = appDao.saveApplication(userId, jobId);
        response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }
}
