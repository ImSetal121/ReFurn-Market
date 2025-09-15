package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.reflip.entity.RfProductSellRecord;

import java.util.List;

/**
 * 买家业务接口
 */
public interface IBuyerService {

    /**
     * 锁定商品
     * 将商品锁定2分钟，锁定期间其他用户无法购买
     * 
     * @param productId 商品ID
     * @return 锁定是否成功
     */
    boolean lockProduct(Long productId);

    /**
     * 检查商品是否被锁定
     * 
     * @param productId 商品ID
     * @return 是否被锁定
     */
    boolean isProductLocked(Long productId);

    /**
     * 解锁商品
     * 提前释放商品锁定
     * 
     * @param productId 商品ID
     * @return 解锁是否成功
     */
    boolean unlockProduct(Long productId);

    /**
     * 检查当前用户是否是商品锁的拥有者
     * 
     * @param productId 商品ID
     * @return 是否为锁拥有者
     */
    boolean isLockOwner(Long productId);

    /**
     * 获取商品锁的剩余时间（秒）
     * 
     * @param productId 商品ID
     * @return 剩余时间（秒），如果未锁定或当前用户不是拥有者则返回-1
     */
    long getLockRemainingTime(Long productId);

    /**
     * 处理购买成功
     * 更新商品状态为SOLD，创建销售记录，释放商品锁
     * 
     * @param productId 商品ID
     * @param paymentIntentId 支付意图ID
     * @return 处理是否成功
     */
    boolean handlePurchaseSuccess(Long productId, String paymentIntentId);

    /**
     * 检查当前用户是否为商品的拥有者（发布人）
     * 
     * @param productId 商品ID
     * @return 是否为商品拥有者
     */
    boolean isProductOwner(Long productId);

    /**
     * 处理寄卖商品购买成功
     * 检查锁定状态，更新商品状态，创建销售记录，创建内部物流任务
     * 
     * @param productId 商品ID
     * @param paymentIntentId 支付意图ID
     * @param deliveryAddress 收货地址
     * @param deliveryPhone 收货电话
     * @param deliveryName 收货人姓名
     * @return 处理是否成功
     */
    boolean handleConsignmentPurchaseSuccess(Long productId, String paymentIntentId, 
                                           String deliveryAddress, String deliveryPhone, String deliveryName);

    /**
     * 获取当前用户的购买记录
     * 分页获取，按创建时间降序排列
     * 
     * @param page 页码（从1开始）
     * @param size 每页大小
     * @return 购买记录列表
     */
    Page<RfProductSellRecord> getMyOrders(int page, int size);

    /**
     * 确认收货
     * 
     * @param orderId 订单ID
     * @param comment 评价内容
     * @param receiptImages 收货凭证图片列表
     * @return 确认是否成功
     */
    boolean confirmReceipt(String orderId, String comment, List<String> receiptImages);

    /**
     * 申请退货
     * 
     * @param orderId 订单ID
     * @param reason 退货原因类型
     * @param description 退货原因详细说明
     * @param pickupAddress 取货地址
     * @return 申请是否成功
     */
    boolean applyRefund(String orderId, String reason, String description, String pickupAddress);
} 