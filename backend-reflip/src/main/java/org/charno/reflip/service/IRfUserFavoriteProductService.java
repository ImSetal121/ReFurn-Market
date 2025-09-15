package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfUserFavoriteProduct;
import java.util.List;

/**
 * 用户收藏商品业务接口
 */
public interface IRfUserFavoriteProductService extends IBaseService<RfUserFavoriteProduct> {

    /**
     * 分页条件查询
     */
    Page<RfUserFavoriteProduct> selectPageWithCondition(Page<RfUserFavoriteProduct> page,
            RfUserFavoriteProduct condition);

    /**
     * 不分页条件查询
     */
    List<RfUserFavoriteProduct> selectListWithCondition(RfUserFavoriteProduct condition);

    /**
     * 用户收藏商品
     */
    boolean addFavorite(Long userId, Long productId);

    /**
     * 用户取消收藏商品
     */
    boolean removeFavorite(Long userId, Long productId);

    /**
     * 判断用户是否已收藏某商品
     */
    boolean isFavorited(Long userId, Long productId);

    /**
     * 获取用户的所有收藏商品
     */
    List<RfUserFavoriteProduct> getUserFavorites(Long userId);

    /**
     * 分页获取用户的收藏商品
     */
    Page<RfUserFavoriteProduct> getUserFavoritesPage(Page<RfUserFavoriteProduct> page, Long userId);

    /**
     * 获取商品的收藏用户列表
     */
    List<RfUserFavoriteProduct> getProductFavorites(Long productId);

    /**
     * 获取用户收藏商品数量
     */
    Long getUserFavoriteCount(Long userId);

    /**
     * 获取商品被收藏次数
     */
    Long getProductFavoriteCount(Long productId);

    /**
     * 批量取消收藏（根据商品ID列表）
     */
    boolean removeFavoritesBatch(Long userId, List<Long> productIds);
}