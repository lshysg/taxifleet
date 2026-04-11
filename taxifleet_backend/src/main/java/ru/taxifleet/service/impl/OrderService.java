package ru.taxifleet.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.taxifleet.entity.Assignment;
import ru.taxifleet.entity.Driver;
import ru.taxifleet.entity.Order;
import ru.taxifleet.enums.CarStatus;
import ru.taxifleet.enums.DriverStatus;
import ru.taxifleet.enums.OrderStatus;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.exception.ResourceNotFoundException;
import ru.taxifleet.repository.AssignmentRepository;
import ru.taxifleet.repository.DriverRepository;
import ru.taxifleet.repository.OrderRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final DriverRepository driverRepository;
    private final AssignmentRepository assignmentRepository;

    @Transactional(readOnly = true)
    public List<Order> getAllOrders() {
        return orderRepository.findAllByOrderByCreatedAtDesc();
    }

    @Transactional(readOnly = true)
    public Order getOrderById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Заказ с ID " + id + " не найден"));
    }

    @Transactional(readOnly = true)
    public List<Order> getOrdersByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }

    @Transactional
    public Order createOrder(Order order) {
        order.setStatus(OrderStatus.NEW);
        return orderRepository.save(order);
    }

    @Transactional
    public Order assignDriver(Long orderId, Long driverId) {
        // Найти заказ
        Order order = getOrderById(orderId);
        if (!order.isNew()) {
            throw new BusinessException(
                    "Назначить водителя можно только на заказ со статусом NEW. " +
                    "Текущий статус: " + order.getStatus());
        }

        // Найти водителя
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Водитель с ID " + driverId + " не найден"));
        if (!driver.isFree()) {
            throw new BusinessException(
                    "Водитель недоступен. Текущий статус: " + driver.getStatus());
        }

        // Проверить наличие автомобиля у водителя
        if (driver.getCar() == null) {
            throw new BusinessException(
                    "У водителя нет закреплённого автомобиля");
        }
        if (!driver.getCar().isAvailable()) {
            throw new BusinessException(
                    "Автомобиль водителя недоступен. Статус: " + driver.getCar().getStatus());
        }

        // Создать назначение
        Assignment assignment = new Assignment();
        assignment.setOrder(order);
        assignment.setDriver(driver);
        assignment.setCar(driver.getCar());
        assignmentRepository.save(assignment);

        // Обновить статусы
        order.setStatus(OrderStatus.ASSIGNED);
        driver.occupy();
        driver.getCar().setStatus(CarStatus.ON_TRIP);

        driverRepository.save(driver);
        return orderRepository.save(order);
    }

    @Transactional
    public Order changeStatus(Long orderId, OrderStatus newStatus) {
        Order order = getOrderById(orderId);

        // При завершении заказа — освободить водителя
        if (newStatus == OrderStatus.DONE || newStatus == OrderStatus.CANCELLED) {
            assignmentRepository.findByOrderId(orderId).ifPresent(assignment -> {
                assignment.complete();
                assignmentRepository.save(assignment);

                Driver driver = assignment.getDriver();
                driver.release();
                driver.getCar().setStatus(CarStatus.AVAILABLE);
                driverRepository.save(driver);
            });
        }

        order.setStatus(newStatus);
        return orderRepository.save(order);
    }
}
