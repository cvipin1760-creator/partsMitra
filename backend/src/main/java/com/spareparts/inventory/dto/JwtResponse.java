
package com.spareparts.inventory.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class JwtResponse {
    private String token;
    private String type = "Bearer";
    private Long id;
    private String username;
    private String email;
    private List<String> roles;
    private String address;
    private String status;
    private Double latitude;
    private Double longitude;

    public JwtResponse(String accessToken, Long id, String username, String email, List<String> roles) {
        this.token = accessToken;
        this.id = id;
        this.username = username;
        this.email = email;
        this.roles = roles;
    }

    public JwtResponse(String accessToken, Long id, String username, String email, List<String> roles, String address, String status, Double latitude, Double longitude) {
        this.token = accessToken;
        this.id = id;
        this.username = username;
        this.email = email;
        this.roles = roles;
        this.address = address;
        this.status = status;
        this.latitude = latitude;
        this.longitude = longitude;
    }
}
