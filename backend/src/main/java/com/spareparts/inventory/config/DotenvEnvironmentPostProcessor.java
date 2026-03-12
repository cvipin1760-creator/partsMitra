package com.spareparts.inventory.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertiesPropertySource;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import java.util.stream.Stream;

public class DotenvEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {
    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        try {
            Path[] candidates = new Path[] {
                    Path.of(".env"),
                    Path.of("../.env"),
                    Path.of("../../.env")
            };
            for (Path p : candidates) {
                if (Files.exists(p)) {
                    Properties props = new Properties();
                    try (Stream<String> lines = Files.lines(p)) {
                        lines.forEach(line -> {
                            String trimmed = line.trim();
                            if (trimmed.isEmpty() || trimmed.startsWith("#")) return;
                            int idx = trimmed.indexOf('=');
                            if (idx <= 0) return;
                            String key = trimmed.substring(0, idx).trim();
                            String value = trimmed.substring(idx + 1).trim();
                            if ((value.startsWith("\"") && value.endsWith("\"")) || (value.startsWith("'") && value.endsWith("'"))) {
                                value = value.substring(1, value.length() - 1);
                            }
                            if (!key.isEmpty()) {
                                props.setProperty(key, value);
                            }
                        });
                    }
                    environment.getPropertySources().addFirst(new PropertiesPropertySource("dotenv", props));
                    break;
                }
            }
        } catch (Exception ignored) {
        }
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
