
package com.spareparts.inventory.repository;

import com.spareparts.inventory.entity.Product;
import com.spareparts.inventory.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByWholesaler(User wholesaler);
    Optional<Product> findByPartNumber(String partNumber);
    List<Product> findByNameContainingIgnoreCaseOrPartNumberContainingIgnoreCase(String name, String partNumber);
    List<Product> findByCategory_Id(Long categoryId);
}
