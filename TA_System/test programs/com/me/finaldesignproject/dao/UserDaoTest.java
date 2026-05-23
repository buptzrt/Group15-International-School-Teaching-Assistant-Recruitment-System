package com.me.finaldesignproject.dao;

import com.me.finaldesignproject.model.User;
import com.me.finaldesignproject.testing.TestSupport;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserDaoTest {
    private static final String USERS_JSON = """
            [
              {
                "enrollmentNo": "2023213001",
                "email": "student@example.com",
                "password": "secret123",
                "fullName": "Alice Student",
                "branch": "CS",
                "role": "Student"
              },
              {
                "enrollmentNo": "2023213002",
                "email": "mo@example.com",
                "password": "organizer456",
                "fullName": "Bob Organizer",
                "branch": "SE",
                "role": "MO"
              }
            ]
            """;

    @TempDir
    Path tempDir;

    @Test
    void getAllUsersReturnsEmptyListWhenJsonArrayIsEmpty() throws Exception {
        Path usersFile = tempDir.resolve("users.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, "[]");

            assertTrue(new UserDao().getAllUsers().isEmpty());
        }
    }

    @Test
    void loginMatchesByEmailAndEnrollment() throws Exception {
        Path usersFile = tempDir.resolve("users.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);
            UserDao dao = new UserDao();

            assertNotNull(dao.login("student@example.com", "secret123"));
            assertNotNull(dao.login("2023213002", "organizer456"));
            assertNull(dao.login("student@example.com", "bad"));
        }
    }

    @Test
    void userExistsChecksBothIdentifiersCaseInsensitively() throws Exception {
        Path usersFile = tempDir.resolve("users.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);
            UserDao dao = new UserDao();

            assertTrue(dao.userExists("STUDENT@example.com", null));
            assertTrue(dao.userExists(null, "2023213002"));
            assertFalse(dao.userExists("missing@example.com", "2023213999"));
        }
    }

    @Test
    void saveUserAppendsAndCanBeReadBack() throws Exception {
        Path usersFile = tempDir.resolve("users.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(UserDao.USER_JSON_PATH_PROPERTY, usersFile);
            support.write(usersFile, USERS_JSON);
            UserDao dao = new UserDao();

            assertTrue(dao.saveUser(new User("2023213003", "new@example.com", "pass789", "Cara New", "AI", "Student")));

            List<User> users = dao.getAllUsers();
            assertEquals(3, users.size());
            assertEquals("new@example.com", dao.getUserByEnrollment("2023213003").getEmail());
        }
    }
}
