package ru.taxifleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.taxifleet.entity.Car;
import ru.taxifleet.enums.CarStatus;

import java.util.List;
import java.util.Optional;

public interface CarRepository extends JpaRepository<Car, Long> {
    List<Car> findByStatus(CarStatus status);
    Optional<Car> findByLicensePlate(String licensePlate);
}
