package com.me.finaldesignproject;

import com.me.finaldesignproject.dao.UserDao;
import com.me.finaldesignproject.testing.TestSupport;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.nio.file.Path;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LoginServletTest {
    private static final String USERS_JSON = """
            [
              {
                "enrollmentNo": "2023213001",
                "email": "student@example.com",
                "password": "secret123",
                "fullName": "Alice Student",
                "branch": "CS",
                "role": "Student"
              },
              {
                "enrollmentNo": "2023213002",
                "email": "mo@example.com",
                "password": "organizer456",
                "fullName": "Bob Organizer",
                "branch": "SE",
                "role": "MO"
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
    HttpSession session;

    @Mock
    RequestDispatcher dispatcher;

    @Test
    void successfulMoLoginStoresSessionAndRememberCookie() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        Map<String, Object> sessionAttributes = new LinkedHashMap<>();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);

            stubSuccessfulLoginFlow(sessionAttributes);
            when(request.getParameter("loginId")).thenReturn("mo@example.com");
            when(request.getParameter("password")).thenReturn("organizer456");
            when(request.getParameter("remember")).thenReturn("on");
            when(request.getSession(true)).thenReturn(session);
            when(request.getSession(false)).thenReturn(session);

            new LoginServlet().doPost(request, response);

            assertEquals("2023213002", sessionAttributes.get("userId"));
            assertEquals("MO", sessionAttributes.get("userRole"));
            assertEquals("MO", sessionAttributes.get("role"));
            verify(response).sendRedirect("/TA_System/mo_home.jsp");

            ArgumentCaptor<Cookie> cookieCaptor = ArgumentCaptor.forClass(Cookie.class);
            verify(response).addCookie(cookieCaptor.capture());
            Cookie cookie = cookieCaptor.getValue();
            assertEquals("saved_login_id", cookie.getName());
            assertEquals("mo@example.com", cookie.getValue());
            assertTrue(cookie.getMaxAge() > 0);
        }
    }

    @Test
    void successfulStudentLoginWithoutRememberClearsCookie() throws Exception {
        Path usersFile = tempDir.resolve("users.json");
        Map<String, Object> sessionAttributes = new LinkedHashMap<>();

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);

            stubSuccessfulLoginFlow(sessionAttributes);
            when(request.getParameter("loginId")).thenReturn("student@example.com");
            when(request.getParameter("password")).thenReturn("secret123");
            when(request.getParameter("remember")).thenReturn(null);
            when(request.getSession(true)).thenReturn(session);
            when(request.getSession(false)).thenReturn(session);

            new LoginServlet().doPost(request, response);

            verify(response).sendRedirect("/TA_System/student_home.jsp");

            ArgumentCaptor<Cookie> cookieCaptor = ArgumentCaptor.forClass(Cookie.class);
            verify(response).addCookie(cookieCaptor.capture());
            assertEquals(0, cookieCaptor.getValue().getMaxAge());
        }
    }

    @Test
    void failedLoginForwardsBackToLoginPage() throws Exception {
        Path usersFile = tempDir.resolve("users.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);

            when(request.getParameter("loginId")).thenReturn("student@example.com");
            when(request.getParameter("password")).thenReturn("wrong-password");
            when(request.getRequestDispatcher("/login.jsp")).thenReturn(dispatcher);

            new LoginServlet().doPost(request, response);

            verify(request).setAttribute("error", "invalid email or password");
            verify(dispatcher).forward(request, response);
            verify(response, never()).sendRedirect(anyString());
        }
    }

    private void stubSuccessfulLoginFlow(Map<String, Object> sessionAttributes) {
        when(request.getContextPath()).thenReturn("/TA_System");
        when(session.getId()).thenReturn("session-1");
        when(session.getCreationTime()).thenReturn(100L);
        when(session.getLastAccessedTime()).thenReturn(200L);
        when(session.getMaxInactiveInterval()).thenReturn(1800);
        when(session.getAttributeNames()).thenAnswer(invocation -> Collections.enumeration(sessionAttributes.keySet()));
        doAnswer(invocation -> {
            sessionAttributes.put(invocation.getArgument(0), invocation.getArgument(1));
            return null;
        }).when(session).setAttribute(anyString(), any());
    }
}
