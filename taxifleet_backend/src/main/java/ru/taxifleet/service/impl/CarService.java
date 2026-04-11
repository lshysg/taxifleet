package ru.taxifleet.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.taxifleet.entity.Car;
import ru.taxifleet.enums.CarStatus;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.exception.ResourceNotFoundException;
import ru.taxifleet.repository.CarRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CarService {

    private final CarRepository carRepository;

    @Transactional(readOnly = true)
    public List<Car> getAllCars() {
        return carRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Car getCarById(Long id) {
        return carRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Автомобиль с ID " + id + " не найден"));
    }

    @Transactional(readOnly = true)
    public List<Car> getAvailableCars() {
        return carRepository.findByStatus(CarStatus.AVAILABLE);
    }

    @Transactional
    public Car createCar(Car car) {
        if (carRepository.findByLicensePlate(car.getLicensePlate()).isPresent()) {
            throw new BusinessException(
                    "Автомобиль с номером " + car.getLicensePlate() + " уже существует");
        }
        car.setStatus(CarStatus.AVAILABLE);
        return carRepository.save(car);
    }

    @Transactional
    public Car updateCar(Long id, Car updated) {
        Car existing = getCarById(id);
        existing.setBrand(updated.getBrand());
        existing.setModel(updated.getModel());
        existing.setYear(updated.getYear());
        existing.setMileageKm(updated.getMileageKm());
        return carRepository.save(existing);
    }

    @Transactional
    public void deleteCar(Long id) {
        Car car = getCarById(id);
        if (car.getStatus() == CarStatus.ON_TRIP) {
            throw new BusinessException("Нельзя удалить автомобиль в рейсе");
        }
        carRepository.delete(car);
    }
}
