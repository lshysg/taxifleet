package ru.taxifleet.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.taxifleet.entity.Driver;
import ru.taxifleet.enums.DriverStatus;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.exception.ResourceNotFoundException;
import ru.taxifleet.repository.AssignmentRepository;
import ru.taxifleet.repository.DriverRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DriverService {

    private final DriverRepository driverRepository;
    private final AssignmentRepository assignmentRepository;

    @Transactional(readOnly = true)
    public List<Driver> getAllDrivers() {
        return driverRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Driver getDriverById(Long id) {
        return driverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Водитель с ID " + id + " не найден"));
    }

    @Transactional(readOnly = true)
    public List<Driver> getFreeDrivers() {
        return driverRepository.findByStatus(DriverStatus.FREE);
    }

    @Transactional
    public Driver createDriver(Driver driver) {
        if (driverRepository.existsByLicenseNumber(driver.getLicenseNumber())) {
            throw new BusinessException(
                    "Водитель с номером прав " + driver.getLicenseNumber() + " уже существует");
        }
        driver.setStatus(DriverStatus.FREE);
        return driverRepository.save(driver);
    }

    @Transactional
    public Driver updateDriver(Long id, Driver updated) {
        Driver existing = getDriverById(id);
        existing.setFullName(updated.getFullName());
        existing.setPhone(updated.getPhone());
        existing.setLicenseNumber(updated.getLicenseNumber());
        existing.setHiredAt(updated.getHiredAt());
        if (updated.getCar() != null) {
            existing.setCar(updated.getCar());
        }
        return driverRepository.save(existing);
    }

    @Transactional
    public void deleteDriver(Long id) {
        Driver driver = getDriverById(id);
        boolean hasActiveAssignment = assignmentRepository
                .findByDriverId(id).stream()
                .anyMatch(a -> !a.isCompleted());
        if (hasActiveAssignment) {
            throw new BusinessException(
                    "Нельзя удалить водителя с активным назначением");
        }
        driverRepository.delete(driver);
    }

    @Transactional
    public Driver updateStatus(Long id, DriverStatus status) {
        Driver driver = getDriverById(id);
        driver.setStatus(status);
        return driverRepository.save(driver);
    }
}
