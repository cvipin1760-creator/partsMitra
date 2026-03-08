package com.spareshub.controller;

import com.spareshub.entity.NotificationEntity;
import com.spareshub.repo.NotificationRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notifications")
public class NotificationController {
    private final NotificationRepo repo;
    public NotificationController(NotificationRepo repo) { this.repo = repo; }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        NotificationEntity n = new NotificationEntity();
        n.setTitle(String.valueOf(body.get("title")));
        n.setMessage(String.valueOf(body.get("message")));
        n.setTargetRole(String.valueOf(body.get("targetRole")));
        n.setCreatedAt(new Date().toInstant().toString());
        repo.save(n);
        return ResponseEntity.ok(Map.of("status", "OK"));
    }

    @GetMapping("/my")
    public ResponseEntity<?> my(@RequestParam String role) {
        List<NotificationEntity> all = repo.findAll();
        return ResponseEntity.ok(all.stream()
                .filter(n -> "ALL".equalsIgnoreCase(n.getTargetRole()) || n.getTargetRole().equalsIgnoreCase(role))
                .sorted(Comparator.comparing(NotificationEntity::getCreatedAt).reversed())
                .toList());
    }
}
