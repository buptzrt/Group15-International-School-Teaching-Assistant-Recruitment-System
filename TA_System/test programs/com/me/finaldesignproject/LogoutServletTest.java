package com.me.finaldesignproject;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LogoutServletTest {
    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    HttpSession session;

    @Test
    void doGetInvalidatesExistingSession() throws Exception {
        when(request.getSession(false)).thenReturn(session);

        new LogoutServlet().doGet(request, response);

        verify(session).invalidate();
        verify(response).sendRedirect("index.html");
    }

    @Test
    void doGetWithoutSessionStillRedirects() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        new LogoutServlet().doGet(request, response);

        verify(response).sendRedirect("index.html");
    }

    @Test
    void doPostDelegatesToDoGet() throws Exception {
        when(request.getSession(false)).thenReturn(session);

        new LogoutServlet().doPost(request, response);

        verify(session).invalidate();
        verify(response).sendRedirect("index.html");
        verify(request, never()).getSession(true);
    }
}
