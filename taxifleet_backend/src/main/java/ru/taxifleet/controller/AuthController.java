package ru.taxifleet.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import ru.taxifleet.entity.Admin;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.repository.AdminRepository;
import ru.taxifleet.security.JwtUtils;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Admin admin = adminRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException("Неверный email или пароль"));

        if (!passwordEncoder.matches(password, admin.getPasswordHash())) {
            throw new BusinessException("Неверный email или пароль");
        }

        String token = jwtUtils.generateToken(email);
        return ResponseEntity.ok(Map.of(
                "token", token,
                "adminId", admin.getId(),
                "name", admin.getName()
        ));
    }
}
