package com.spareshub.repo;

import com.spareshub.entity.OrderRequest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRequestRepo extends JpaRepository<OrderRequest, Integer> {
}
