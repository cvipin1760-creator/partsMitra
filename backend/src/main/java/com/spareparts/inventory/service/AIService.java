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
    private String apiKey;

    @Autowired
    private ProductRepository productRepository;

    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=";

    private final RestTemplate restTemplate = new RestTemplate();

    public String askAI(String prompt) {
        if (apiKey == null || apiKey.isEmpty()) {
            return "AI integration is not configured. Please add an API key.";
        }

        try {
            // Get some context about current products to make AI smarter
            List<Product> someProducts = productRepository.findAll();
            String productContext = someProducts.stream()
                    .limit(20) // Limit context to first 20 products to save tokens
                    .map(p -> p.getName() + " (Part: " + p.getPartNumber() + ")")
                    .collect(Collectors.joining(", "));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> requestBody = new HashMap<>();
            Map<String, Object> content = new HashMap<>();
            Map<String, Object> part = new HashMap<>();
            
            String systemPrompt = "You are an AI assistant for Spares Hub, an auto spare parts inventory system. " +
                    "We have parts like: " + productContext + ". " +
                    "Help users with part identification, maintenance advice, or finding items. " +
                    "Be professional, concise, and helpful. If asked about parts we don't have, give general advice. " +
                    "User's question: " + prompt;

            part.put("text", systemPrompt);
            content.put("parts", Collections.singletonList(part));
            requestBody.put("contents", Collections.singletonList(content));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            Map<String, Object> response = restTemplate.postForObject(GEMINI_API_URL + apiKey, entity, Map.class);

            if (response != null && response.containsKey("candidates")) {
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
                if (!candidates.isEmpty()) {
                    Map<String, Object> candidate = candidates.get(0);
                    Map<String, Object> contentRes = (Map<String, Object>) candidate.get("content");
                    if (contentRes != null && contentRes.containsKey("parts")) {
                        List<Map<String, Object>> partsRes = (List<Map<String, Object>>) contentRes.get("parts");
                        if (!partsRes.isEmpty()) {
                            return (String) partsRes.get(0).get("text");
                        }
                    }
                }
            }
            return "I'm sorry, I couldn't process your request.";
        } catch (Exception e) {
            return "AI service error: " + e.getMessage();
        }
    }
}
