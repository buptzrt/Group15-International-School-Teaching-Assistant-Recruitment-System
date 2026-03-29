package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.User;

import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    private static final String USER_JSON_FILE = "users.json";

    /**
     * 获取 users.json 文件的路径
     * 优先使用 classpath 中的文件（运行时），如果找不到就使用开发环境的路径
     */
    private static String getUserJsonPath() {
        try {
            // 尝试从 classpath 加载（运行时路径）
            InputStream resourceStream = UserDao.class.getClassLoader().getResourceAsStream(USER_JSON_FILE);
            if (resourceStream != null) {
                resourceStream.close();
                // 从 classpath 获取路径
                String classPath = UserDao.class.getClassLoader().getResource(USER_JSON_FILE).getPath();
                return classPath;
            }
        } catch (Exception e) {
            // 忽略异常，使用备选方案
        }

        // 备选方案：使用开发环境路径（相对于项目根目录）
        String projectRoot = System.getProperty("user.dir");
        return Paths.get(projectRoot, "src", "main", "resources", USER_JSON_FILE).toString();
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String filePath = getUserJsonPath();

        try (InputStream is = new FileInputStream(filePath);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {

            Type listType = new TypeToken<List<User>>() {}.getType();
            users = new Gson().fromJson(reader, listType);

            if (users == null) {
                users = new ArrayList<>();
            }

        } catch (Exception e) {
            System.err.println("Error reading users.json from: " + filePath);
            e.printStackTrace();
        }

        return users;
    }

    public boolean userExists(String email, String enrollmentNo) {
        if (email == null && enrollmentNo == null) {
            return false;
        }
        List<User> users = getAllUsers();
        for (User u : users) {
            if (u == null) continue;
            if (email != null && u.getEmail() != null && u.getEmail().equalsIgnoreCase(email.trim())) {
                return true;
            }
            if (enrollmentNo != null && u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(enrollmentNo.trim())) {
                return true;
            }
        }
        return false;
    }

    public boolean saveUser(User user) {
        if (user == null) {
            return false;
        }

        List<User> users = getAllUsers();
        users.add(user);
        String filePath = getUserJsonPath();

        try (java.io.Writer writer = new java.io.OutputStreamWriter(
                new java.io.FileOutputStream(filePath), StandardCharsets.UTF_8)) {
            new com.google.gson.Gson().toJson(users, writer);
            return true;
        } catch (Exception e) {
            System.err.println("Error writing users.json to: " + filePath);
            e.printStackTrace();
            return false;
        }
    }

    public User login(String loginId, String password) {
        List<User> users = getAllUsers();

        if (loginId == null || password == null) {
            return null;
        }

        String inputId = loginId.trim();
        String inputPwd = password.trim();

        for (User user : users) {
            if (user == null) {
                continue;
            }

            boolean idMatch =
                    (user.getEmail() != null && inputId.equalsIgnoreCase(user.getEmail().trim())) ||
                    (user.getEnrollmentNo() != null && inputId.equalsIgnoreCase(user.getEnrollmentNo().trim()));

            boolean passwordMatch =
                    user.getPassword() != null && inputPwd.equals(user.getPassword().trim());

            if (idMatch && passwordMatch) {
                return user;
            }
        }

        return null;
    }
}