package com.spareshub.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URISyntaxException;

@Configuration
public class DataSourceConfig {
    @Bean
    public DataSource dataSource() throws URISyntaxException {
        String databaseUrl = System.getenv("DATABASE_URL");
        String jdbcUrl = System.getenv("SPRING_DATASOURCE_URL");
        String username = System.getenv("SPRING_DATASOURCE_USERNAME");
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        if (!StringUtils.hasText(jdbcUrl) && StringUtils.hasText(databaseUrl)) {
            URI dbUri = new URI(databaseUrl);
            username = dbUri.getUserInfo().split(":")[0];
            password = dbUri.getUserInfo().split(":")[1];
            String host = dbUri.getHost();
            int port = dbUri.getPort() == -1 ? 5432 : dbUri.getPort();
            String path = dbUri.getPath();
            jdbcUrl = "jdbc:postgresql://" + host + ":" + port + path + "?sslmode=require";
        }
        HikariConfig config = new HikariConfig();
        if (StringUtils.hasText(jdbcUrl)) config.setJdbcUrl(jdbcUrl);
        if (StringUtils.hasText(username)) config.setUsername(username);
        if (StringUtils.hasText(password)) config.setPassword(password);
        return new HikariDataSource(config);
    }
}
