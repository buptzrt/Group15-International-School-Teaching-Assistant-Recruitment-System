package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.User;

import java.io.*;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    // 确保路径指向你当前的 E 盘项目位置
    private static final String FILE_PATH = "E:/TA_SYSTEM/TA_System/TA_System/data/users.json";
    private Gson gson = new Gson();

    // 1. 获取所有用户（无论角色）
    public List<User> getAllUsers() {
        try (Reader reader = new FileReader(FILE_PATH)) {
            Type listType = new TypeToken<List<User>>(){}.getType();
            List<User> users = gson.fromJson(reader, listType);
            return users != null ? users : new ArrayList<>();
        } catch (FileNotFoundException e) {
            return new ArrayList<>();
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 2. 统一登录验证 (管理员输入 AD001 或 邮箱 都能登)
    public User login(String loginId, String password) {
        List<User> users = getAllUsers();
        if (loginId == null || password == null) return null;

        String inputId = loginId.trim();

        for (User u : users) {
            // 密码匹配
            if (u.getPassword() != null && u.getPassword().equals(password)) {
                // 账号匹配：要么匹配学号/工号，要么匹配邮箱
                boolean matchId = u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(inputId);
                boolean matchEmail = u.getEmail() != null && u.getEmail().equalsIgnoreCase(inputId);

                if (matchId || matchEmail) {
                    return u;
                }
            }
        }
        return null;
    }

    // 3. 统一注册/添加用户 (支持管理员和学生)
    public synchronized boolean addUser(User newUser) {
        List<User> users = getAllUsers();

        // 查重：学号/工号 或 邮箱 只要有一个重复就不能注册
        for (User u : users) {
            if (u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(newUser.getEnrollmentNo())) {
                return false;
            }
            if (u.getEmail() != null && u.getEmail().equalsIgnoreCase(newUser.getEmail())) {
                return false;
            }
        }

        users.add(newUser);

        // 写回文件
        try (Writer writer = new FileWriter(FILE_PATH)) {
            gson.toJson(users, writer);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 4. 检查是否存在 (给 Servlet 的校验逻辑用)
    public boolean userExists(String enrollmentNo, String email) {
        List<User> users = getAllUsers();
        for (User u : users) {
            if (enrollmentNo != null && enrollmentNo.equalsIgnoreCase(u.getEnrollmentNo())) return true;
            if (email != null && email.equalsIgnoreCase(u.getEmail())) return true;
        }
        return false;
    }
}