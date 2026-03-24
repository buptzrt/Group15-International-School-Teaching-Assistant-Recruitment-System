package com.me.finaldesignproject.model;

public class User {
    // 私有成员变量（对应数据库字段，驼峰命名适配Java规范）
    private String enrollmentNo; // 对应 enrollment_no
    private String email;        // 用邮箱登录
    private String password;
    private String fullName;     // 对应 full_name
    private String branch;       // 对应 branch
    private String role;         // "Student", "TA" 等

    // 空参构造器（框架/反射常用，必须保留）
    public User() {}

    // 全参构造器（方便一次性创建对象）
    public User(String enrollmentNo, String email, String password,
                String fullName, String branch, String role) {
        this.enrollmentNo = enrollmentNo;
        this.email = email;
        this.password = password;
        this.fullName = fullName;
        this.branch = branch;
        this.role = role;
    }

    // 部分参构造器（可选，方便常用场景创建对象，比如仅登录用）
    public User(String email, String password) {
        this.email = email;
        this.password = password;
    }

    // ========== Getter 方法（全部） ==========
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

    // ========== Setter 方法（全部） ==========
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

    // ========== toString() 方法（方便打印/调试对象） ==========
    @Override
    public String toString() {
        return "User{" +
                "enrollmentNo='" + enrollmentNo + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", branch='" + branch + '\'' +
                ", role='" + role + '\'' +
                '}';
        // 注意：toString() 中隐藏了 password，避免调试时泄露敏感信息
    }
}
