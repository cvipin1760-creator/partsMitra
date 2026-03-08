
package com.spareparts.inventory.repository;

import com.spareparts.inventory.entity.Order;
import com.spareparts.inventory.entity.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    @EntityGraph(attributePaths = {"customer", "seller", "items", "items.product"})
    List<Order> findByCustomer(User customer);

    @EntityGraph(attributePaths = {"customer", "seller", "items", "items.product"})
    List<Order> findBySeller(User seller);

    List<Order> findByStatus(Order.OrderStatus status);
}
