-- ============================================
-- TaxiFleet Admin — Initial Data
-- PostgreSQL 16
-- ============================================

-- Администратор (пароль: admin123, BCrypt hash)
INSERT INTO admins (username, password_hash, full_name) VALUES
    ('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Иванов Иван Иванович');

-- Водители
INSERT INTO drivers (name, phone, license_number, status) VALUES
    ('Петров Пётр Петрович', '+7-900-111-2233', '77 01 123456', 'FREE'),
    ('Сидоров Алексей Николаевич', '+7-900-222-3344', '77 02 234567', 'FREE'),
    ('Козлов Дмитрий Сергеевич', '+7-900-333-4455', '77 03 345678', 'BUSY'),
    ('Морозова Елена Викторовна', '+7-900-444-5566', '77 04 456789', 'UNAVAILABLE');

-- Автомобили
INSERT INTO cars (brand, model, plate_number, year, color, status) VALUES
    ('Toyota', 'Camry', 'А111АА77', 2022, 'Белый', 'AVAILABLE'),
    ('Hyundai', 'Solaris', 'В222ВВ77', 2021, 'Серый', 'AVAILABLE'),
    ('Kia', 'Rio', 'С333СС77', 2023, 'Чёрный', 'ON_TRIP'),
    ('Volkswagen', 'Polo', 'Е444ЕЕ77', 2020, 'Синий', 'MAINTENANCE');

-- Заказы
INSERT INTO orders (client_name, client_phone, address_from, address_to, status) VALUES
    ('Алексеев Максим', '+7-911-100-2000', 'ул. Ленина, 10', 'пр. Мира, 25', 'NEW'),
    ('Николаева Ольга', '+7-911-200-3000', 'ул. Пушкина, 5', 'ул. Гагарина, 12', 'ASSIGNED'),
    ('Фёдоров Игорь', '+7-911-300-4000', 'пр. Победы, 30', 'ул. Советская, 8', 'ON_WAY'),
    ('Смирнова Анна', '+7-911-400-5000', 'ул. Кирова, 15', 'ул. Мира, 3', 'DONE');

-- Назначение (заказ 2 → водитель 3, автомобиль 3)
INSERT INTO assignments (order_id, driver_id, car_id) VALUES
    (2, 3, 3);
