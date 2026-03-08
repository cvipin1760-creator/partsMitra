package com.spareshub.controller;

import com.spareshub.entity.VoiceCorrection;
import com.spareshub.repo.VoiceCorrectionRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/voice-corrections")
public class VoiceCorrectionController {
    private final VoiceCorrectionRepo repo;
    public VoiceCorrectionController(VoiceCorrectionRepo repo) { this.repo = repo; }

    @PostMapping
    public ResponseEntity<?> add(@RequestBody Map<String, Object> body) {
        VoiceCorrection vc = new VoiceCorrection();
        vc.setRecognizedText(String.valueOf(body.get("recognizedText")));
        vc.setCorrectedText(String.valueOf(body.get("correctedText")));
        repo.save(vc);
        return ResponseEntity.ok(Map.of("status", "OK"));
    }

    @PostMapping("/find")
    public ResponseEntity<?> find(@RequestBody Map<String, Object> body) {
        String recognized = String.valueOf(body.get("recognizedText"));
        return repo.findFirstByRecognizedTextIgnoreCase(recognized)
                .map(vc -> ResponseEntity.ok(Map.of("correctedText", vc.getCorrectedText())))
                .orElse(ResponseEntity.ok(Map.of()));
    }

    @GetMapping
    public ResponseEntity<?> list() {
        List<VoiceCorrection> list = repo.findAll();
        return ResponseEntity.ok(list);
    }

    @PostMapping("/delete")
    public ResponseEntity<?> delete(@RequestBody Map<String, Object> body) {
        int id = ((Number) body.get("id")).intValue();
        repo.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "OK"));
    }
}
