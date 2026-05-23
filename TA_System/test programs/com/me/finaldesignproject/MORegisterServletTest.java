package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.testing.TestSupport;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MORegisterServletTest {
    @TempDir
    Path tempDir;

    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    RequestDispatcher dispatcher;

    @Test
    void successfulRegistrationSavesMoRole() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonParameters("Module Organizer", "2023213006", "mo@example.com", "123456", "123456");

            new MORegisterServlet().doPost(request, response);

            verify(response).sendRedirect("login.jsp");
            String saved = support.read(usersFile);
            assertTrue(saved.contains("\"role\":\"MO\""));
            assertTrue(saved.contains("\"fullName\":\"Module Organizer\""));
        }
    }

    @Test
    void duplicateMoRegistrationShowsError() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, """
                    [{"enrollmentNo":"2023213006","email":"mo@example.com","password":"123456","fullName":"Old MO","role":"MO"}]
                    """);
            stubCommonParameters("Module Organizer", "2023213006", "mo@example.com", "123456", "123456");
            when(request.getRequestDispatcher("mo_register.jsp")).thenReturn(dispatcher);

            new MORegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", "Email or ID already exists.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    void invalidMoEnrollmentShowsRuleText() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonParameters("Module Organizer", "bad-id", "mo@example.com", "123456", "123456");
            when(request.getRequestDispatcher("mo_register.jsp")).thenReturn(dispatcher);

            new MORegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", RegistrationRules.PUBLIC_ID_RULE_TEXT);
            verify(dispatcher).forward(request, response);
        }
    }

    private void stubCommonParameters(String companyName, String enrollmentNo, String email,
                                      String password, String confirmPassword) {
        when(request.getParameter("company_name")).thenReturn(companyName);
        when(request.getParameter("enrollment_no")).thenReturn(enrollmentNo);
        when(request.getParameter("email")).thenReturn(email);
        when(request.getParameter("password")).thenReturn(password);
        when(request.getParameter("confirm_password")).thenReturn(confirmPassword);
    }
}
