package org.charno.reflip.dto;

/**
 * 退货申请请求DTO
 */
public class RefundApplicationRequest {
    
    /**
     * 订单ID
     */
    private String orderId;
    
    /**
     * 退货原因类型
     */
    private String reason;
    
    /**
     * 详细说明
     */
    private String description;
    
    /**
     * 取货地址
     */
    private String pickupAddress;
    
    public RefundApplicationRequest() {}
    
    public RefundApplicationRequest(String orderId, String reason, String description) {
        this.orderId = orderId;
        this.reason = reason;
        this.description = description;
    }
    
    public RefundApplicationRequest(String orderId, String reason, String description, String pickupAddress) {
        this.orderId = orderId;
        this.reason = reason;
        this.description = description;
        this.pickupAddress = pickupAddress;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPickupAddress() {
        return pickupAddress;
    }

    public void setPickupAddress(String pickupAddress) {
        this.pickupAddress = pickupAddress;
    }

    @Override
    public String toString() {
        return "RefundApplicationRequest{" +
                "orderId='" + orderId + '\'' +
                ", reason='" + reason + '\'' +
                ", description='" + description + '\'' +
                ", pickupAddress='" + pickupAddress + '\'' +
                '}';
    }
} 