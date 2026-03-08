
package com.spareparts.inventory.controller;

import com.spareparts.inventory.dto.OrderDto;
import com.spareparts.inventory.dto.OrderRequest;
import com.spareparts.inventory.entity.Order;
import com.spareparts.inventory.security.UserDetailsImpl;
import com.spareparts.inventory.service.OrderService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    @Autowired
    private OrderService orderService;

    @PostMapping
    @PreAuthorize("hasRole('RETAILER') or hasRole('MECHANIC') or hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<OrderDto> createOrder(@Valid @RequestBody OrderRequest orderRequest, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return ResponseEntity.ok(orderService.createOrder(orderRequest, userDetails.getId()));
    }

    @GetMapping("/my-orders")
    public ResponseEntity<List<OrderDto>> getMyOrders(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return ResponseEntity.ok(orderService.getCustomerOrders(userDetails.getId()));
    }

    @GetMapping("/seller-orders")
    @PreAuthorize("hasRole('WHOLESALER') or hasRole('RETAILER') or hasRole('ADMIN') or hasRole('SUPER_MANAGER')")
    public ResponseEntity<List<OrderDto>> getSellerOrders(Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return ResponseEntity.ok(orderService.getSellerOrders(userDetails.getId()));
    }

    @PutMapping("/{orderId}/status")
    @PreAuthorize("hasRole('WHOLESALER') or hasRole('RETAILER') or hasRole('ADMIN') or hasRole('SUPER_MANAGER') or hasRole('STAFF')")
    public ResponseEntity<OrderDto> updateOrderStatus(@PathVariable Long orderId, @RequestParam Order.OrderStatus status, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return ResponseEntity.ok(orderService.updateOrderStatus(orderId, status, userDetails.getId()));
    }

    @PutMapping("/{orderId}/cancel")
    @PreAuthorize("hasRole('RETAILER') or hasRole('MECHANIC')")
    public ResponseEntity<OrderDto> cancelOrder(@PathVariable Long orderId, Authentication authentication) {
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return ResponseEntity.ok(orderService.cancelOrder(orderId, userDetails.getId()));
    }
}
