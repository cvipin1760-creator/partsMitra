package com.spareparts.inventory.repository;

import com.spareparts.inventory.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.time.LocalDateTime;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByTargetRoleOrTargetRoleOrderByCreatedAtDesc(String targetRole, String allRole);
    List<Notification> findByUserIdOrTargetRoleOrTargetRoleOrderByCreatedAtDesc(Long userId, String targetRole, String allRole);
    
    long countByTargetRoleOrTargetRoleAndCreatedAtAfter(String targetRole, String allRole, LocalDateTime date);
    long countByUserIdOrTargetRoleOrTargetRoleAndCreatedAtAfter(Long userId, String targetRole, String allRole, LocalDateTime date);
    
    long countByTargetRoleOrTargetRole(String targetRole, String allRole);
    long countByUserIdOrTargetRoleOrTargetRole(Long userId, String targetRole, String allRole);
}
