package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.User;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    // Fixed path to your current project users.json
    private static final String FILE_PATH = "D:/Group15_TA_SYSTEM-sirong-new_admin_modi/TA_MO/TA_System/TA_System/data/users.json";

    private final Gson gson = new Gson();

    private File getUserFile() {
        return new File(FILE_PATH);
    }

    public List<User> getAllUsers() {
        File userFile = getUserFile();
        if (!userFile.exists()) {
            return new ArrayList<>();
        }

        try (Reader reader = new FileReader(userFile)) {
            Type listType = new TypeToken<List<User>>() {}.getType();
            List<User> users = gson.fromJson(reader, listType);
            return users != null ? users : new ArrayList<>();
        } catch (FileNotFoundException e) {
            return new ArrayList<>();
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public User login(String loginId, String password) {
        List<User> users = getAllUsers();
        if (loginId == null || password == null) {
            return null;
        }

        String inputId = loginId.trim();
        for (User u : users) {
            if (u.getPassword() != null && u.getPassword().equals(password)) {
                boolean matchId = u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(inputId);
                boolean matchEmail = u.getEmail() != null && u.getEmail().equalsIgnoreCase(inputId);
                if (matchId || matchEmail) {
                    return u;
                }
            }
        }
        return null;
    }

    public synchronized boolean addUser(User newUser) {
        List<User> users = getAllUsers();

        for (User u : users) {
            if (u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(newUser.getEnrollmentNo())) {
                return false;
            }
            if (u.getEmail() != null && u.getEmail().equalsIgnoreCase(newUser.getEmail())) {
                return false;
            }
        }

        users.add(newUser);

        File userFile = getUserFile();
        File parent = userFile.getParentFile();
        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }

        try (Writer writer = new FileWriter(userFile)) {
            gson.toJson(users, writer);
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean userExists(String enrollmentNo, String email) {
        List<User> users = getAllUsers();
        for (User u : users) {
            if (enrollmentNo != null && enrollmentNo.equalsIgnoreCase(u.getEnrollmentNo())) {
                return true;
            }
            if (email != null && email.equalsIgnoreCase(u.getEmail())) {
                return true;
            }
        }
        return false;
    }
}