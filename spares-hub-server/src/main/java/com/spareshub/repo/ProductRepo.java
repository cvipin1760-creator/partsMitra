package com.spareshub.repo;

import com.spareshub.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductRepo extends JpaRepository<Product, Integer> {
    List<Product> findByNameContainingIgnoreCaseOrPartNumberContainingIgnoreCase(String name, String partNumber);
}
