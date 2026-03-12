package com.spareparts.inventory.service;

import com.spareparts.inventory.entity.Product;
import com.spareparts.inventory.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AIService {

    @Value("${app.gemini.api.key:}")
    private String geminiApiKey;
    @Value("${app.openai.api.key:}")
    private String openaiApiKey;
    @Value("${app.openai.model:gpt-4o-mini}")
    private String openaiModel;

    @Autowired
    private ProductRepository productRepository;

    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=";
    private static final String OPENAI_CHAT_URL = "https://api.openai.com/v1/chat/completions";

    private final RestTemplate restTemplate = new RestTemplate();

    public String askAI(String prompt, String provider) {
        try {
            String productContext = productRepository.findAll().stream()
                    .limit(20)
                    .map(p -> p.getName() + " (Part: " + p.getPartNumber() + ")")
                    .collect(Collectors.joining(", "));

            String systemPrompt = "You are an AI assistant for Spares Hub, an auto spare parts inventory system. " +
                    "We have parts like: " + productContext + ". " +
                    "Help users with part identification, maintenance advice, or finding items. " +
                    "Be professional, concise, and helpful.";

            boolean useOpenAI = "openai".equalsIgnoreCase(provider) || (openaiApiKey != null && !openaiApiKey.isEmpty());
            if (useOpenAI) {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                headers.setBearerAuth(openaiApiKey);

                Map<String, Object> req = new HashMap<>();
                req.put("model", openaiModel);
                List<Map<String, Object>> messages = List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", prompt)
                );
                req.put("messages", messages);

                HttpEntity<Map<String, Object>> entity = new HttpEntity<>(req, headers);
                Map<String, Object> response = restTemplate.postForObject(OPENAI_CHAT_URL, entity, Map.class);
                if (response != null && response.containsKey("choices")) {
                    List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
                    if (!choices.isEmpty()) {
                        Map<String, Object> first = choices.get(0);
                        Map<String, Object> msg = (Map<String, Object>) first.get("message");
                        Object content = msg != null ? msg.get("content") : null;
                        if (content != null) return content.toString();
                    }
                }
                return "I couldn't generate a response.";
            }

            if (geminiApiKey != null && !geminiApiKey.isEmpty()) {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);

                Map<String, Object> requestBody = new HashMap<>();
                Map<String, Object> content = new HashMap<>();
                Map<String, Object> part = new HashMap<>();
                String fullPrompt = systemPrompt + " User's question: " + prompt;
                part.put("text", fullPrompt);
                content.put("parts", Collections.singletonList(part));
                requestBody.put("contents", Collections.singletonList(content));

                HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
                Map<String, Object> response = restTemplate.postForObject(GEMINI_API_URL + geminiApiKey, entity, Map.class);
                if (response != null && response.containsKey("candidates")) {
                    List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
                    if (!candidates.isEmpty()) {
                        Map<String, Object> candidate = candidates.get(0);
                        Map<String, Object> contentRes = (Map<String, Object>) candidate.get("content");
                        if (contentRes != null && contentRes.containsKey("parts")) {
                            List<Map<String, Object>> partsRes = (List<Map<String, Object>>) contentRes.get("parts");
                            if (!partsRes.isEmpty()) {
                                Object t = partsRes.get(0).get("text");
                                if (t != null) return t.toString();
                            }
                        }
                    }
                }
                Object error = response != null ? response.get("error") : null;
                if (error != null) return "AI service error: " + error.toString();
                return "I couldn't generate a response.";
            }
            return "AI integration is not configured. Please set OPENAI_API_KEY or GEMINI_API_KEY.";
        } catch (Exception e) {
            return "AI service error: " + e.getMessage();
        }
    }
}
