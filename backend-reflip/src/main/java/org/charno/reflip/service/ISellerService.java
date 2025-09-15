package org.charno.reflip.service;

import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfProductSellRecord;
import org.charno.reflip.entity.RfProductReturnRecord;
import org.charno.reflip.dto.ConsignmentListingRequest;
import org.charno.common.entity.SysUserStripeAccount;
import java.util.List;
import java.util.Map;

/**
 * 卖家业务接口
 */
public interface ISellerService {
    
    /**
     * 商品上架
     * 处理前端传来的商品信息，进行验证和保存
     * 
     * @param rfProduct 商品信息
     * @return 上架后的商品信息
     */
    RfProduct listProduct(RfProduct rfProduct);

    /**
     * 寄卖上架
     * 处理前端传来的寄卖商品信息，创建商品和物流记录
     * 
     * @param request 寄卖上架请求
     * @return 上架后的商品信息
     */
    RfProduct consignmentListing(ConsignmentListingRequest request);

    /**
     * 自提上架
     * 处理前端传来的自提商品信息，进行验证和保存
     * 
     * @param rfProduct 商品信息
     * @return 上架后的商品信息
     */
    RfProduct selfPickupListing(RfProduct rfProduct);

    /**
     * 获取当前用户的商品列表
     * 
     * @return 用户商品列表
     */
    List<RfProduct> getMyProducts();

    /**
     * 获取当前用户的销售记录
     * 
     * @param page 页码
     * @param size 每页大小
     * @return 销售记录列表
     */
    List<RfProductSellRecord> getMySales(int page, int size);

    /**
     * 获取用户的Stripe账户信息
     * 
     * @return Stripe账户信息，如果不存在则返回null
     */
    SysUserStripeAccount getStripeAccountInfo();

    /**
     * 创建Stripe Express账户
     * 
     * @return 包含账户设置链接的响应信息
     */
    Map<String, Object> createStripeAccount();

    /**
     * 刷新Stripe账户设置链接
     * 
     * @return 包含新账户设置链接的响应信息
     */
    Map<String, Object> refreshStripeAccountLink();

    /**
     * 同步Stripe账户状态
     * 从Stripe获取最新状态并更新到数据库
     * 
     * @return 更新后的账户信息
     */
    SysUserStripeAccount syncStripeAccountStatus();

    /**
     * 获取退货申请详情
     * 
     * @param sellRecordId 销售记录ID
     * @return 退货申请详情
     */
    Map<String, Object> getReturnRequestDetail(Long sellRecordId);

    /**
     * 处理退货申请
     * 
     * @param sellRecordId 销售记录ID
     * @param accept 是否同意退货
     * @param sellerOpinion 卖家意见
     * @return 处理结果
     */
    boolean handleReturnRequest(Long sellRecordId, boolean accept, String sellerOpinion);

    /**
     * 确认收到退货商品
     * 
     * @param sellRecordId 销售记录ID
     * @return 确认结果
     */
    boolean confirmReturnReceived(Long sellRecordId);

    /**
     * 请求退回卖家
     * 
     * @param productId 商品ID
     * @param returnAddress 退回地址
     * @return 请求结果
     */
    boolean requestReturnToSeller(Long productId, String returnAddress);
} 