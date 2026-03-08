package com.spareshub.controller;

import com.spareshub.entity.OrderEntity;
import com.spareshub.entity.OrderItemEntity;
import com.spareshub.repo.OrderRepo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/orders")
public class OrderController {
    private final OrderRepo orderRepo;
    public OrderController(OrderRepo orderRepo) { this.orderRepo = orderRepo; }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> body) {
        int sellerId = ((Number) body.get("sellerId")).intValue();
        int customerId = ((Number) body.get("customerId")).intValue();
        List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
        OrderEntity o = new OrderEntity();
        o.setCustomerId(customerId);
        o.setCustomerName("Customer " + customerId);
        o.setSellerId(sellerId);
        o.setSellerName("Seller " + sellerId);
        o.setCreatedAt(new Date().toInstant().toString());
        o.setStatus("PENDING");
        double total = 0;
        List<OrderItemEntity> itemEntities = new ArrayList<>();
        for (Map<String, Object> it : items) {
            OrderItemEntity item = new OrderItemEntity();
            item.setOrder(o);
            item.setProductId(((Number) it.get("productId")).intValue());
            item.setProductName(String.valueOf(it.get("productName")));
            item.setQuantity(((Number) it.get("quantity")).intValue());
            item.setPrice(Double.parseDouble(String.valueOf(it.get("price"))));
            total += item.getPrice() * item.getQuantity();
            itemEntities.add(item);
        }
        o.setTotalAmount(total);
        o.setItems(itemEntities);
        orderRepo.save(o);
        return ResponseEntity.ok(o);
    }

    @PostMapping("/admin")
    public ResponseEntity<?> createAdmin(@RequestBody Map<String, Object> body) {
        int customerId = ((Number) body.get("customerId")).intValue();
        String customerName = String.valueOf(body.get("customerName"));
        List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
        OrderEntity o = new OrderEntity();
        o.setCustomerId(customerId);
        o.setCustomerName(customerName);
        o.setSellerId(0);
        o.setSellerName("Admin");
        o.setCreatedAt(new Date().toInstant().toString());
        o.setStatus("APPROVED");
        double total = 0;
        List<OrderItemEntity> itemEntities = new ArrayList<>();
        for (Map<String, Object> it : items) {
            OrderItemEntity item = new OrderItemEntity();
            item.setOrder(o);
            item.setProductId(((Number) it.get("productId")).intValue());
            item.setProductName(String.valueOf(it.get("productName")));
            item.setQuantity(((Number) it.get("quantity")).intValue());
            item.setPrice(Double.parseDouble(String.valueOf(it.get("price"))));
            total += item.getPrice() * item.getQuantity();
            itemEntities.add(item);
        }
        o.setTotalAmount(total);
        o.setItems(itemEntities);
        orderRepo.save(o);
        return ResponseEntity.ok(o);
    }

    @GetMapping("/my")
    public ResponseEntity<?> my() {
        return ResponseEntity.ok(orderRepo.findAll());
    }

    @PostMapping("/{id}/status")
    public ResponseEntity<?> status(@PathVariable int id, @RequestBody Map<String, Object> body) {
        String status = String.valueOf(body.get("status"));
        return orderRepo.findById(id).map(o -> {
            o.setStatus(status);
            orderRepo.save(o);
            return ResponseEntity.ok(o);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/items")
    public ResponseEntity<?> items(@PathVariable int id, @RequestBody Map<String, Object> body) {
        return orderRepo.findById(id).map(o -> {
            List<Map<String, Object>> items = (List<Map<String, Object>>) body.get("items");
            o.getItems().clear();
            double total = 0;
            for (Map<String, Object> it : items) {
                OrderItemEntity item = new OrderItemEntity();
                item.setOrder(o);
                item.setProductId(((Number) it.get("productId")).intValue());
                item.setProductName(String.valueOf(it.get("productName")));
                item.setQuantity(((Number) it.get("quantity")).intValue());
                item.setPrice(Double.parseDouble(String.valueOf(it.get("price"))));
                total += item.getPrice() * item.getQuantity();
                o.getItems().add(item);
            }
            o.setTotalAmount(total);
            orderRepo.save(o);
            return ResponseEntity.ok(Map.of("status", "OK"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/sales")
    public ResponseEntity<?> sales(@RequestBody Map<String, Object> body) {
        String type = String.valueOf(body.get("type"));
        double total = orderRepo.findAll().stream().mapToDouble(or -> Optional.ofNullable(or.getTotalAmount()).orElse(0.0)).sum();
        int count = (int) orderRepo.count();
        return ResponseEntity.ok(Map.of("type", type, "totalSales", total, "totalOrders", count));
    }
}
