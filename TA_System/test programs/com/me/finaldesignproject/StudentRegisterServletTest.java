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
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StudentRegisterServletTest {
    private static final String EXISTING_USERS_JSON = """
            [
              {
                "enrollmentNo": "2023213001",
                "email": "student@example.com",
                "password": "secret123",
                "fullName": "Alice Student",
                "branch": "CS",
                "role": "Student"
              }
            ]
            """;

    @TempDir
    Path tempDir;

    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    RequestDispatcher dispatcher;

    @Test
    void rejectsBlankFields() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonRegistrationParameters("", "2023213005", "new@example.com", "123456", "123456");
            when(request.getRequestDispatcher("student_register.jsp")).thenReturn(dispatcher);

            new StudentRegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", "All fields are required.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    void rejectsInvalidEnrollmentNumber() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonRegistrationParameters("Test Student", "2027213005", "new@example.com", "123456", "123456");
            when(request.getRequestDispatcher("student_register.jsp")).thenReturn(dispatcher);

            new StudentRegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", RegistrationRules.PUBLIC_ID_RULE_TEXT);
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    void rejectsPasswordMismatch() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonRegistrationParameters("Test Student", "2023213005", "new@example.com", "123456", "654321");
            when(request.getRequestDispatcher("student_register.jsp")).thenReturn(dispatcher);

            new StudentRegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", "Passwords do not match.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    void rejectsDuplicateUser() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, EXISTING_USERS_JSON);
            stubCommonRegistrationParameters("Test Student", "2023213001", "student@example.com", "123456", "123456");
            when(request.getRequestDispatcher("student_register.jsp")).thenReturn(dispatcher);

            new StudentRegisterServlet().doPost(request, response);

            verify(request).setAttribute("error", "Email or ID already exists.");
            verify(dispatcher).forward(request, response);
        }
    }

    @Test
    void successfulRegistrationSavesStudentAndRedirects() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");
            stubCommonRegistrationParameters("New Student", "2023213005", "new@example.com", "123456", "123456");

            new StudentRegisterServlet().doPost(request, response);

            verify(response).sendRedirect("login.jsp");
            verify(request, never()).setAttribute(org.mockito.ArgumentMatchers.eq("error"), org.mockito.ArgumentMatchers.any());
            assertTrue(support.read(usersFile).contains("\"role\":\"Student\""));
            assertTrue(support.read(usersFile).contains("\"email\":\"new@example.com\""));
        }
    }

    private void stubCommonRegistrationParameters(String fullName, String enrollmentNo, String email,
                                                  String password, String confirmPassword) {
        when(request.getParameter("full_name")).thenReturn(fullName);
        when(request.getParameter("enrollment_no")).thenReturn(enrollmentNo);
        when(request.getParameter("email")).thenReturn(email);
        when(request.getParameter("password")).thenReturn(password);
        when(request.getParameter("confirm_password")).thenReturn(confirmPassword);
    }
}
