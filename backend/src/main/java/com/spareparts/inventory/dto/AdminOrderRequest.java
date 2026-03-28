package com.spareparts.inventory.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class AdminOrderRequest {
    @NotNull
    private Long customerId;
    
    @NotNull
    private Long sellerId;
    
    @NotEmpty
    private List<OrderItemDto> items;

    private BigDecimal discountAmount;
}
