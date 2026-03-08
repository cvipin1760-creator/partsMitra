
package com.spareparts.inventory.repository;

import com.spareparts.inventory.entity.Product;
import com.spareparts.inventory.entity.RetailerInventory;
import com.spareparts.inventory.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RetailerInventoryRepository extends JpaRepository<RetailerInventory, Long> {
    List<RetailerInventory> findByRetailer(User retailer);
    Optional<RetailerInventory> findByRetailerAndProduct(User retailer, Product product);
}
