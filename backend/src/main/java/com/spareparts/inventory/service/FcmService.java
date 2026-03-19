package com.spareparts.inventory.service;

import com.google.firebase.messaging.*;
import com.spareparts.inventory.entity.Notification;
import com.spareparts.inventory.entity.User;
import com.spareparts.inventory.repository.NotificationRepository;
import com.spareparts.inventory.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FcmService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserRepository userRepository;

    public void sendToUser(Long userId, String title, String message) {
        userRepository.findById(userId).ifPresent(user -> {
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                Message fcmMessage = Message.builder()
                        .setToken(user.getFcmToken())
                        .setNotification(com.google.firebase.messaging.Notification.builder()
                                .setTitle(title)
                                .setBody(message)
                                .build())
                        .build();

                try {
                    FirebaseMessaging.getInstance().send(fcmMessage);
                    saveNotification(userId, title, message, false, null);
                } catch (FirebaseMessagingException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public void sendBroadcast(String title, String message) {
        com.google.firebase.messaging.Notification fcmNotification = com.google.firebase.messaging.Notification.builder()
                .setTitle(title)
                .setBody(message)
                .build();

        // Using topics for broadcast
        Message fcmMessage = Message.builder()
                .setTopic("all")
                .setNotification(fcmNotification)
                .build();

        try {
            FirebaseMessaging.getInstance().send(fcmMessage);
            saveNotification(null, title, message, true, "ALL");
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }

    public void sendToRole(String role, String title, String message) {
        // Alternatively, use topics per role
        Message fcmMessage = Message.builder()
                .setTopic(role)
                .setNotification(com.google.firebase.messaging.Notification.builder()
                        .setTitle(title)
                        .setBody(message)
                        .build())
                .build();

        try {
            FirebaseMessaging.getInstance().send(fcmMessage);
            saveNotification(null, title, message, false, role);
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }

    private void saveNotification(Long userId, String title, String message, boolean isBroadcast, String targetRole) {
        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setUserId(userId);
        notification.setBroadcast(isBroadcast);
        notification.setTargetRole(targetRole);
        notificationRepository.save(notification);
    }
}
