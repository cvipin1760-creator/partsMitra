package com.spareparts.inventory.repository;

import com.spareparts.inventory.entity.VoiceTrainingSample;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;

public interface VoiceTrainingSampleRepository extends JpaRepository<VoiceTrainingSample, Long> {
    @Query("SELECT v FROM VoiceTrainingSample v " +
            "WHERE (:role IS NULL OR v.role = :role) " +
            "AND (:from IS NULL OR v.createdAt >= :from) " +
            "AND (:to IS NULL OR v.createdAt <= :to) " +
            "ORDER BY v.createdAt DESC")
    Page<VoiceTrainingSample> findFiltered(@Param("role") String role,
                                           @Param("from") LocalDateTime from,
                                           @Param("to") LocalDateTime to,
                                           Pageable pageable);
}
