package com.spareshub.repo;

import com.spareshub.entity.VoiceCorrection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VoiceCorrectionRepo extends JpaRepository<VoiceCorrection, Integer> {
    Optional<VoiceCorrection> findFirstByRecognizedTextIgnoreCase(String recognizedText);
}
