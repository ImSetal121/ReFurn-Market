package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfUserFavoriteProduct;
import org.charno.reflip.mapper.RfUserFavoriteProductMapper;
import org.charno.reflip.service.IRfUserFavoriteProductService;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户收藏商品业务实现类
 */
@Service
public class RfUserFavoriteProductServiceImpl extends ServiceImpl<RfUserFavoriteProductMapper, RfUserFavoriteProduct>
        implements IRfUserFavoriteProductService {

    @Override
    public Page<RfUserFavoriteProduct> selectPageWithCondition(Page<RfUserFavoriteProduct> page,
            RfUserFavoriteProduct condition) {
        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();

        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserFavoriteProduct::getUserId, condition.getUserId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfUserFavoriteProduct::getProductId, condition.getProductId());
            }
        }

        queryWrapper.orderByDesc(RfUserFavoriteProduct::getFavoriteTime);
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfUserFavoriteProduct> selectListWithCondition(RfUserFavoriteProduct condition) {
        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();

        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserFavoriteProduct::getUserId, condition.getUserId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfUserFavoriteProduct::getProductId, condition.getProductId());
            }
        }

        queryWrapper.orderByDesc(RfUserFavoriteProduct::getFavoriteTime);
        return this.list(queryWrapper);
    }

    @Override
    @Transactional
    public boolean addFavorite(Long userId, Long productId) {
        if (userId == null || productId == null) {
            return false;
        }

        // 检查是否已经收藏
        if (isFavorited(userId, productId)) {
            return true; // 已经收藏，返回成功
        }

        // 创建收藏记录
        RfUserFavoriteProduct favorite = new RfUserFavoriteProduct();
        favorite.setUserId(userId);
        favorite.setProductId(productId);
        favorite.setFavoriteTime(LocalDateTime.now());

        return this.save(favorite);
    }

    @Override
    @Transactional
    public boolean removeFavorite(Long userId, Long productId) {
        if (userId == null || productId == null) {
            return false;
        }

        // 物理删除收藏记录
        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId)
                .eq(RfUserFavoriteProduct::getProductId, productId);

        return this.remove(queryWrapper);
    }

    @Override
    public boolean isFavorited(Long userId, Long productId) {
        if (userId == null || productId == null) {
            return false;
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId)
                .eq(RfUserFavoriteProduct::getProductId, productId);

        return this.count(queryWrapper) > 0;
    }

    @Override
    public List<RfUserFavoriteProduct> getUserFavorites(Long userId) {
        if (userId == null) {
            return List.of();
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId)
                .orderByDesc(RfUserFavoriteProduct::getFavoriteTime);

        return this.list(queryWrapper);
    }

    @Override
    public Page<RfUserFavoriteProduct> getUserFavoritesPage(Page<RfUserFavoriteProduct> page, Long userId) {
        if (userId == null) {
            return page;
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId)
                .orderByDesc(RfUserFavoriteProduct::getFavoriteTime);

        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfUserFavoriteProduct> getProductFavorites(Long productId) {
        if (productId == null) {
            return List.of();
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getProductId, productId)
                .orderByDesc(RfUserFavoriteProduct::getFavoriteTime);

        return this.list(queryWrapper);
    }

    @Override
    public Long getUserFavoriteCount(Long userId) {
        if (userId == null) {
            return 0L;
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId);

        return this.count(queryWrapper);
    }

    @Override
    public Long getProductFavoriteCount(Long productId) {
        if (productId == null) {
            return 0L;
        }

        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getProductId, productId);

        return this.count(queryWrapper);
    }

    @Override
    @Transactional
    public boolean removeFavoritesBatch(Long userId, List<Long> productIds) {
        if (userId == null || productIds == null || productIds.isEmpty()) {
            return false;
        }

        // 批量物理删除收藏记录
        LambdaQueryWrapper<RfUserFavoriteProduct> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserFavoriteProduct::getUserId, userId)
                .in(RfUserFavoriteProduct::getProductId, productIds);

        return this.remove(queryWrapper);
    }
}