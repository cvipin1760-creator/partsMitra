package com.spareshub.repo;

import com.spareshub.entity.NotificationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepo extends JpaRepository<NotificationEntity, Integer> {
}
