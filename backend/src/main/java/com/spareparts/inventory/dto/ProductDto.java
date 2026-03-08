
package com.spareparts.inventory.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ProductDto {
    private Long id;
    
    @NotBlank
    private String name;
    
    @NotBlank
    private String partNumber;
    
    @NotNull
    private BigDecimal mrp;
    
    @NotNull
    private BigDecimal sellingPrice;
    
    @NotNull
    private BigDecimal wholesalerPrice;
    
    @NotNull
    private BigDecimal retailerPrice;
    
    @NotNull
    private BigDecimal mechanicPrice;
    
    @NotNull
    private Integer stock;
    
    private String imagePath;
    
    private Long wholesalerId;
}
