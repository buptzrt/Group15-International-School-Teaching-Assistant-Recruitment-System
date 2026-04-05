package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.StudentProfileDao;
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

        // 【诊断】打印请求信息
        System.out.println("========== [StudentProfileServlet] GET 请求开始 ==========");
        System.out.println("[StudentProfileServlet] 请求 Cookie: " + request.getHeader("Cookie"));
        
        // 【获取 session】使用 getSession(false) 不创建新 session
        HttpSession session = request.getSession(false);
        
        if (session == null) {
            System.err.println("[StudentProfileServlet] ERROR: 无法获取 session");
            System.err.println("[StudentProfileServlet] 原因：getSession(false) 返回 null，说明浏览器发送的 JSESSIONID 在服务器端不存在或已过期");
            System.err.println("[StudentProfileServlet] 解决办法：需要用户重新登录");
            System.out.println("[StudentProfileServlet] 即将重定向到 login.jsp");
            response.sendRedirect("login.jsp");
            return;
        }

        System.out.println("[StudentProfileServlet] ✓ 成功获得 session ID: " + session.getId());
        
        // 【获取 User 对象】
        User user = (User) session.getAttribute("user");
        if (user == null) {
            System.err.println("[StudentProfileServlet] ERROR: Session 中的 User 对象为 null");
            System.err.println("[StudentProfileServlet] 原因：User 对象丢失（可能在序列化过程中被清除）");
            System.err.println("[StudentProfileServlet] 所有 session 属性: " + String.join(", ", 
                java.util.Collections.list(session.getAttributeNames())));
            System.err.println("[StudentProfileServlet] 解决办法：清除旧的 JSESSIONID cookie，重新登录");
            response.sendRedirect("login.jsp");
            return;
        }

        System.out.println("[StudentProfileServlet] ✓ 获得 User: " + user.getEnrollmentNo() + " (" + user.getEmail() + ")");

        request.setAttribute("userProfile", user);

        String role = user.getRole() == null ? "" : user.getRole().trim();
        if ("TA".equalsIgnoreCase(role) || "Student".equalsIgnoreCase(role)) {
            StudentProfile studentProfile = new StudentProfileDao().getByEnrollment(user.getEnrollmentNo());
            request.setAttribute("studentProfile", studentProfile);
            System.out.println("[StudentProfileServlet] ✓ 加载学生资料成功");
        }

        System.out.println("[StudentProfileServlet] 准备转发到 view_profile.jsp");
        RequestDispatcher dispatcher = request.getRequestDispatcher("view_profile.jsp");
        dispatcher.forward(request, response);
        System.out.println("========== [StudentProfileServlet] GET 请求完成 ==========");
    }
}
