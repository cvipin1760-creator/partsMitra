package com.spareshub.controller;

import com.spareshub.repo.ProductRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/products")
public class ProductController {
    private final ProductRepo productRepo;
    public ProductController(ProductRepo productRepo) { this.productRepo = productRepo; }

    @GetMapping
    public ResponseEntity<?> all() {
        return ResponseEntity.ok(productRepo.findAll());
    }

    @GetMapping("/search")
    public ResponseEntity<?> search(@RequestParam String query) {
        return ResponseEntity.ok(productRepo.findByNameContainingIgnoreCaseOrPartNumberContainingIgnoreCase(query, query));
    }
}
