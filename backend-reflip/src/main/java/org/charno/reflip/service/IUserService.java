package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.reflip.entity.RfBillItem;
import org.charno.reflip.entity.RfProduct;
import java.util.Map;

/**
 * 用户业务接口
 */
public interface IUserService {

    /**
     * 获取当前用户的账单列表
     * 
     * @param status 账单状态 (可选: PENDING, PAID, OVERDUE)
     * @param page   页码
     * @param size   每页大小
     * @return 账单分页数据
     */
    Page<RfBillItem> getUserBills(String status, Integer page, Integer size);

    /**
     * 获取当前用户的账单统计信息
     * 
     * @return 账单统计数据
     */
    Map<String, Object> getBillsSummary();

    /**
     * 获取当前用户的账单详情
     * 
     * @param billId 账单ID
     * @return 账单详情
     */
    RfBillItem getBillDetail(Long billId);

    /**
     * 处理账单支付成功
     * 
     * @param billId          账单ID
     * @param paymentIntentId Stripe支付意图ID
     * @return 处理结果
     */
    boolean handleBillPaymentSuccess(Long billId, String paymentIntentId);

    /**
     * 使用余额支付账单
     * 
     * @param billId 账单ID
     * @return 处理结果
     */
    boolean handleBillBalancePayment(Long billId);

    /**
     * 收藏商品
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    boolean addFavoriteProduct(Long productId);

    /**
     * 取消收藏商品
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    boolean removeFavoriteProduct(Long productId);

    /**
     * 查询某个商品是否被当前用户收藏
     * 
     * @param productId 商品ID
     * @return 是否已收藏
     */
    boolean isProductFavorited(Long productId);

    /**
     * 获取当前用户的收藏商品列表（分页）
     * 
     * @param page 页码
     * @param size 每页大小
     * @return 收藏商品分页数据
     */
    Page<RfProduct> getUserFavoriteProducts(Integer page, Integer size);

    /**
     * 记录用户浏览商品历史
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    boolean recordBrowseHistory(Long productId);

    /**
     * 获取当前用户的浏览历史记录（分页）
     * 
     * @param page 页码
     * @param size 每页大小
     * @return 浏览历史分页数据
     */
    Page<RfProduct> getUserBrowseHistory(Integer page, Integer size);

    /**
     * 获取某个商品的总浏览数
     * 
     * @param productId 商品ID
     * @return 浏览次数
     */
    Long getProductBrowseCount(Long productId);
}