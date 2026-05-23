package com.me.finaldesignproject;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MOLogoutServletTest {
    @Mock
    HttpServletRequest request;

    @Mock
    HttpServletResponse response;

    @Mock
    HttpSession session;

    @Test
    void doGetInvalidatesSessionAndWritesRedirectScript() throws Exception {
        StringWriter buffer = new StringWriter();
        PrintWriter writer = new PrintWriter(buffer, true);

        when(request.getSession(false)).thenReturn(session);
        when(response.getWriter()).thenReturn(writer);

        new MOLogoutServlet().doGet(request, response);

        verify(session).invalidate();
        verify(response).setContentType("text/html");
        assertTrue(buffer.toString().contains("window.top.location.href = 'index.html';"));
    }
}
