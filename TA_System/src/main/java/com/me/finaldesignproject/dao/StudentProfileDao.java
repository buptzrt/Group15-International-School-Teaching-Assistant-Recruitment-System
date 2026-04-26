package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.StudentProfile;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

public class StudentProfileDao {

    private static final String FILE_NAME = "student_profiles.json";
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    private static Path resolvePath() {
        return Paths.get("D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/" + FILE_NAME);

    }

    public Map<String, StudentProfile> loadAll() {
        Path path = resolvePath();

        try {
            if (Files.notExists(path)) {
                Files.createDirectories(path.getParent());
                Files.writeString(path, "{}", StandardCharsets.UTF_8);
            }
        } catch (Exception e) {
            System.err.println("StudentProfileDao init: " + path + " - " + e.getMessage());
        }

        try (InputStream is = Files.newInputStream(path);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            Type type = new TypeToken<Map<String, StudentProfile>>() {}.getType();
            Map<String, StudentProfile> map = GSON.fromJson(reader, type);
            return map == null ? new LinkedHashMap<>() : map;
        } catch (Exception e) {
            System.err.println("StudentProfileDao read: " + path + " - " + e.getMessage());
            return new LinkedHashMap<>();
        }
    }

    public StudentProfile getByEnrollment(String enrollmentNo) {
        if (enrollmentNo == null) {
            return null;
        }
        return loadAll().get(enrollmentNo.trim());
    }

    public boolean save(StudentProfile profile) {
        if (profile == null || profile.getEnrollmentNo() == null || profile.getEnrollmentNo().isBlank()) {
            return false;
        }

        String key = profile.getEnrollmentNo().trim();
        Map<String, StudentProfile> profiles = loadAll();
        profile.setEnrollmentNo(key);
        profiles.put(key, profile);

        Path path = resolvePath();
        try (OutputStreamWriter writer = new OutputStreamWriter(Files.newOutputStream(path), StandardCharsets.UTF_8)) {
            GSON.toJson(profiles, writer);
            return true;
        } catch (Exception e) {
            System.err.println("StudentProfileDao write: " + path);
            e.printStackTrace();
            return false;
        }
    }
}
