package ru.taxifleet.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.taxifleet.entity.Order;
import ru.taxifleet.enums.OrderStatus;
import ru.taxifleet.service.impl.OrderService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<List<Order>> getAll(
            @RequestParam(required = false) String status) {
        if (status != null) {
            return ResponseEntity.ok(
                    orderService.getOrdersByStatus(OrderStatus.valueOf(status.toUpperCase())));
        }
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getById(@PathVariable Long id) {
        return ResponseEntity.ok(orderService.getOrderById(id));
    }

    @PostMapping
    public ResponseEntity<Order> create(@RequestBody Order order) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(orderService.createOrder(order));
    }

    @PostMapping("/{id}/assign")
    public ResponseEntity<Order> assignDriver(@PathVariable Long id,
                                              @RequestBody Map<String, Long> body) {
        Long driverId = body.get("driverId");
        return ResponseEntity.ok(orderService.assignDriver(id, driverId));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Order> changeStatus(@PathVariable Long id,
                                              @RequestBody Map<String, String> body) {
        OrderStatus status = OrderStatus.valueOf(body.get("status").toUpperCase());
        return ResponseEntity.ok(orderService.changeStatus(id, status));
    }
}
