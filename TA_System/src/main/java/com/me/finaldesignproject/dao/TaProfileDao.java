package com.me.finaldesignproject.dao;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.me.finaldesignproject.model.TaProfile;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.lang.reflect.Type;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

public class TaProfileDao {

    private static final String FILE_NAME = "ta_profiles.json";
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    private static Path resolvePath() {
        try {
            InputStream is = TaProfileDao.class.getClassLoader().getResourceAsStream(FILE_NAME);
            if (is != null) {
                is.close();
                URL resource = TaProfileDao.class.getClassLoader().getResource(FILE_NAME);
                if (resource != null && "file".equalsIgnoreCase(resource.getProtocol())) {
                    return Path.of(resource.toURI());
                }
            }
        } catch (Exception ignored) {
        }
        return Paths.get(System.getProperty("user.dir"), "src", "main", "resources", FILE_NAME);
    }

    public Map<String, TaProfile> loadAll() {
        Path path = resolvePath();

        try {
            if (Files.notExists(path)) {
                Files.createDirectories(path.getParent());
                Files.writeString(path, "{}", StandardCharsets.UTF_8);
            }
        } catch (Exception e) {
            System.err.println("TaProfileDao init: " + path + " - " + e.getMessage());
        }

        try (InputStream is = Files.newInputStream(path);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            Type type = new TypeToken<Map<String, TaProfile>>() {}.getType();
            Map<String, TaProfile> map = GSON.fromJson(reader, type);
            if (map == null) {
                return new LinkedHashMap<>();
            }
            return map;
        } catch (Exception e) {
            System.err.println("TaProfileDao read: " + path + " - " + e.getMessage());
            return new LinkedHashMap<>();
        }
    }

    public TaProfile getByEnrollment(String enrollmentNo) {
        if (enrollmentNo == null) {
            return null;
        }
        return loadAll().get(enrollmentNo.trim());
    }

    public boolean save(TaProfile profile) {
        if (profile == null || profile.getEnrollmentNo() == null || profile.getEnrollmentNo().isBlank()) {
            return false;
        }

        String key = profile.getEnrollmentNo().trim();
        Map<String, TaProfile> profiles = loadAll();
        profile.setEnrollmentNo(key);
        profiles.put(key, profile);

        Path path = resolvePath();
        try (OutputStreamWriter writer = new OutputStreamWriter(Files.newOutputStream(path), StandardCharsets.UTF_8)) {
            GSON.toJson(profiles, writer);
            return true;
        } catch (Exception e) {
            System.err.println("TaProfileDao write: " + path);
            e.printStackTrace();
            return false;
        }
    }
}
