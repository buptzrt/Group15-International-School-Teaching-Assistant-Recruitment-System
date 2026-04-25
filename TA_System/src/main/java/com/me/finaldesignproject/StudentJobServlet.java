package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.JobDao;
import com.me.finaldesignproject.model.Job;

import java.io.IOException;
import java.util.stream.Collectors;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * 学生职位列表 Servlet
 * 负责展示系统中所有发布的职位，供学生（TA 申请者）查看和筛选
 */
@WebServlet("/StudentJobServlet")
public class StudentJobServlet extends HttpServlet {
    private JobDao jobDao = new JobDao(); // 实例化职位数据访问对象

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // 权限校验：确保用户已登录
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Student list keeps closed/overdue jobs visible, but hidden deleted records should not appear.
        List<Job> allJobs = jobDao.getAllJobs().stream()
                .filter(job -> !job.isDeleted())
                .collect(Collectors.toList());

        // 将数据传递给 JSP 页面
        request.setAttribute("jobList", allJobs);

        // 转发到学生专属的职位列表页面
        request.getRequestDispatcher("student_job_list.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 学生端的 POST 请求通常由具体的申请逻辑处理，此处默认执行查询
        doGet(request, response);
    }
}
