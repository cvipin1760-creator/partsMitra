package com.spareshub.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "voice_corrections")
public class VoiceCorrection {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @Column(name = "recognized_text")
    private String recognizedText;
    @Column(name = "corrected_text")
    private String correctedText;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getRecognizedText() { return recognizedText; }
    public void setRecognizedText(String recognizedText) { this.recognizedText = recognizedText; }
    public String getCorrectedText() { return correctedText; }
    public void setCorrectedText(String correctedText) { this.correctedText = correctedText; }
}
