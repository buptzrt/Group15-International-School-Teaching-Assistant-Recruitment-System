package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;
import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        
        // 获取登陆信息
        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        // 验证登陆
        UserDao userDao = new UserDao();
        User user = userDao.login(loginId, password);
        System.out.println("LoginServlet: 请求 loginId=" + loginId + ", password=" + password + ", user=" + (user == null ? "null" : user));
        
        if (user != null) {
            // 登陆成功
            // 【关键步骤】设置Session - 使用 getSession(true) 创建新 session
            HttpSession session = request.getSession(true);
            System.out.println("========================================");
            System.out.println("[LoginServlet] 登陆成功！创建新 session");
            System.out.println("[LoginServlet] Session ID: " + session.getId());
            System.out.println("[LoginServlet] Session 创建时间: " + session.getCreationTime());
            System.out.println("[LoginServlet] Session 最后访问时间: " + session.getLastAccessedTime());
            System.out.println("[LoginServlet] Session 超时设置: " + session.getMaxInactiveInterval() + " 秒 (即 " + (session.getMaxInactiveInterval() / 60) + " 分钟)");
            
            // 【存储用户信息】将用户信息保存到 session
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getEnrollmentNo());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("role", user.getRole()); // 与 JSP 页面访问控制保持一致
            // 兼容旧 Student/Company 相关 Servlet：它们依赖 session 中的 email / enrollment_no
            session.setAttribute("email", user.getEmail());
            session.setAttribute("enrollment_no", user.getEnrollmentNo());
            
            System.out.println("[LoginServlet] 已保存到 session:");
            System.out.println("  - user: " + user.getEnrollmentNo());
            System.out.println("  - userId: " + user.getEnrollmentNo());
            System.out.println("  - userRole: " + user.getRole());
            System.out.println("  - enrollment_no: " + user.getEnrollmentNo());
            System.out.println("[LoginServlet] Session 属性总数: " + java.util.Collections.list(session.getAttributeNames()).size());
            
            // 【验证 session 是否可以被立即获取】
            HttpSession testSession = request.getSession(false);
            if (testSession != null && testSession.getId().equals(session.getId())) {
                System.out.println("[LoginServlet] ✓ 验证成功：getSession(false) 能够立即获取创建的 session");
            } else {
                System.err.println("[LoginServlet] ✗ 警告：getSession(false) 无法获取刚创建的 session！");
            }
            
            // 如果选中"记住我"，保存loginId到Cookie
            if ("on".equals(remember) || "true".equals(remember)) {
                Cookie cookie = new Cookie("saved_login_id", loginId);
                cookie.setMaxAge(7 * 24 * 60 * 60); // 7天过期
                cookie.setPath("/");
                response.addCookie(cookie);
                System.out.println("[LoginServlet] 已添加 saved_login_id Cookie");
            } else {
                // 清除記住我的Cookie
                Cookie cookie = new Cookie("saved_login_id", "");
                cookie.setMaxAge(0);
                cookie.setPath("/");
                response.addCookie(cookie);
                System.out.println("[LoginServlet] 已清除 saved_login_id Cookie");
            }
            
            // 根据用户角色重定向到不同页面
            String role = user.getRole();
            String redirectPage = "student_home.jsp"; // 默认学生页面
            if (role != null) {
                role = role.trim().toLowerCase();
                if ("mo".equals(role)) {
                    redirectPage = "mo_home.jsp";
                } else if ("admin".equals(role)) {
                    redirectPage = "admin_home.jsp";
                } else if ("student".equals(role)) {
                    redirectPage = "student_home.jsp";
                } else if ("ta".equals(role)) {
                    redirectPage = "student_home.jsp";
                }
            }

            System.out.println("[LoginServlet] 用户角色: " + user.getRole() + " → 将重定向到: " + redirectPage);
            System.out.println("[LoginServlet] 重定向URL: " + request.getContextPath() + "/" + redirectPage);
            System.out.println("[LoginServlet] 浏览器即将收到 Set-Cookie 响应头，应包含 JSESSIONID=" + session.getId());
            System.out.println("========================================");
            response.sendRedirect(request.getContextPath() + "/" + redirectPage);

        } else {
            // 登陆失败，返回错误
            request.setAttribute("error", "invalid email or password");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
            dispatcher.forward(request, response);
        }
    }
}
