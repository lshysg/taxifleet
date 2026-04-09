package ru.taxifleet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.taxifleet.entity.Admin;
import java.util.Optional;

public interface AdminRepository extends JpaRepository<Admin, Long> {
    Optional<Admin> findByEmail(String email);
}
