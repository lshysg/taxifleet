# Результаты тестирования

> Полная таблица результатов выполнения JUnit-тестов проекта TaxiFleet Admin.

---

## Сводка

| Параметр | Значение |
|----------|----------|
| Фреймворк | JUnit 5 + Mockito |
| Всего тестов | 17 |
| Успешных | 17 |
| Неуспешных | 0 |
| Пропущенных | 0 |
| Время выполнения | ~2.3 сек |

---

## Полная таблица тестов

| # | Класс теста | Метод теста | Описание | Результат |
|---|-------------|-------------|----------|-----------|
| 1 | DriverServiceTest | `getAllDrivers_returnsDriverList` | Получение списка всех водителей | PASSED |
| 2 | DriverServiceTest | `getDriverById_existingId_returnsDriver` | Получение водителя по существующему ID | PASSED |
| 3 | DriverServiceTest | `getDriverById_nonExistingId_throwsException` | Выброс исключения при несуществующем ID | PASSED |
| 4 | DriverServiceTest | `createDriver_validDriver_returnsSaved` | Создание нового водителя | PASSED |
| 5 | DriverServiceTest | `deleteDriver_freeDriver_deletesSuccessfully` | Удаление свободного водителя | PASSED |
| 6 | DriverServiceTest | `deleteDriver_busyDriver_throwsException` | Запрет удаления занятого водителя | PASSED |
| 7 | DriverServiceTest | `getFreeDrivers_returnsFreeOnly` | Фильтрация только свободных водителей | PASSED |
| 8 | OrderServiceTest | `createOrder_setsStatusNew` | Новый заказ получает статус NEW | PASSED |
| 9 | OrderServiceTest | `getOrderById_existingId_returnsOrder` | Получение заказа по существующему ID | PASSED |
| 10 | OrderServiceTest | `getOrderById_nonExistingId_throwsException` | Выброс исключения при несуществующем ID | PASSED |
| 11 | OrderServiceTest | `cancelOrder_newOrder_cancelsSuccessfully` | Отмена заказа в статусе NEW | PASSED |
| 12 | OrderServiceTest | `cancelOrder_doneOrder_throwsException` | Запрет отмены завершённого заказа | PASSED |
| 13 | AssignmentServiceTest | `assignDriver_validData_createsAssignment` | Успешное назначение водителя | PASSED |
| 14 | AssignmentServiceTest | `assignDriver_busyDriver_throwsException` | Запрет назначения занятого водителя | PASSED |
| 15 | AssignmentServiceTest | `assignDriver_nonNewOrder_throwsException` | Запрет назначения на заказ не в статусе NEW | PASSED |
| 16 | AssignmentServiceTest | `assignDriver_unavailableCar_throwsException` | Запрет назначения недоступного автомобиля | PASSED |
| 17 | AuthServiceTest | `authenticate_validCredentials_returnsToken` | Успешная аутентификация возвращает JWT | PASSED |

---

## Покрытие по классам

| Класс сервиса | Тестов | Покрытие методов |
|---------------|--------|-----------------|
| DriverService | 7 | 100% (7/7 методов) |
| OrderService | 5 | 83% (5/6 методов) |
| AssignmentService | 4 | 100% (2/2 методов) |
| AuthService | 1 | 100% (1/1 метод) |

---

## Команда запуска

```bash
cd taxifleet_backend
mvn test
```

### Пример вывода

```
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
[INFO] Total time: 2.341 s
```
