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

/**
 * 用户数据访问对象（DAO）
 *
 * 负责用户信息的持久化操作，包括：
 * 1. 从 users.json 文件读取用户数据
 * 2. 检查用户是否已存在（邮箱或学号）
 * 3. 保存新用户到 JSON 文件
 * 4. 用户登录验证
 *
 * 使用 GSON 库处理 JSON 格式的数据，支持开发环境和运行时环境的文件路径自动切换
 *
 * @author Team
 * @version 1.0
 */
public class UserDao {

    private static final String USER_JSON_FILE = "users.json";

    /**
     * 获取 users.json 文件的路径
     *
     * 使用本地绝对路径：
     * 将JSON文件存储在resources目录中
     *
     * @return users.json 文件的完整路径
     */
    private static String getUserJsonPath() {
        // 使用resources目录作为存储位置
        return "D:/Desktop/Study/three down/software_eng/Group15_TA_SYSTEM/TA_System/src/main/resources/" + USER_JSON_FILE;
    }

    /**
     * 获取所有用户数据
     *
     * 从 users.json 文件中读取所有用户信息，使用 GSON 反序列化 JSON 数据
     * 如果文件不存在或解析异常，返回空列表
     *
     * @return 用户对象列表，若无用户或读取失败则返回空列表
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String filePath = getUserJsonPath();

        try (InputStream is = new FileInputStream(filePath);
             Reader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            // 使用 GSON 并指定目标类型为 List<User>
            Type listType = new TypeToken<List<User>>() {}.getType();
            users = new Gson().fromJson(reader, listType);

            // 如果 JSON 文件为空或解析结果为 null，初始化为空列表
            if (users == null) {
                users = new ArrayList<>();
            }

        } catch (Exception e) {
            // 输出错误日志并打印堆栈跟踪
            System.err.println("Error reading users.json from: " + filePath);
            e.printStackTrace();
        }

        return users;
    }

    /**
     * 检查用户是否已存在
     *
     * 根据邮箱或学号检查用户是否已在系统中存在
     * 邮箱比较时不区分大小写，学号比较时不区分大小写
     *
     * @param email 用户邮箱，可为 null
     * @param enrollmentNo 用户学号或 ID，可为 null
     * @return 若邮箱或学号已存在返回 true，否则返回 false
     */
    public boolean userExists(String email, String enrollmentNo) {
        // 如果邮箱和学号都为空，直接返回 false
        if (email == null && enrollmentNo == null) {
            return false;
        }

        List<User> users = getAllUsers();
        for (User u : users) {
            // 跳过 null 对象
            if (u == null) continue;

            // 检查邮箱是否已存在（不区分大小写）
            if (email != null && u.getEmail() != null && u.getEmail().equalsIgnoreCase(email.trim())) {
                return true;
            }

            // 检查学号是否已存在（不区分大小写）
            if (enrollmentNo != null && u.getEnrollmentNo() != null && u.getEnrollmentNo().equalsIgnoreCase(enrollmentNo.trim())) {
                return true;
            }
        }
        return false;
    }

    /**
     * 保存新用户到 JSON 文件
     *
     * 读取现有用户列表，将新用户添加到列表，然后将更新后的列表写入 users.json 文件
     * 使用 UTF-8 编码确保中文等特殊字符正确保存
     *
     * @param user 要保存的用户对象
     * @return 保存成功返回 true，失败返回 false
     */
    public boolean saveUser(User user) {
        // 验证用户对象不为空
        if (user == null) {
            return false;
        }

        // 获取现有的所有用户列表
        List<User> users = getAllUsers();
        // 将新用户添加到列表
        users.add(user);
        String filePath = getUserJsonPath();

        try (java.io.Writer writer = new java.io.OutputStreamWriter(
                new java.io.FileOutputStream(filePath), StandardCharsets.UTF_8)) {
            // 使用 GSON 将用户列表序列化为 JSON 格式并写入文件
            new com.google.gson.Gson().toJson(users, writer);
            return true;
        } catch (Exception e) {
            // 输出错误日志
            System.err.println("Error writing users.json to: " + filePath);
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 用户登录验证
     *
     * 根据登录 ID（可以是邮箱或学号）和密码验证用户身份
     * 登录 ID 的比对不区分大小写，密码比对区分大小写
     *
     * @param loginId 登录 ID，可以是用户邮箱或学号
     * @param password 用户密码
     * @return 登录成功返回 User 对象，失败返回 null
     */
    public User login(String loginId, String password) {
        // 获取所有用户列表
        List<User> users = getAllUsers();

        // 验证登录 ID 和密码不为空
        if (loginId == null || password == null) {
            return null;
        }

        // 清理输入的空格
        String inputId = loginId.trim();
        String inputPwd = password.trim();

        // 遍历用户列表进行逐个验证
        for (User user : users) {
            // 跳过 null 对象
            if (user == null) {
                continue;
            }

            // 检查登录 ID 是否与用户的邮箱或学号匹配（不区分大小写）
            boolean idMatch =
                    (user.getEmail() != null && inputId.equalsIgnoreCase(user.getEmail().trim())) ||
                    (user.getEnrollmentNo() != null && inputId.equalsIgnoreCase(user.getEnrollmentNo().trim()));

            // 检查密码是否与用户的密码匹配（区分大小写）
            boolean passwordMatch =
                    user.getPassword() != null && inputPwd.equals(user.getPassword().trim());

            // 如果 ID 和密码都匹配，返回该用户对象
            if (idMatch && passwordMatch) {
                return user;
            }
        }

        // 没有找到匹配的用户，返回 null
        return null;
    }
}
