package com.spareshub.controller;

import com.spareshub.entity.OrderRequest;
import com.spareshub.repo.OrderRequestRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/order-requests")
public class OrderRequestController {
    private final OrderRequestRepo repo;
    public OrderRequestController(OrderRequestRepo repo) { this.repo = repo; }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        OrderRequest r = new OrderRequest();
        int customerId = ((Number) body.get("customerId")).intValue();
        r.setCustomerId(customerId);
        r.setCustomerName("Customer " + customerId);
        r.setText(String.valueOf(body.get("text")));
        r.setPhotoPath(String.valueOf(body.get("photoPath")));
        r.setStatus("NEW");
        r.setCreatedAt(new Date().toInstant().toString());
        repo.save(r);
        return ResponseEntity.ok(Map.of("id", r.getId()));
    }

    @GetMapping
    public ResponseEntity<?> list() {
        return ResponseEntity.ok(repo.findAll());
    }

    @PostMapping("/{id}/status")
    public ResponseEntity<?> status(@PathVariable int id, @RequestBody Map<String, Object> body) {
        String status = String.valueOf(body.get("status"));
        return repo.findById(id).map(r -> {
            r.setStatus(status);
            repo.save(r);
            return ResponseEntity.ok(Map.of("status", "OK"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/assign")
    public ResponseEntity<?> assign(@PathVariable int id, @RequestBody Map<String, Object> body) {
        int staffId = ((Number) body.get("staffId")).intValue();
        return repo.findById(id).map(r -> {
            r.setAssignedStaffId(staffId);
            r.setAssignedStaffName("Staff " + staffId);
            r.setStatus("ASSIGNED");
            repo.save(r);
            return ResponseEntity.ok(Map.of("status", "OK"));
        }).orElse(ResponseEntity.notFound().build());
    }
}
