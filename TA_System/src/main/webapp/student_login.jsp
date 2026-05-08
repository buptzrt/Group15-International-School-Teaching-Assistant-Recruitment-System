<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 兼容旧逻辑：系统里有多处 sendRedirect("student_login.jsp")
    // 但当前项目实际只有 login.jsp，因此这里直接跳转到 login.jsp，避免 404。
    response.sendRedirect("login.jsp");
%>

