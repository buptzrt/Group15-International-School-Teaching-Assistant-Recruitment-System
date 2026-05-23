package com.me.finaldesignproject.dao;

import com.me.finaldesignproject.model.StudentProfile;
import com.me.finaldesignproject.testing.TestSupport;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class StudentProfileDaoTest {
    @TempDir
    Path tempDir;

    @Test
    void loadAllCreatesMissingFileAndReturnsEmptyMap() {
        Path profilesFile = tempDir.resolve("student_profiles.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile);

            Map<String, StudentProfile> profiles = new StudentProfileDao().loadAll();

            assertTrue(profiles.isEmpty());
            assertTrue(profilesFile.toFile().exists());
        }
    }

    @Test
    void saveRejectsBlankEnrollmentNumber() {
        Path profilesFile = tempDir.resolve("student_profiles.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile);
            StudentProfile profile = new StudentProfile();
            profile.setEnrollmentNo(" ");

            assertFalse(new StudentProfileDao().save(profile));
        }
    }

    @Test
    void saveAndGetByEnrollmentTrimAndPersistProfile() throws Exception {
        Path profilesFile = tempDir.resolve("student_profiles.json");

        try (TestSupport support = new TestSupport()) {
            support.withProperty(StudentProfileDao.STUDENT_PROFILE_JSON_PATH_PROPERTY, profilesFile);
            StudentProfile profile = new StudentProfile();
            profile.setEnrollmentNo(" 2023213999 ");
            profile.setFullName("Test Student");
            profile.setEmail("student@example.com");
            profile.setSkills("Java, SQL");

            StudentProfileDao dao = new StudentProfileDao();
            assertTrue(dao.save(profile));

            StudentProfile stored = dao.getByEnrollment("2023213999");
            assertNotNull(stored);
            assertEquals("2023213999", stored.getEnrollmentNo());
            assertEquals("Test Student", stored.getFullName());
        }
    }
}
