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
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Student 个人资料数据访问对象（DAO）
 * 
 * 负责 Student 个人资料的持久化操作，包括：
 * 1. 从 student_profiles.json 文件加载所有 Student 个人资料
 * 2. 根据学号查询 Student 个人资料
 * 3. 保存或更新 Student 个人资料
 * 
 * 使用 GSON 库处理 JSON 数据，支持自动格式化保存（PrettyPrinting）
 * 采用键值对（Map）结构，以学号作为 key 存储 Student 信息
 * 
 * @author Team
 * @version 1.0
 */
public class StudentProfileDao {

    private static final String FILE_NAME = "student_profiles.json";
    // 创建 GSON 实例并启用格式化打印以提高 JSON 可读性
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    /**
     * 解析 student_profiles.json 文件的路径
     *
     * 使用本地绝对路径：
     * 将JSON文件存储在resources目录中
     *
     * @return student_profiles.json 文件的 Path 对象
     */
    private static Path resolvePath() {
        // 使用resources目录作为存储位置
        return Paths.get("E:/Group15_TA_SYSTEM/TA_System/src/main/resources/" + FILE_NAME);
    }

    /**
     * 加载所有 Student 个人资料
     * 
     * 从 student_profiles.json 文件中读取所有 Student 资料，以键值对形式存储
     * 如果文件不存在则创建空文件；如果读取失败则返回空 Map
     * 
     * @return Map 对象，key 为学号，value 为 StudentProfile 对象；读取失败返回空 Map
     */
    public Map<String, StudentProfile> loadAll() {
        Path path = resolvePath();

        try {
            // 检查文件是否存在，不存在则创建空 JSON 文件
            if (Files.notExists(path)) {
                Files.createDirectories(path.getParent());
                Files.writeString(path, "{}", StandardCharsets.UTF_8);
            }
        } catch (Exception e) {
            System.err.println("StudentProfileDao init: " + path + " - " + e.getMessage());
        }

        try (InputStream is = Files.newInputStream(path);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            // 使用 GSON 反序列化 JSON 为 Map<String, StudentProfile> 类型
            Type type = new TypeToken<Map<String, StudentProfile>>() {}.getType();
            Map<String, StudentProfile> map = GSON.fromJson(reader, type);
            // 如果解析结果为 null，返回空 Map
            if (map == null) {
                return new LinkedHashMap<>();
            }
            return map;
        } catch (Exception e) {
            System.err.println("StudentProfileDao read: " + path + " - " + e.getMessage());
            return new LinkedHashMap<>();
        }
    }

    /**
     * 根据学号查询 Student 个人资料
     * 
     * @param enrollmentNo Student 的学号
     * @return 返回对应的 StudentProfile 对象，若不存在返回 null
     */
    public StudentProfile getByEnrollment(String enrollmentNo) {
        if (enrollmentNo == null) {
            return null;
        }
        // 以学号作为 key 从 Map 中查询对应的 Student 资料
        return loadAll().get(enrollmentNo.trim());
    }

    /**
     * 保存或更新 Student 个人资料
     * 
     * 将 Student 资料保存到 student_profiles.json 文件，如果已存在则覆盖
     * 使用学号作为唯一标识 key
     * 
     * @param profile 要保存的 StudentProfile 对象
     * @return 保存成功返回 true，失败或输入为 null 返回 false
     */
    public boolean save(StudentProfile profile) {
        // 验证资料对象和学号不为空
        if (profile == null || profile.getEnrollmentNo() == null || profile.getEnrollmentNo().isBlank()) {
            return false;
        }

        // 获取学号作为 key，并进行 trim 处理
        String key = profile.getEnrollmentNo().trim();
        // 加载所有现有资料
        Map<String, StudentProfile> profiles = loadAll();
        // 更新学号（确保一致性）
        profile.setEnrollmentNo(key);
        // 将资料添加到 Map 中（如果已存在则覆盖）
        profiles.put(key, profile);

        // 将更新后的资料写回文件
        Path path = resolvePath();
        try (OutputStreamWriter writer = new OutputStreamWriter(Files.newOutputStream(path), StandardCharsets.UTF_8)) {
            // 使用 GSON 将 Map 序列化为格式化的 JSON 并写入文件
            GSON.toJson(profiles, writer);
            return true;
        } catch (Exception e) {
            System.err.println("StudentProfileDao write: " + path);
            e.printStackTrace();
            return false;
        }
    }
}
