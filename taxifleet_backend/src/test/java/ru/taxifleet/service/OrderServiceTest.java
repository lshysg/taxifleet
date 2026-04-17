package ru.taxifleet.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import ru.taxifleet.entity.*;
import ru.taxifleet.enums.CarStatus;
import ru.taxifleet.enums.DriverStatus;
import ru.taxifleet.enums.OrderStatus;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.exception.ResourceNotFoundException;
import ru.taxifleet.repository.AssignmentRepository;
import ru.taxifleet.repository.DriverRepository;
import ru.taxifleet.repository.OrderRepository;
import ru.taxifleet.service.impl.OrderService;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Тесты OrderService")
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private DriverRepository driverRepository;
    @Mock private AssignmentRepository assignmentRepository;
    @InjectMocks private OrderService orderService;

    private Order testOrder;
    private Driver testDriver;
    private Car testCar;

    @BeforeEach
    void setUp() {
        testCar = new Car();
        testCar.setId(1L);
        testCar.setLicensePlate("А123БВ77");
        testCar.setBrand("Toyota");
        testCar.setModel("Camry");
        testCar.setYear(2020);
        testCar.setStatus(CarStatus.AVAILABLE);

        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setFullName("Иванов Иван Иванович");
        testDriver.setStatus(DriverStatus.FREE);
        testDriver.setCar(testCar);

        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setAddressFrom("ул. Ленина, 1");
        testOrder.setAddressTo("ул. Пушкина, 15");
        testOrder.setClientName("Смирнов А.В.");
        testOrder.setClientPhone("+79165678901");
        testOrder.setStatus(OrderStatus.NEW);
    }

    @Test
    @DisplayName("createOrder — создаёт заказ со статусом NEW")
    void createOrder_ValidOrder_SetsStatusNew() {
        when(orderRepository.save(testOrder)).thenReturn(testOrder);
        Order result = orderService.createOrder(testOrder);
        assertEquals(OrderStatus.NEW, result.getStatus());
        verify(orderRepository).save(testOrder);
    }

    @Test
    @DisplayName("getOrderById — выбрасывает исключение если заказ не найден")
    void getOrderById_NotFound_ThrowsException() {
        when(orderRepository.findById(99L)).thenReturn(Optional.empty());
        assertThrows(ResourceNotFoundException.class,
                () -> orderService.getOrderById(99L));
    }

    @Test
    @DisplayName("assignDriver — успешное назначение водителя")
    void assignDriver_ValidInput_CreatesAssignment() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));
        when(orderRepository.save(any())).thenReturn(testOrder);
        when(driverRepository.save(any())).thenReturn(testDriver);

        Order result = orderService.assignDriver(1L, 1L);

        assertEquals(OrderStatus.ASSIGNED, result.getStatus());
        assertEquals(DriverStatus.BUSY, testDriver.getStatus());
        assertEquals(CarStatus.ON_TRIP, testCar.getStatus());
        verify(assignmentRepository).save(any(Assignment.class));
    }

    @Test
    @DisplayName("assignDriver — выбрасывает исключение если заказ не NEW")
    void assignDriver_OrderNotNew_ThrowsException() {
        testOrder.setStatus(OrderStatus.ASSIGNED);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));

        assertThrows(BusinessException.class,
                () -> orderService.assignDriver(1L, 1L));
    }

    @Test
    @DisplayName("assignDriver — выбрасывает исключение если водитель занят")
    void assignDriver_DriverBusy_ThrowsException() {
        testDriver.setStatus(DriverStatus.BUSY);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));

        assertThrows(BusinessException.class,
                () -> orderService.assignDriver(1L, 1L));
    }

    @Test
    @DisplayName("assignDriver — выбрасывает исключение если у водителя нет машины")
    void assignDriver_DriverNoCar_ThrowsException() {
        testDriver.setCar(null);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));

        assertThrows(BusinessException.class,
                () -> orderService.assignDriver(1L, 1L));
    }

    @Test
    @DisplayName("isNew — возвращает true для нового заказа")
    void isNew_NewOrder_ReturnsTrue() {
        assertTrue(testOrder.isNew());
    }

    @Test
    @DisplayName("cancel — меняет статус заказа на CANCELLED")
    void cancel_ChangesStatusToCancelled() {
        testOrder.cancel();
        assertEquals(OrderStatus.CANCELLED, testOrder.getStatus());
    }
}
