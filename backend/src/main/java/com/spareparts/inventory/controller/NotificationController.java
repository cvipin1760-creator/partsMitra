package com.spareparts.inventory.controller;

import com.spareparts.inventory.entity.Notification;
import com.spareparts.inventory.entity.User;
import com.spareparts.inventory.repository.NotificationRepository;
import com.spareparts.inventory.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import com.spareparts.inventory.service.FcmService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FcmService fcmService;

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(
            @RequestParam String role,
            @RequestParam Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || user.getLastNotificationReadAt() == null) {
            return ResponseEntity.ok(notificationRepository.countByUserIdOrTargetRoleOrTargetRole(userId, role, "ALL"));
        }
        return ResponseEntity.ok(notificationRepository.countByUserIdOrTargetRoleOrTargetRoleAndCreatedAtAfter(userId, role, "ALL", user.getLastNotificationReadAt()));
    }

    @PostMapping("/mark-all-read")
    public ResponseEntity<?> markAllRead(@RequestParam Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user != null) {
            user.setLastNotificationReadAt(LocalDateTime.now());
            userRepository.save(user);
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/my")
    public ResponseEntity<List<Notification>> getMyNotifications(
            @RequestParam String role,
            @RequestParam(required = false) Long userId) {
        if (userId != null) {
            return ResponseEntity.ok(notificationRepository.findByUserIdOrTargetRoleOrTargetRoleOrderByCreatedAtDesc(userId, role, "ALL"));
        }
        return ResponseEntity.ok(notificationRepository.findByTargetRoleOrTargetRoleOrderByCreatedAtDesc(role, "ALL"));
    }

    @PostMapping("/send/broadcast")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<?> sendBroadcast(@RequestBody Map<String, String> request) {
        String title = request.get("title");
        String message = request.get("message");
        String offerType = request.get("offerType");
        String imageUrl = request.get("imageUrl");
        fcmService.sendBroadcast(title, message, offerType, imageUrl);
        return ResponseEntity.ok("Broadcast notification sent successfully");
    }

    @PostMapping("/send/user/{userId}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<?> sendToUser(@PathVariable Long userId, @RequestBody Map<String, String> request) {
        String title = request.get("title");
        String message = request.get("message");
        String offerType = request.get("offerType");
        String imageUrl = request.get("imageUrl");
        fcmService.sendToUser(userId, title, message, offerType, imageUrl);
        return ResponseEntity.ok("Targeted notification sent successfully");
    }

    @PostMapping("/send/role/{role}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<?> sendToRole(@PathVariable String role, @RequestBody Map<String, String> request) {
        String title = request.get("title");
        String message = request.get("message");
        String offerType = request.get("offerType");
        String imageUrl = request.get("imageUrl");
        fcmService.sendToRole(role, title, message, offerType, imageUrl);
        return ResponseEntity.ok("Role-based notification sent successfully");
    }
}
