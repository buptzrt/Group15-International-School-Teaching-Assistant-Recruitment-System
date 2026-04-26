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

public class StudentProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("========== [StudentProfileServlet] GET 请求开始 ==========");

        // 1. 【核心修改】同时兼容 userId 和 studentId 参数
        // 因为 mo_applications.jsp 传的是 studentId，这里必须能抓到
        String targetId = request.getParameter("studentId");
        if (targetId == null || targetId.trim().isEmpty()) {
            targetId = request.getParameter("userId");
        }

        User displayUser = null;
        StudentProfile studentProfile = null;

        if (targetId != null && !targetId.trim().isEmpty()) {
            // --- MO 模式：查看指定学生 ---
            System.out.println("[StudentProfileServlet] 正在查询指定 ID: " + targetId);

            // 🌟 请根据你 UserDao 的实际方法名选择 (getUserByEnrollment 或 getUserByEnrollmentNo)
            displayUser = new UserDao().getUserByEnrollment(targetId);

            // 🌟 同样，确保 StudentProfileDao 方法名正确
            studentProfile = new StudentProfileDao().getByEnrollment(targetId);

            request.setAttribute("isReadOnly", true);
        } else {
            // --- 学生模式：查看自己 ---
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                System.out.println("[StudentProfileServlet] 未登录，重定向");
                response.sendRedirect("login.jsp");
                return;
            }
            displayUser = (User) session.getAttribute("user");
            if (displayUser != null) {
                studentProfile = new StudentProfileDao().getByEnrollment(displayUser.getEnrollmentNo());
            }
        }

        // 2. 【转发逻辑】
        if (displayUser == null) {
            System.err.println("[StudentProfileServlet] ERROR: 找不到该用户数据");
            // 如果没找到，尝试返回登录或给出错误提示
            response.sendRedirect("login.jsp");
            return;
        }

        // 🌟 这里的 Attribute Name 必须严格对应 view_profile.jsp 顶部的获取名
        request.setAttribute("userProfile", displayUser);
        request.setAttribute("studentProfile", studentProfile);

        System.out.println("[StudentProfileServlet] 数据准备完毕，转发中...");
        RequestDispatcher dispatcher = request.getRequestDispatcher("view_profile.jsp");
        dispatcher.forward(request, response);
        System.out.println("========== [StudentProfileServlet] GET 请求完成 ==========");
    }
}