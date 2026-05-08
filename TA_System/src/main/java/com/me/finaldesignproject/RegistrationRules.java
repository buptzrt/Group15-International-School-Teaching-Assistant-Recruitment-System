package com.me.finaldesignproject;

import java.util.regex.Pattern;

public final class RegistrationRules {
    public static final String PUBLIC_ID_RULE_TEXT =
            "ID must follow 2020-2026 + 212/213 + any 3 digits, for example 2023213070.";

    private static final Pattern PUBLIC_ID_PATTERN = Pattern.compile("^202[0-6](212|213)\\d{3}$");

    private RegistrationRules() {
    }

    public static boolean isValidPublicEnrollmentNo(String enrollmentNo) {
        return enrollmentNo != null && PUBLIC_ID_PATTERN.matcher(enrollmentNo.trim()).matches();
    }
}
