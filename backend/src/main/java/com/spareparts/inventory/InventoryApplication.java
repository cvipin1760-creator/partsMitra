
package com.spareparts.inventory;

import com.spareparts.inventory.entity.Role;
import com.spareparts.inventory.entity.RoleName;
import com.spareparts.inventory.entity.User;
import com.spareparts.inventory.repository.RoleRepository;
import com.spareparts.inventory.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class InventoryApplication {
    public static void main(String[] args) {
        SpringApplication.run(InventoryApplication.class, args);
    }

    @Bean
    CommandLineRunner init(RoleRepository roleRepository, UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            // Check and create roles if they don't exist
            for (RoleName roleName : RoleName.values()) {
                if (roleRepository.findByName(roleName).isEmpty()) {
                    roleRepository.save(new Role(null, roleName));
                }
            }

            // Create test users if they don't exist
            String defaultPassword = passwordEncoder.encode("password123");

            if (userRepository.findByEmail("supermanager@example.com").isEmpty()) {
                Role superManagerRole = roleRepository.findByName(RoleName.ROLE_SUPER_MANAGER).orElseThrow();
                User superManager = new User(null, "Super Manager", "supermanager@example.com", defaultPassword, "9999999999", "Super Manager HQ", superManagerRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(superManager);
            } else {
                userRepository.findByEmail("supermanager@example.com").ifPresent(u -> {
                    Role superManagerRole = roleRepository.findByName(RoleName.ROLE_SUPER_MANAGER).orElseThrow();
                    u.setRole(superManagerRole);
                    u.setStatus(User.UserStatus.ACTIVE);
                    u.setPassword(defaultPassword); // Reset to password123 for troubleshooting
                    userRepository.save(u);
                });
            }

            if (userRepository.findByEmail("super.manager@example.com").isEmpty()) {
                Role superManagerRole = roleRepository.findByName(RoleName.ROLE_SUPER_MANAGER).orElseThrow();
                User superManager = new User(null, "Super Manager Dot", "super.manager@example.com", defaultPassword, "9999999998", "Super Manager HQ", superManagerRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(superManager);
            } else {
                // Ensure role is set for existing user
                userRepository.findByEmail("super.manager@example.com").ifPresent(u -> {
                    if (u.getRole() == null) {
                        Role superManagerRole = roleRepository.findByName(RoleName.ROLE_SUPER_MANAGER).orElseThrow();
                        u.setRole(superManagerRole);
                        u.setStatus(User.UserStatus.ACTIVE);
                        userRepository.save(u);
                    }
                });
            }

            if (userRepository.findByEmail("admin@example.com").isEmpty()) {
                Role adminRole = roleRepository.findByName(RoleName.ROLE_ADMIN).orElseThrow();
                User admin = new User(null, "System Admin", "admin@example.com", defaultPassword, "1234567890", "Admin Address", adminRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(admin);
            } else {
                userRepository.findByEmail("admin@example.com").ifPresent(u -> {
                    u.setPassword(defaultPassword);
                    userRepository.save(u);
                });
            }

            if (userRepository.findByEmail("wholesaler@example.com").isEmpty()) {
                Role wholesalerRole = roleRepository.findByName(RoleName.ROLE_WHOLESALER).orElseThrow();
                User wholesaler = new User(null, "Best Wholesaler", "wholesaler@example.com", defaultPassword, "1234567890", "Wholesaler Address", wholesalerRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(wholesaler);
            }

            if (userRepository.findByEmail("retailer@example.com").isEmpty()) {
                Role retailerRole = roleRepository.findByName(RoleName.ROLE_RETAILER).orElseThrow();
                User retailer = new User(null, "City Retailer", "retailer@example.com", defaultPassword, "1234567890", "Retailer Address", retailerRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(retailer);
            }

            if (userRepository.findByEmail("mechanic@example.com").isEmpty()) {
                Role mechanicRole = roleRepository.findByName(RoleName.ROLE_MECHANIC).orElseThrow();
                User mechanic = new User(null, "Expert Mechanic", "mechanic@example.com", defaultPassword, "1234567890", "Mechanic Address", mechanicRole, User.UserStatus.ACTIVE, null, null);
                userRepository.save(mechanic);
            }
        };
    }
}
