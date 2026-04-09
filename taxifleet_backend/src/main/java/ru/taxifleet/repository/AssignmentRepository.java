package ru.taxifleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.taxifleet.entity.Assignment;

import java.util.List;
import java.util.Optional;

public interface AssignmentRepository extends JpaRepository<Assignment, Long> {
    Optional<Assignment> findByOrderId(Long orderId);
    List<Assignment> findByDriverId(Long driverId);
}
