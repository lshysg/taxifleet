# 05. Проектирование

> Детальное проектирование информационной системы TaxiFleet Admin: диаграммы последовательности, диаграмма классов, спецификации методов, REST API.

---

## 5.1 Диаграмма последовательности — UC-01: Войти в систему

```plantuml
@startuml SD-Login

skinparam sequenceArrowThickness 2
skinparam sequenceParticipant underline

actor "Администратор" as User
participant "LoginScreen" as UI
participant "ApiService" as API
participant "AuthController" as Ctrl
participant "AuthService" as Svc
participant "AdminRepository" as Repo
database "PostgreSQL" as DB

User -> UI : Ввод логина и пароля
UI -> API : POST /api/auth/login\n{username, password}
API -> Ctrl : login(AuthRequest)
Ctrl -> Svc : authenticate(username, password)
Svc -> Repo : findByUsername(username)
Repo -> DB : SELECT * FROM admins\nWHERE username = ?
DB --> Repo : Admin
Repo --> Svc : Optional<Admin>

alt Пользователь найден и пароль верный
    Svc -> Svc : BCrypt.matches(password, hash)
    Svc -> Svc : generateJwtToken(admin)
    Svc --> Ctrl : AuthResponse(token, admin)
    Ctrl --> API : 200 OK {token, fullName}
    API --> UI : Сохранить JWT в SharedPreferences
    UI -> UI : Перейти на HomeScreen
else Неверные учётные данные
    Svc --> Ctrl : throw AuthException
    Ctrl --> API : 401 Unauthorized
    API --> UI : Показать ошибку
    UI -> User : «Неверный логин или пароль»
end

@enduml
```

![Диаграмма последовательности — Вход](images/sd-login.png)

---

## 5.2 Диаграмма последовательности — UC-10: Создать заказ

```plantuml
@startuml SD-CreateOrder

skinparam sequenceArrowThickness 2

actor "Администратор" as User
participant "OrdersScreen" as UI
participant "ApiService" as API
participant "OrderController" as Ctrl
participant "OrderService" as Svc
participant "OrderRepository" as Repo
database "PostgreSQL" as DB

User -> UI : Нажать «Новый заказ»
UI -> UI : Показать форму
User -> UI : Заполнить поля\n(clientName, clientPhone,\naddressFrom, addressTo)
User -> UI : Нажать «Создать»
UI -> UI : Валидация полей

alt Валидация прошла
    UI -> API : POST /api/orders\n{clientName, clientPhone,\naddressFrom, addressTo}
    API -> Ctrl : createOrder(OrderDTO)
    Ctrl -> Svc : createOrder(order)
    Svc -> Svc : order.setStatus(NEW)
    Svc -> Repo : save(order)
    Repo -> DB : INSERT INTO orders ...
    DB --> Repo : Order (с id)
    Repo --> Svc : Order
    Svc --> Ctrl : Order
    Ctrl --> API : 201 Created {order}
    API --> UI : Обновить список заказов
    UI -> User : Показать успешное создание
else Ошибка валидации
    UI -> User : Показать ошибки полей
end

@enduml
```

![Диаграмма последовательности — Создать заказ](images/sd-create-order.png)

---

## 5.3 Диаграмма последовательности — UC-11: Назначить водителя

```plantuml
@startuml SD-AssignDriver

skinparam sequenceArrowThickness 2

actor "Администратор" as User
participant "AssignDriverScreen" as UI
participant "ApiService" as API
participant "AssignmentController" as Ctrl
participant "AssignmentService" as Svc
participant "OrderRepository" as ORepo
participant "DriverRepository" as DRepo
participant "CarRepository" as CRepo
participant "AssignmentRepository" as ARepo
database "PostgreSQL" as DB

User -> UI : Выбрать водителя и автомобиль
User -> UI : Нажать «Назначить»
UI -> API : POST /api/assignments\n{orderId, driverId, carId}
API -> Ctrl : createAssignment(AssignmentDTO)

Ctrl -> Svc : assignDriver(orderId, driverId, carId)
note right of Svc : @Transactional

group Транзакция
    Svc -> ORepo : findById(orderId)
    ORepo -> DB : SELECT
    DB --> ORepo : Order
    ORepo --> Svc : Order(status=NEW)

    Svc -> DRepo : findById(driverId)
    DRepo -> DB : SELECT
    DB --> DRepo : Driver
    DRepo --> Svc : Driver(status=FREE)

    Svc -> CRepo : findById(carId)
    CRepo -> DB : SELECT
    DB --> CRepo : Car
    CRepo --> Svc : Car(status=AVAILABLE)

    Svc -> Svc : Проверить статусы

    alt Все статусы корректны
        Svc -> ARepo : save(new Assignment)
        ARepo -> DB : INSERT INTO assignments
        DB --> ARepo : Assignment

        Svc -> ORepo : save(order.status=ASSIGNED)
        ORepo -> DB : UPDATE orders SET status='ASSIGNED'

        Svc -> DRepo : save(driver.status=BUSY)
        DRepo -> DB : UPDATE drivers SET status='BUSY'

        Svc -> CRepo : save(car.status=ON_TRIP)
        CRepo -> DB : UPDATE cars SET status='ON_TRIP'

        Svc --> Ctrl : Assignment
        Ctrl --> API : 201 Created
        API --> UI : Успех
        UI -> User : «Водитель назначен»
    else Некорректные статусы
        Svc --> Ctrl : throw IllegalStateException
        note right : Rollback транзакции
        Ctrl --> API : 400 Bad Request
        API --> UI : Ошибка
        UI -> User : «Водитель или авто недоступны»
    end
end

@enduml
```

![Диаграмма последовательности — Назначить водителя](images/sd-assign-driver.png)

---

## 5.4 Диаграмма классов проектирования

```plantuml
@startuml DesignClasses

skinparam classAttributeIconSize 0
skinparam class {
    BackgroundColor #FFFDE7
    BorderColor #F57F17
}

' === CONTROL LAYER ===
package "Control" #E8F5E9 {
    class AuthController {
        -authService: AuthService
        +login(AuthRequest): ResponseEntity<AuthResponse>
    }

    class DriverController {
        -driverService: DriverService
        +getAllDrivers(): List<Driver>
        +getDriverById(id): Driver
        +createDriver(Driver): Driver
        +updateDriver(id, Driver): Driver
        +deleteDriver(id): void
        +getFreeDrivers(): List<Driver>
    }

    class OrderController {
        -orderService: OrderService
        +getAllOrders(): List<Order>
        +getOrderById(id): Order
        +createOrder(Order): Order
        +updateStatus(id, status): Order
        +cancelOrder(id): void
    }

    class CarController {
        -carService: CarService
        +getAllCars(): List<Car>
        +getCarById(id): Car
        +createCar(Car): Car
        +updateCar(id, Car): Car
        +deleteCar(id): void
    }

    class AssignmentController {
        -assignmentService: AssignmentService
        +createAssignment(AssignmentDTO): Assignment
        +getByOrderId(orderId): Assignment
    }
}

' === MEDIATOR LAYER ===
package "Mediator" #FFF3E0 {
    class AuthService {
        -adminRepository: AdminRepository
        -jwtUtil: JwtUtil
        +authenticate(username, password): AuthResponse
        -generateToken(Admin): String
    }

    class DriverService {
        -driverRepository: DriverRepository
        +getAllDrivers(): List<Driver>
        +getDriverById(id): Driver
        +createDriver(Driver): Driver
        +updateDriver(id, Driver): Driver
        +deleteDriver(id): void
        +getFreeDrivers(): List<Driver>
    }

    class OrderService {
        -orderRepository: OrderRepository
        +getAllOrders(): List<Order>
        +getOrderById(id): Order
        +createOrder(Order): Order
        +updateStatus(id, OrderStatus): Order
        +cancelOrder(id): void
    }

    class CarService {
        -carRepository: CarRepository
        +getAllCars(): List<Car>
        +getCarById(id): Car
        +createCar(Car): Car
        +updateCar(id, Car): Car
        +deleteCar(id): void
        +getAvailableCars(): List<Car>
    }

    class AssignmentService {
        -assignmentRepository: AssignmentRepository
        -orderService: OrderService
        -driverService: DriverService
        -carService: CarService
        +assignDriver(orderId, driverId, carId): Assignment
        +getByOrderId(orderId): Assignment
    }
}

' === ENTITY LAYER ===
package "Entity" #F3E5F5 {
    class Admin {
        -id: Long
        -username: String
        -passwordHash: String
        -fullName: String
        -createdAt: LocalDateTime
    }

    class Driver {
        -id: Long
        -name: String
        -phone: String
        -licenseNumber: String
        -status: DriverStatus
        -createdAt: LocalDateTime
    }

    class Car {
        -id: Long
        -brand: String
        -model: String
        -plateNumber: String
        -year: Integer
        -color: String
        -status: CarStatus
        -createdAt: LocalDateTime
    }

    class Order {
        -id: Long
        -clientName: String
        -clientPhone: String
        -addressFrom: String
        -addressTo: String
        -status: OrderStatus
        -createdAt: LocalDateTime
        -updatedAt: LocalDateTime
    }

    class Assignment {
        -id: Long
        -order: Order
        -driver: Driver
        -car: Car
        -assignedAt: LocalDateTime
    }

    enum DriverStatus {
        FREE
        BUSY
        UNAVAILABLE
    }

    enum CarStatus {
        AVAILABLE
        ON_TRIP
        MAINTENANCE
        BROKEN
    }

    enum OrderStatus {
        NEW
        ASSIGNED
        ON_WAY
        DONE
        CANCELLED
    }
}

' === FOUNDATION LAYER ===
package "Foundation" #FFEBEE {
    interface AdminRepository <<JpaRepository>>
    interface DriverRepository <<JpaRepository>>
    interface OrderRepository <<JpaRepository>>
    interface CarRepository <<JpaRepository>>
    interface AssignmentRepository <<JpaRepository>>
}

' === Relationships ===
AuthController --> AuthService
DriverController --> DriverService
OrderController --> OrderService
CarController --> CarService
AssignmentController --> AssignmentService

AuthService --> AdminRepository
DriverService --> DriverRepository
OrderService --> OrderRepository
CarService --> CarRepository
AssignmentService --> AssignmentRepository
AssignmentService --> OrderService
AssignmentService --> DriverService
AssignmentService --> CarService

AdminRepository ..> Admin
DriverRepository ..> Driver
OrderRepository ..> Order
CarRepository ..> Car
AssignmentRepository ..> Assignment

Driver --> DriverStatus
Car --> CarStatus
Order --> OrderStatus
Assignment --> Order
Assignment --> Driver
Assignment --> Car

@enduml
```

![Диаграмма классов проектирования](images/design-classes.png)

---

## 5.5 Спецификация метода `assignDriver()`

| Параметр | Значение |
|----------|----------|
| **Класс** | AssignmentService |
| **Метод** | `assignDriver(Long orderId, Long driverId, Long carId)` |
| **Возвращает** | Assignment |
| **Аннотации** | @Transactional |
| **Исключения** | EntityNotFoundException, IllegalStateException |

### Псевдокод

```
МЕТОД assignDriver(orderId, driverId, carId):
    НАЧАЛО ТРАНЗАКЦИИ

    order ← orderRepository.findById(orderId)
    ЕСЛИ order = null ТО БРОСИТЬ EntityNotFoundException("Заказ не найден")

    driver ← driverRepository.findById(driverId)
    ЕСЛИ driver = null ТО БРОСИТЬ EntityNotFoundException("Водитель не найден")

    car ← carRepository.findById(carId)
    ЕСЛИ car = null ТО БРОСИТЬ EntityNotFoundException("Автомобиль не найден")

    ЕСЛИ order.status ≠ NEW ТО
        БРОСИТЬ IllegalStateException("Заказ не в статусе NEW")

    ЕСЛИ driver.status ≠ FREE ТО
        БРОСИТЬ IllegalStateException("Водитель не свободен")

    ЕСЛИ car.status ≠ AVAILABLE ТО
        БРОСИТЬ IllegalStateException("Автомобиль недоступен")

    assignment ← новый Assignment(order, driver, car)
    assignmentRepository.save(assignment)

    order.status ← ASSIGNED
    orderRepository.save(order)

    driver.status ← BUSY
    driverRepository.save(driver)

    car.status ← ON_TRIP
    carRepository.save(car)

    КОНЕЦ ТРАНЗАКЦИИ
    ВЕРНУТЬ assignment
```

---

## 5.6 Спецификация метода `deleteDriver()`

| Параметр | Значение |
|----------|----------|
| **Класс** | DriverService |
| **Метод** | `deleteDriver(Long id)` |
| **Возвращает** | void |
| **Исключения** | EntityNotFoundException, IllegalStateException |

### Псевдокод

```
МЕТОД deleteDriver(id):
    driver ← driverRepository.findById(id)
    ЕСЛИ driver = null ТО БРОСИТЬ EntityNotFoundException("Водитель не найден")

    ЕСЛИ driver.status = BUSY ТО
        БРОСИТЬ IllegalStateException("Нельзя удалить занятого водителя")

    driverRepository.delete(driver)
```

---

## 5.7 REST API эндпоинты

| # | Метод | Эндпоинт | Описание | Тело запроса | Ответ |
|---|-------|----------|----------|-------------|-------|
| 1 | POST | `/api/auth/login` | Аутентификация | `{username, password}` | `{token, fullName}` |
| 2 | GET | `/api/drivers` | Список всех водителей | — | `[Driver]` |
| 3 | GET | `/api/drivers/{id}` | Водитель по ID | — | `Driver` |
| 4 | POST | `/api/drivers` | Создать водителя | `Driver` | `Driver` (201) |
| 5 | PUT | `/api/drivers/{id}` | Обновить водителя | `Driver` | `Driver` |
| 6 | DELETE | `/api/drivers/{id}` | Удалить водителя | — | 204 |
| 7 | GET | `/api/drivers/free` | Свободные водители | — | `[Driver]` |
| 8 | GET | `/api/orders` | Список всех заказов | — | `[Order]` |
| 9 | GET | `/api/orders/{id}` | Заказ по ID | — | `Order` |
| 10 | POST | `/api/orders` | Создать заказ | `Order` | `Order` (201) |
| 11 | PATCH | `/api/orders/{id}/status` | Изменить статус заказа | `{status}` | `Order` |
| 12 | GET | `/api/cars` | Список всех автомобилей | — | `[Car]` |
| 13 | POST | `/api/cars` | Создать автомобиль | `Car` | `Car` (201) |
| 14 | PUT | `/api/cars/{id}` | Обновить автомобиль | `Car` | `Car` |
| 15 | POST | `/api/assignments` | Назначить водителя | `{orderId, driverId, carId}` | `Assignment` (201) |

---

## Навигация

| Предыдущий | Следующий |
|------------|-----------|
| [04. База данных](../04-database/README.md) | [06. Реализация](../06-implementation/README.md) |
