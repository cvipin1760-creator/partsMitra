
package com.spareparts.inventory.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class SignupRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    @NotBlank
    @Size(max = 100)
    @Email
    private String email;

    @NotBlank
    @Size(min = 6, max = 40)
    private String password;

    private String phone;
    
    private String countryCode; // e.g., +91

    private String address;
    private String role; // admin, wholesaler, retailer, mechanic
    
    private String otp;
    
    private String firebaseToken;
}
