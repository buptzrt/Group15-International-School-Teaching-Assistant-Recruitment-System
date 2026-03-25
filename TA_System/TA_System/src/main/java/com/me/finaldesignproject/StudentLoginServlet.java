package com.me.finaldesignproject;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet; // 确保引入了注解

// 引入你新建的模型和 DAO 工具
import com.me.finaldesignproject.model.User;
import com.me.finaldesignproject.dao.UserDao;

@WebServlet("/StudentLoginServlet") // 路由地址，对应 jsp 表单里的 action
public class    StudentLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1.接收前端传来的登录账号（可能是邮箱，也可能是学号）
        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");

        // 2. 调用我们自己写的 UserDao，去本地的 JSON 文件里查找匹配的用户
        UserDao userDao = new UserDao();
        User loggedInUser = userDao.login(loginId, password);

        // 3. 判断是否查到了该用户
        if (loggedInUser != null) {
            // ✅ 登录成功：把用户信息存入 Session
            // 注意：这里的属性名 ("email", "full_name" 等) 必须和原来的保持一致，以免 JSP 报错
            HttpSession session = request.getSession();
            session.setAttribute("email", loggedInUser.getEmail());
            session.setAttribute("full_name", loggedInUser.getFullName());
            session.setAttribute("enrollment_no", loggedInUser.getEnrollmentNo());
            session.setAttribute("branch", loggedInUser.getBranch());

            // 跳转到学生主页
            response.sendRedirect("student_home.jsp");
        } else {
            // ❌ 登录失败：账号或密码在 JSON 里找不到
            request.setAttribute("error", "Invalid Email or Password");
            RequestDispatcher rd = request.getRequestDispatcher("student_login.jsp");
            rd.forward(request, response);
        }
    }
}
