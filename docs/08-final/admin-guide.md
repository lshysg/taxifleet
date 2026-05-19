# Руководство администратора (развёртывание)

> Руководство по установке, настройке и запуску информационной системы TaxiFleet Admin.

---

## 1. Системные требования

| Компонент | Минимальные требования |
|-----------|----------------------|
| ОС | Windows 10+ / macOS 12+ / Ubuntu 20.04+ |
| Java | JDK 17 или выше |
| Maven | 3.9 или выше |
| PostgreSQL | 16.x |
| Flutter SDK | 3.x |
| Dart SDK | 3.x (входит в Flutter) |
| Android SDK | API Level 21+ (для эмулятора) |
| Оперативная память | 8 GB+ |
| Свободное место на диске | 5 GB+ |

---

## 2. Установка PostgreSQL

### Windows

1. Скачайте установщик с [postgresql.org](https://www.postgresql.org/download/windows/).
2. Запустите установщик, следуйте инструкциям.
3. Запомните пароль для пользователя `postgres`.
4. Убедитесь, что PostgreSQL добавлен в PATH.

### Проверка установки

```bash
psql --version
# psql (PostgreSQL) 16.x
```

### Создание базы данных

```bash
# Подключиться к PostgreSQL
psql -U postgres

# Создать базу данных
CREATE DATABASE taxifleet;

# Выйти
\q
```

### Применение схемы и начальных данных

```bash
# Применить DDL-скрипт
psql -U postgres -d taxifleet -f docs/04-database/schema.sql

# Загрузить начальные данные
psql -U postgres -d taxifleet -f docs/04-database/data.sql
```

---

## 3. Запуск серверной части (Spring Boot)

### 3.1 Настройка подключения к БД

Откройте файл `taxifleet_backend/src/main/resources/application.yml` и настройте параметры:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/taxifleet
    username: postgres
    password: your_password_here
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: your-secret-key-at-least-256-bits-long-for-hs256
  expiration: 86400000  # 24 часа в миллисекундах

server:
  port: 8080
```

### 3.2 Сборка и запуск

```bash
cd taxifleet_backend

# Сборка проекта
mvn clean package -DskipTests

# Запуск
mvn spring-boot:run
```

### 3.3 Проверка работоспособности

```bash
# Проверка доступности сервера
curl http://localhost:8080/api/auth/login \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Ожидаемый ответ:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "fullName": "Иванов Иван Иванович"
}
```

### 3.4 Swagger UI

После запуска сервера Swagger UI доступен по адресу:

```
http://localhost:8080/swagger-ui.html
```

---

## 4. Настройка Flutter-приложения

### 4.1 Установка Flutter SDK

```bash
# Проверка установки
flutter doctor
```

Убедитесь, что все пункты имеют статус «зелёной галочки» или допустимых предупреждений.

### 4.2 Настройка адреса сервера

В файле `taxifleet_app/lib/services/api_service.dart` укажите адрес сервера:

```dart
// Для Android эмулятора:
baseUrl: 'http://10.0.2.2:8080/api'

// Для физического устройства (укажите IP компьютера):
baseUrl: 'http://192.168.1.100:8080/api'

// Для iOS эмулятора:
baseUrl: 'http://localhost:8080/api'
```

### 4.3 Сборка и запуск

```bash
cd taxifleet_app

# Установка зависимостей
flutter pub get

# Запуск на эмуляторе
flutter run

# Сборка APK
flutter build apk --release
```

---

## 5. Решение типичных проблем

### Проблема: «Connection refused» при подключении к серверу

| Причина | Решение |
|---------|---------|
| Сервер не запущен | Запустите `mvn spring-boot:run` |
| Неверный адрес в Flutter | Для Android эмулятора используйте `10.0.2.2` |
| Firewall блокирует порт | Откройте порт 8080 в настройках брандмауэра |

### Проблема: «Authentication failed» при входе

| Причина | Решение |
|---------|---------|
| Неверные учётные данные | Используйте `admin` / `admin123` |
| Данные не загружены в БД | Выполните `psql -d taxifleet -f data.sql` |
| Пароль не BCrypt-хешированный | Проверьте содержимое таблицы admins |

### Проблема: PostgreSQL не запускается

```bash
# Windows: проверить службу
net start postgresql-x64-16

# Проверить порт
netstat -an | findstr 5432
```

### Проблема: Flutter build error

```bash
# Очистить кеш
flutter clean
flutter pub get

# Обновить зависимости
flutter pub upgrade
```

### Проблема: «LazyInitializationException» в API

Убедитесь, что Entity-классы содержат аннотацию:
```java
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
```

---

## 6. Запуск тестов

```bash
cd taxifleet_backend

# Запуск всех тестов
mvn test

# Запуск конкретного тестового класса
mvn test -Dtest=DriverServiceTest

# Запуск с отчётом о покрытии
mvn test jacoco:report
```

---

## 7. Порядок полного развёртывания

```bash
# 1. Клонировать репозиторий
git clone <repository-url>
cd taxifleet

# 2. Создать и настроить БД
psql -U postgres -c "CREATE DATABASE taxifleet;"
psql -U postgres -d taxifleet -f docs/04-database/schema.sql
psql -U postgres -d taxifleet -f docs/04-database/data.sql

# 3. Настроить и запустить сервер
cd taxifleet_backend
# Отредактировать application.yml (пароль БД)
mvn spring-boot:run

# 4. В другом терминале — запустить Flutter
cd taxifleet_app
flutter pub get
flutter run
```
