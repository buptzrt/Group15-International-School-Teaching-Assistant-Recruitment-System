package com.me.finaldesignproject;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RegistrationRulesTest {

    @Test
    void acceptsValidPublicEnrollmentNumbers() {
        assertTrue(RegistrationRules.isValidPublicEnrollmentNo("2023213001"));
        assertTrue(RegistrationRules.isValidPublicEnrollmentNo(" 2026212999 "));
    }

    @Test
    void rejectsInvalidPublicEnrollmentNumbers() {
        assertFalse(RegistrationRules.isValidPublicEnrollmentNo(null));
        assertFalse(RegistrationRules.isValidPublicEnrollmentNo("2027213001"));
        assertFalse(RegistrationRules.isValidPublicEnrollmentNo("2023214001"));
        assertFalse(RegistrationRules.isValidPublicEnrollmentNo("20232130"));
    }
}
