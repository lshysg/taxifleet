# 06. Реализация

> Реализация серверной части информационной системы TaxiFleet Admin: структура проекта, ключевые листинги, тестирование, рефакторинг.

---

## 6.1 Структура проекта (серверная часть)

```
taxifleet_backend/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/com/taxifleet/
    │   │   ├── TaxifleetApplication.java
    │   │   ├── config/
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── CorsConfig.java
    │   │   │   └── SwaggerConfig.java
    │   │   ├── controller/                  # [C] Control
    │   │   │   ├── AuthController.java
    │   │   │   ├── DriverController.java
    │   │   │   ├── OrderController.java
    │   │   │   ├── CarController.java
    │   │   │   └── AssignmentController.java
    │   │   ├── service/                     # [M] Mediator
    │   │   │   ├── AuthService.java
    │   │   │   ├── DriverService.java
    │   │   │   ├── OrderService.java
    │   │   │   ├── CarService.java
    │   │   │   └── AssignmentService.java
    │   │   ├── repository/                  # [F] Foundation
    │   │   │   ├── AdminRepository.java
    │   │   │   ├── DriverRepository.java
    │   │   │   ├── OrderRepository.java
    │   │   │   ├── CarRepository.java
    │   │   │   └── AssignmentRepository.java
    │   │   ├── model/                       # [E] Entity
    │   │   │   ├── Admin.java
    │   │   │   ├── Driver.java
    │   │   │   ├── Car.java
    │   │   │   ├── Order.java
    │   │   │   ├── Assignment.java
    │   │   │   ├── DriverStatus.java
    │   │   │   ├── CarStatus.java
    │   │   │   └── OrderStatus.java
    │   │   ├── dto/
    │   │   │   ├── AuthRequest.java
    │   │   │   ├── AuthResponse.java
    │   │   │   └── AssignmentRequest.java
    │   │   └── security/
    │   │       ├── JwtUtil.java
    │   │       └── JwtAuthFilter.java
    │   └── resources/
    │       └── application.yml
    └── test/java/com/taxifleet/
        ├── service/
        │   ├── DriverServiceTest.java
        │   └── OrderServiceTest.java
        └── controller/
            └── AuthControllerTest.java
```

### Соответствие слоям PCMEF

| Слой PCMEF | Пакет | Описание |
|------------|-------|----------|
| **P** (Presentation) | `taxifleet_app/lib/` | Flutter-приложение (отдельный модуль) |
| **C** (Control) | `com.taxifleet.controller` | REST-контроллеры, принимают HTTP-запросы |
| **M** (Mediator) | `com.taxifleet.service` | Бизнес-логика, транзакции |
| **E** (Entity) | `com.taxifleet.model`, `com.taxifleet.dto` | JPA-сущности, DTO |
| **F** (Foundation) | `com.taxifleet.repository` | Spring Data JPA репозитории |

---

## 6.2 Листинг: Driver.java

```java
package com.taxifleet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "drivers")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Driver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    @Column(name = "license_number", nullable = false, unique = true, length = 20)
    private String licenseNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private DriverStatus status = DriverStatus.FREE;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public boolean isFree() {
        return this.status == DriverStatus.FREE;
    }

    public void markBusy() {
        this.status = DriverStatus.BUSY;
    }

    public void markFree() {
        this.status = DriverStatus.FREE;
    }

    // --- Getters and Setters ---

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getLicenseNumber() { return licenseNumber; }
    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }

    public DriverStatus getStatus() { return status; }
    public void setStatus(DriverStatus status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}
```

---

## 6.3 Листинг: OrderService.assignDriver()

```java
package com.taxifleet.service;

import com.taxifleet.model.*;
import com.taxifleet.repository.*;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AssignmentService {

    private final AssignmentRepository assignmentRepository;
    private final OrderRepository orderRepository;
    private final DriverRepository driverRepository;
    private final CarRepository carRepository;

    public AssignmentService(AssignmentRepository assignmentRepository,
                             OrderRepository orderRepository,
                             DriverRepository driverRepository,
                             CarRepository carRepository) {
        this.assignmentRepository = assignmentRepository;
        this.orderRepository = orderRepository;
        this.driverRepository = driverRepository;
        this.carRepository = carRepository;
    }

    @Transactional
    public Assignment assignDriver(Long orderId, Long driverId, Long carId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "Заказ не найден: " + orderId));

        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "Водитель не найден: " + driverId));

        Car car = carRepository.findById(carId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "Автомобиль не найден: " + carId));

        if (order.getStatus() != OrderStatus.NEW) {
            throw new IllegalStateException(
                    "Заказ не в статусе NEW: " + order.getStatus());
        }

        if (!driver.isFree()) {
            throw new IllegalStateException(
                    "Водитель не свободен: " + driver.getStatus());
        }

        if (car.getStatus() != CarStatus.AVAILABLE) {
            throw new IllegalStateException(
                    "Автомобиль недоступен: " + car.getStatus());
        }

        Assignment assignment = new Assignment();
        assignment.setOrder(order);
        assignment.setDriver(driver);
        assignment.setCar(car);
        assignmentRepository.save(assignment);

        order.setStatus(OrderStatus.ASSIGNED);
        orderRepository.save(order);

        driver.markBusy();
        driverRepository.save(driver);

        car.setStatus(CarStatus.ON_TRIP);
        carRepository.save(car);

        return assignment;
    }
}
```

---

## 6.4 Листинг: DriverServiceTest.java

```java
package com.taxifleet.service;

import com.taxifleet.model.Driver;
import com.taxifleet.model.DriverStatus;
import com.taxifleet.repository.DriverRepository;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DriverServiceTest {

    @Mock
    private DriverRepository driverRepository;

    @InjectMocks
    private DriverService driverService;

    private Driver testDriver;

    @BeforeEach
    void setUp() {
        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setName("Петров Пётр");
        testDriver.setPhone("+7-900-111-2233");
        testDriver.setLicenseNumber("77 01 123456");
        testDriver.setStatus(DriverStatus.FREE);
    }

    @Test
    void getAllDrivers_returnsDriverList() {
        when(driverRepository.findAll()).thenReturn(Arrays.asList(testDriver));

        List<Driver> result = driverService.getAllDrivers();

        assertEquals(1, result.size());
        assertEquals("Петров Пётр", result.get(0).getName());
        verify(driverRepository).findAll();
    }

    @Test
    void getDriverById_existingId_returnsDriver() {
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));

        Driver result = driverService.getDriverById(1L);

        assertNotNull(result);
        assertEquals(1L, result.getId());
    }

    @Test
    void getDriverById_nonExistingId_throwsException() {
        when(driverRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class,
                () -> driverService.getDriverById(99L));
    }

    @Test
    void createDriver_validDriver_returnsSaved() {
        when(driverRepository.save(testDriver)).thenReturn(testDriver);

        Driver result = driverService.createDriver(testDriver);

        assertNotNull(result);
        assertEquals("Петров Пётр", result.getName());
        verify(driverRepository).save(testDriver);
    }

    @Test
    void deleteDriver_freeDriver_deletesSuccessfully() {
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));

        assertDoesNotThrow(() -> driverService.deleteDriver(1L));
        verify(driverRepository).delete(testDriver);
    }

    @Test
    void deleteDriver_busyDriver_throwsException() {
        testDriver.setStatus(DriverStatus.BUSY);
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));

        assertThrows(IllegalStateException.class,
                () -> driverService.deleteDriver(1L));
        verify(driverRepository, never()).delete(any());
    }

    @Test
    void getFreeDrivers_returnsFreeOnly() {
        when(driverRepository.findByStatus(DriverStatus.FREE))
                .thenReturn(Arrays.asList(testDriver));

        List<Driver> result = driverService.getFreeDrivers();

        assertEquals(1, result.size());
        assertTrue(result.get(0).isFree());
    }
}
```

---

## 6.5 Листинг: OrderServiceTest.java

```java
package com.taxifleet.service;

import com.taxifleet.model.*;
import com.taxifleet.repository.*;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderService orderService;

    private Order testOrder;

    @BeforeEach
    void setUp() {
        testOrder = new Order();
        testOrder.setId(1L);
        testOrder.setClientName("Алексеев Максим");
        testOrder.setClientPhone("+7-911-100-2000");
        testOrder.setAddressFrom("ул. Ленина, 10");
        testOrder.setAddressTo("пр. Мира, 25");
        testOrder.setStatus(OrderStatus.NEW);
    }

    @Test
    void createOrder_setsStatusNew() {
        when(orderRepository.save(any(Order.class))).thenReturn(testOrder);

        Order result = orderService.createOrder(testOrder);

        assertEquals(OrderStatus.NEW, result.getStatus());
        verify(orderRepository).save(testOrder);
    }

    @Test
    void getOrderById_existingId_returnsOrder() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));

        Order result = orderService.getOrderById(1L);

        assertNotNull(result);
        assertEquals("Алексеев Максим", result.getClientName());
    }

    @Test
    void getOrderById_nonExistingId_throwsException() {
        when(orderRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class,
                () -> orderService.getOrderById(99L));
    }

    @Test
    void cancelOrder_newOrder_cancelsSuccessfully() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(orderRepository.save(any())).thenReturn(testOrder);

        orderService.cancelOrder(1L);

        assertEquals(OrderStatus.CANCELLED, testOrder.getStatus());
        verify(orderRepository).save(testOrder);
    }

    @Test
    void cancelOrder_doneOrder_throwsException() {
        testOrder.setStatus(OrderStatus.DONE);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(testOrder));

        assertThrows(IllegalStateException.class,
                () -> orderService.cancelOrder(1L));
    }
}
```

---

## 6.6 Результаты тестирования

Полная таблица тестов: [tests.md](tests.md)

### Сводка

| Метрика | Значение |
|---------|----------|
| Всего тестов | 17 |
| Успешных (PASSED) | 17 |
| Неуспешных (FAILED) | 0 |
| Время выполнения | ~2.3 сек |
| Покрытие бизнес-логики | ~85% |

---

## 6.7 Рефакторинг

### Data Mapper через @JsonIgnoreProperties

**Проблема:** При сериализации JPA-сущностей Hibernate прокси-объекты вызывали `LazyInitializationException` или циклическую сериализацию.

**Решение:** Добавлена аннотация `@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})` на Entity-классы.

```java
@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Driver { ... }
```

### EAGER Loading для Assignment

**Проблема:** При загрузке Assignment связанные объекты (Order, Driver, Car) загружались лениво, что приводило к ошибкам при сериализации в JSON.

**Решение:** Для связей в Assignment установлен `FetchType.EAGER`:

```java
@ManyToOne(fetch = FetchType.EAGER)
@JoinColumn(name = "driver_id", nullable = false)
private Driver driver;
```

---

## 6.8 Отчёт статического анализа

| Категория | Количество | Серьёзность | Статус |
|-----------|-----------|-------------|--------|
| Неиспользуемые импорты | 3 | Низкая | Исправлено |
| Missing @Override | 2 | Информационная | Исправлено |
| Потенциальный NPE | 1 | Средняя | Исправлено (Optional) |
| Дублирование кода в контроллерах | 2 | Низкая | Допустимо |
| Magic numbers | 0 | — | — |
| SQL injection | 0 | — | — |
| Hardcoded credentials | 0 | — | — |

---

## Навигация

| Предыдущий | Следующий |
|------------|-----------|
| [05. Проектирование](../05-design/README.md) | [07. Пользовательский интерфейс](../07-ui/README.md) |
