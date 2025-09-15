package org.charno.reflip.controller;

import org.charno.reflip.dto.PickupRequestDTO;
import org.charno.reflip.dto.DeliveryRequestDTO;
import org.charno.reflip.dto.AcceptTaskRequestDTO;
import org.charno.reflip.service.CourierService;
import org.charno.common.core.R;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/courier")
public class CourierController {

    @Autowired
    private CourierService courierService;

    @PostMapping("/pickup")
    public R<Boolean> pickupItem(@RequestBody PickupRequestDTO request) {
        boolean result = courierService.handlePickup(request);
        return result ? R.ok(result) : R.fail("取货失败");
    }

    @PostMapping("/deliver")
    public R<Boolean> deliverItem(@RequestBody DeliveryRequestDTO request) {
        boolean result = courierService.handleDelivery(request);
        return result ? R.ok(result) : R.fail("送达失败");
    }

    @PostMapping("/accept-task")
    public R<Boolean> acceptTask(@RequestBody AcceptTaskRequestDTO request) {
        boolean result = courierService.acceptTask(request);
        return result ? R.ok(result) : R.fail("接单失败");
    }
} 