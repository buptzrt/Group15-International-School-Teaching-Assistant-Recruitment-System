package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.User;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    // 🚨 极度重要：把这里的路径换成你电脑上 data/users.json 的绝对路径！
    // 注意 Windows 路径要把单斜杠 \ 换成双斜杠 \\ 或者正斜杠 /
    //改成自己的绝对地址
    private static final String FILE_PATH = "D:/Desktop/Study/three down/software_eng/project/sys/Group15-International-School-Teaching-Assistant-Recruitment-System/TA_System/TA_System/data/users.json";
    //private static final String FILE_PATH = "data/users.json";
    private Gson gson = new Gson();

    // 方法1：读取所有用户
    public List<User> getAllUsers() {
        try (Reader reader = new FileReader(FILE_PATH)) {
            List<User> users = gson.fromJson(reader, new TypeToken<List<User>>(){}.getType());
            return users != null ? users : new ArrayList<>();
        } catch (FileNotFoundException e) {
            return new ArrayList<>(); // 如果文件还没建好，返回空列表
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 方法2：保存用户列表到 JSON
    public synchronized void saveAllUsers(List<User> users) {
        try (Writer writer = new FileWriter(FILE_PATH)) {
            gson.toJson(users, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // 方法3：注册新用户
    public boolean register(User newUser) {
        List<User> users = getAllUsers();
        // 检查学号是否已经存在
        for (User u : users) {
            if (u.getEnrollmentNo().equals(newUser.getEnrollmentNo())) {
                return false; // 注册失败，已存在
            }
        }
        users.add(newUser);
        saveAllUsers(users);
        return true; // 注册成功
    }

    // 方法4：登录验证-用学号/邮箱登陆
    public User login(String loginId, String password) {
        List<User> users = getAllUsers();

        for (User u : users) {
            // 判断前提：密码必须对
            if (u.getPassword() != null && u.getPassword().equals(password)) {

                // 核心逻辑：输入的 loginId 要么等于学号，要么等于邮箱
                boolean matchId = u.getEnrollmentNo() != null && u.getEnrollmentNo().equals(loginId);
                boolean matchEmail = u.getEmail() != null && u.getEmail().equals(loginId);

                if (matchId || matchEmail) {
                    return u; // 只要匹配上其中一个，就允许登录！
                }
            }
        }
        return null; // 账号或密码错误
    }
}
