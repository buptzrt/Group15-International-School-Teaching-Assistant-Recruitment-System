package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
import com.me.finaldesignproject.dao.UserDao; // 记得导入 UserDao
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

        // 1. 【新增逻辑】优先尝试获取 URL 传来的 userId 参数
        String targetUserId = request.getParameter("userId");
        User displayUser = null;
        StudentProfile studentProfile = null;

        if (targetUserId != null && !targetUserId.trim().isEmpty()) {
            // 说明是 MO 在看学生的简历
            System.out.println("[StudentProfileServlet] 检测到 userId 参数: " + targetUserId);
            // 通过 UserDao 查出该学生的基本信息 (为了拿到名字、角色等)
            displayUser = new UserDao().getUserByEnrollment(targetUserId);
            // 查出该学生的详细 Profile
            studentProfile = new StudentProfileDao().getByEnrollment(targetUserId);
            request.setAttribute("isReadOnly", true); // 标记为只读模式，隐藏编辑按钮
        } else {
            // 2. 【原始逻辑】如果没有参数，再走 Session 逻辑（学生看自己）
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            displayUser = (User) session.getAttribute("user");
            if (displayUser != null) {
                studentProfile = new StudentProfileDao().getByEnrollment(displayUser.getEnrollmentNo());
            }
        }

        // 3. 【健壮性检查】
        if (displayUser == null) {
            System.err.println("[StudentProfileServlet] ERROR: 找不到目标用户对象");
            response.sendRedirect("login.jsp");
            return;
        }

        // 4. 【设置属性并转发】
        System.out.println("[StudentProfileServlet] ✓ 准备加载用户: " + displayUser.getEnrollmentNo());
        request.setAttribute("userProfile", displayUser);
        request.setAttribute("studentProfile", studentProfile);

        System.out.println("[StudentProfileServlet] 准备转发到 view_profile.jsp");
        RequestDispatcher dispatcher = request.getRequestDispatcher("view_profile.jsp");
        dispatcher.forward(request, response);
        System.out.println("========== [StudentProfileServlet] GET 请求完成 ==========");
    }
}