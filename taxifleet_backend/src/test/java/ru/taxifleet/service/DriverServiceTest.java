package ru.taxifleet.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import ru.taxifleet.entity.Driver;
import ru.taxifleet.enums.DriverStatus;
import ru.taxifleet.exception.BusinessException;
import ru.taxifleet.exception.ResourceNotFoundException;
import ru.taxifleet.repository.AssignmentRepository;
import ru.taxifleet.repository.DriverRepository;
import ru.taxifleet.service.impl.DriverService;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Тесты DriverService")
class DriverServiceTest {

    @Mock private DriverRepository driverRepository;
    @Mock private AssignmentRepository assignmentRepository;
    @InjectMocks private DriverService driverService;

    private Driver testDriver;

    @BeforeEach
    void setUp() {
        testDriver = new Driver();
        testDriver.setId(1L);
        testDriver.setFullName("Иванов Иван Иванович");
        testDriver.setPhone("+79161234567");
        testDriver.setLicenseNumber("ВУ1234567");
        testDriver.setStatus(DriverStatus.FREE);
        testDriver.setHiredAt(LocalDate.of(2022, 3, 15));
    }

    @Test
    @DisplayName("getAllDrivers — возвращает список водителей")
    void getAllDrivers_ReturnsListOfDrivers() {
        when(driverRepository.findAll()).thenReturn(List.of(testDriver));
        List<Driver> result = driverService.getAllDrivers();
        assertEquals(1, result.size());
        assertEquals("Иванов Иван Иванович", result.get(0).getFullName());
        verify(driverRepository).findAll();
    }

    @Test
    @DisplayName("getDriverById — возвращает водителя по существующему ID")
    void getDriverById_ExistingId_ReturnsDriver() {
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));
        Driver result = driverService.getDriverById(1L);
        assertNotNull(result);
        assertEquals(1L, result.getId());
    }

    @Test
    @DisplayName("getDriverById — выбрасывает исключение если водитель не найден")
    void getDriverById_NotFound_ThrowsException() {
        when(driverRepository.findById(99L)).thenReturn(Optional.empty());
        assertThrows(ResourceNotFoundException.class,
                () -> driverService.getDriverById(99L));
    }

    @Test
    @DisplayName("getFreeDrivers — возвращает только свободных водителей")
    void getFreeDrivers_ReturnsOnlyFreeDrivers() {
        when(driverRepository.findByStatus(DriverStatus.FREE))
                .thenReturn(List.of(testDriver));
        List<Driver> result = driverService.getFreeDrivers();
        assertEquals(1, result.size());
        assertEquals(DriverStatus.FREE, result.get(0).getStatus());
    }

    @Test
    @DisplayName("createDriver — создаёт нового водителя")
    void createDriver_ValidDriver_SavesAndReturns() {
        when(driverRepository.existsByLicenseNumber("ВУ1234567")).thenReturn(false);
        when(driverRepository.save(testDriver)).thenReturn(testDriver);
        Driver result = driverService.createDriver(testDriver);
        assertNotNull(result);
        assertEquals(DriverStatus.FREE, result.getStatus());
        verify(driverRepository).save(testDriver);
    }

    @Test
    @DisplayName("createDriver — выбрасывает исключение при дублировании номера прав")
    void createDriver_DuplicateLicense_ThrowsException() {
        when(driverRepository.existsByLicenseNumber("ВУ1234567")).thenReturn(true);
        assertThrows(BusinessException.class,
                () -> driverService.createDriver(testDriver));
        verify(driverRepository, never()).save(any());
    }

    @Test
    @DisplayName("deleteDriver — удаляет водителя без активных назначений")
    void deleteDriver_NoActiveAssignments_DeletesDriver() {
        when(driverRepository.findById(1L)).thenReturn(Optional.of(testDriver));
        when(assignmentRepository.findByDriverId(1L)).thenReturn(List.of());
        driverService.deleteDriver(1L);
        verify(driverRepository).delete(testDriver);
    }

    @Test
    @DisplayName("isFree — возвращает true для свободного водителя")
    void isFree_FreeDriver_ReturnsTrue() {
        assertTrue(testDriver.isFree());
    }

    @Test
    @DisplayName("occupy — меняет статус водителя на BUSY")
    void occupy_ChangesStatusToBusy() {
        testDriver.occupy();
        assertEquals(DriverStatus.BUSY, testDriver.getStatus());
    }

    @Test
    @DisplayName("release — меняет статус водителя на FREE")
    void release_ChangesStatusToFree() {
        testDriver.setStatus(DriverStatus.BUSY);
        testDriver.release();
        assertEquals(DriverStatus.FREE, testDriver.getStatus());
    }
}
