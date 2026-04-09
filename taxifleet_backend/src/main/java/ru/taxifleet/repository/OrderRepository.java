package ru.taxifleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.taxifleet.entity.Order;
import ru.taxifleet.enums.OrderStatus;

import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByStatus(OrderStatus status);
    List<Order> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);
    List<Order> findAllByOrderByCreatedAtDesc();
}
