package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.model.User;
import java.io.IOException;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/StudentLoginServlet")
public class StudentLoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginId = request.getParameter("loginId");
        String password = request.getParameter("password");

        com.me.finaldesignproject.dao.UserDao userDao = new com.me.finaldesignproject.dao.UserDao();
        User loggedInUser = userDao.login(loginId, password);

        if (loggedInUser != null) {
            HttpSession session = request.getSession();
            session.setAttribute("email", loggedInUser.getEmail());
            session.setAttribute("full_name", loggedInUser.getFullName());
            session.setAttribute("enrollment_no", loggedInUser.getEnrollmentNo());
            session.setAttribute("branch", loggedInUser.getBranch());
            response.sendRedirect("student_home.jsp");
            return;
        }

        request.setAttribute("error", "Invalid Email or Password");
        RequestDispatcher rd = request.getRequestDispatcher("student_login.jsp");
        rd.forward(request, response);
    }
}