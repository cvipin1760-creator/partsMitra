package com.spareparts.inventory.controller;

import com.spareparts.inventory.entity.Notification;
import com.spareparts.inventory.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    @Autowired
    private NotificationRepository notificationRepository;

    @GetMapping("/my")
    public ResponseEntity<List<Notification>> getMyNotifications(@RequestParam String role) {
        return ResponseEntity.ok(notificationRepository.findByTargetRoleOrTargetRoleOrderByCreatedAtDesc(role, "ALL"));
    }
}
