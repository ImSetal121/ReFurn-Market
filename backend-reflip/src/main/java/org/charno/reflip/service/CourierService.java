package org.charno.reflip.service;

import org.charno.reflip.dto.PickupRequestDTO;
import org.charno.reflip.dto.DeliveryRequestDTO;
import org.charno.reflip.dto.AcceptTaskRequestDTO;

public interface CourierService {
    
    /**
     * 处理取货请求
     * 支持的任务类型：
     * - PICKUP_SERVICE: 寄卖商品取货服务
     * - WAREHOUSE_SHIPMENT: 仓库发货取货
     * - PRODUCT_RETURN: 商品退货取货
     * - RETURN_TO_SELLER: 退给卖家取货
     * @param request 取货请求信息
     * @return 处理结果
     */
    boolean handlePickup(PickupRequestDTO request);

    /**
     * 处理送达请求
     * 支持的任务类型：
     * - PICKUP_SERVICE: 寄卖商品送达仓库
     * - WAREHOUSE_SHIPMENT: 仓库发货送达买家
     * - PRODUCT_RETURN: 商品退货送达
     * - RETURN_TO_SELLER: 退给卖家送达
     * @param request 送达请求信息
     * @return 处理结果
     */
    boolean handleDelivery(DeliveryRequestDTO request);

    /**
     * 接取物流任务
     * @param request 接单请求信息
     * @return 处理结果
     */
    boolean acceptTask(AcceptTaskRequestDTO request);
} 