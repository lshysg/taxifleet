package ru.taxifleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.taxifleet.entity.Driver;
import ru.taxifleet.enums.DriverStatus;

import java.util.List;
import java.util.Optional;

public interface DriverRepository extends JpaRepository<Driver, Long> {
    List<Driver> findByStatus(DriverStatus status);
    Optional<Driver> findByPhone(String phone);
    boolean existsByLicenseNumber(String licenseNumber);
}
