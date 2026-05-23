package com.me.finaldesignproject.model;

import java.io.Serializable;

/**
 * Serializable user model used for authentication, authorization, and session storage.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private String enrollmentNo;
    private String email;
    private String password;
    private String fullName;
    private String branch;
    private String role;

    public User() {
    }

    public User(String enrollmentNo, String email, String password,
                String fullName, String branch, String role) {
        this.enrollmentNo = enrollmentNo;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.branch = branch;
        this.role = role;
    }

    public User(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public String getEnrollmentNo() {
        return enrollmentNo;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getFullName() {
        return fullName;
    }

    public String getBranch() {
        return branch;
    }

    public String getRole() {
        return role;
    }

    public void setEnrollmentNo(String enrollmentNo) {
        this.enrollmentNo = enrollmentNo;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setBranch(String branch) {
        this.branch = branch;
    }

    public void setRole(String role) {
        this.role = role;
    }

    @Override
    public String toString() {
        return "User{"
                + "enrollmentNo='" + enrollmentNo + '\''
                + ", email='" + email + '\''
                + ", fullName='" + fullName + '\''
                + ", branch='" + branch + '\''
                + ", role='" + role + '\''
                + '}';
    }
}
