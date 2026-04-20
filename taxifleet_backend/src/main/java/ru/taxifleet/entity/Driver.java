package ru.taxifleet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import ru.taxifleet.enums.DriverStatus;

import java.time.LocalDate;

@Entity
@Table(name = "drivers")
@Getter @Setter @NoArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Driver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    @Column(name = "license_number", nullable = false, unique = true, length = 50)
    private String licenseNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private DriverStatus status = DriverStatus.FREE;

    @Column(name = "hired_at", nullable = false)
    private LocalDate hiredAt;

    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "drivers"})
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "car_id")
    private Car car;

    public boolean isFree() {
        return this.status == DriverStatus.FREE;
    }

    public void occupy() {
        this.status = DriverStatus.BUSY;
    }

    public void release() {
        this.status = DriverStatus.FREE;
    }
}