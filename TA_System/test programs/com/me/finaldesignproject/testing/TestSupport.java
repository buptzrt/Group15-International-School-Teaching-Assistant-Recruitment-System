package com.me.finaldesignproject.testing;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public final class TestSupport implements AutoCloseable {
    private final Map<String, String> originalProperties = new HashMap<>();

    public TestSupport withProperty(String key, Path value) {
        if (!originalProperties.containsKey(key)) {
            originalProperties.put(key, System.getProperty(key));
        }
        System.setProperty(key, value.toString());
        return this;
    }

    public TestSupport withProperty(String key, String value) {
        if (!originalProperties.containsKey(key)) {
            originalProperties.put(key, System.getProperty(key));
        }
        System.setProperty(key, value);
        return this;
    }

    public Path write(Path path, String content) throws IOException {
        Path parent = path.getParent();
        if (parent != null) {
            Files.createDirectories(parent);
        }
        Files.writeString(path, content, StandardCharsets.UTF_8);
        return path;
    }

    public String read(Path path) throws IOException {
        if (Files.notExists(path)) {
            return "";
        }
        return Files.readString(path, StandardCharsets.UTF_8);
    }

    @Override
    public void close() {
        for (Map.Entry<String, String> entry : originalProperties.entrySet()) {
            if (entry.getValue() == null) {
                System.clearProperty(entry.getKey());
            } else {
                System.setProperty(entry.getKey(), entry.getValue());
            }
        }
    }
}
