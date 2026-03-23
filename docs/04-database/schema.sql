-- ============================================
-- TaxiFleet Admin — DDL Schema
-- PostgreSQL 16
-- ============================================

-- Удаление таблиц (если существуют)
DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS cars CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS admins CASCADE;

-- ============================================
-- Таблица администраторов
-- ============================================
CREATE TABLE admins (
    id              BIGSERIAL       PRIMARY KEY,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    full_name       VARCHAR(100)    NOT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admins_username ON admins(username);

-- ============================================
-- Таблица водителей
-- ============================================
CREATE TABLE drivers (
    id              BIGSERIAL       PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL UNIQUE,
    license_number  VARCHAR(20)     NOT NULL UNIQUE,
    status          VARCHAR(20)     NOT NULL DEFAULT 'FREE'
                    CHECK (status IN ('FREE', 'BUSY', 'UNAVAILABLE')),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_drivers_status ON drivers(status);
CREATE INDEX idx_drivers_license ON drivers(license_number);

-- ============================================
-- Таблица автомобилей
-- ============================================
CREATE TABLE cars (
    id              BIGSERIAL       PRIMARY KEY,
    brand           VARCHAR(50)     NOT NULL,
    model           VARCHAR(50)     NOT NULL,
    plate_number    VARCHAR(15)     NOT NULL UNIQUE,
    year            INTEGER         NOT NULL CHECK (year > 1990),
    color           VARCHAR(30),
    status          VARCHAR(20)     NOT NULL DEFAULT 'AVAILABLE'
                    CHECK (status IN ('AVAILABLE', 'ON_TRIP', 'MAINTENANCE', 'BROKEN')),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_plate ON cars(plate_number);

-- ============================================
-- Таблица заказов
-- ============================================
CREATE TABLE orders (
    id              BIGSERIAL       PRIMARY KEY,
    client_name     VARCHAR(100)    NOT NULL,
    client_phone    VARCHAR(20),
    address_from    VARCHAR(255)    NOT NULL,
    address_to      VARCHAR(255)    NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'NEW'
                    CHECK (status IN ('NEW', 'ASSIGNED', 'ON_WAY', 'DONE', 'CANCELLED')),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP
);

CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- ============================================
-- Таблица назначений
-- ============================================
CREATE TABLE assignments (
    id              BIGSERIAL       PRIMARY KEY,
    order_id        BIGINT          NOT NULL UNIQUE,
    driver_id       BIGINT          NOT NULL,
    car_id          BIGINT          NOT NULL,
    assigned_at     TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_assignment_order
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignment_driver
        FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE RESTRICT,
    CONSTRAINT fk_assignment_car
        FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE RESTRICT
);

CREATE INDEX idx_assignments_driver ON assignments(driver_id);
CREATE INDEX idx_assignments_car ON assignments(car_id);
CREATE INDEX idx_assignments_order ON assignments(order_id);
