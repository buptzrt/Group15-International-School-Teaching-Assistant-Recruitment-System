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
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    private static final String USER_JSON_PATH = "E:\\study\\software engineer\\Group15_TA_SYSTEM\\TA_System\\TA_System\\src\\main\\resources\\users.json";

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();

        try (InputStream is = new FileInputStream(USER_JSON_PATH);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {

            Type listType = new TypeToken<List<User>>() {}.getType();
            users = new Gson().fromJson(reader, listType);

            if (users == null) {
                users = new ArrayList<>();
            }

        } catch (Exception e) {
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

        try (java.io.Writer writer = new java.io.OutputStreamWriter(
                new java.io.FileOutputStream(USER_JSON_PATH), StandardCharsets.UTF_8)) {
            new com.google.gson.Gson().toJson(users, writer);
            return true;
        } catch (Exception e) {
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