package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfUserProductBrowseHistory;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.mapper.RfUserProductBrowseHistoryMapper;
import org.charno.reflip.service.IRfUserProductBrowseHistoryService;
import org.charno.reflip.service.IRfProductService;
import org.charno.common.entity.SysUser;
import org.charno.system.service.ISysUserService;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户商品浏览记录业务实现类
 */
@Service
public class RfUserProductBrowseHistoryServiceImpl
        extends ServiceImpl<RfUserProductBrowseHistoryMapper, RfUserProductBrowseHistory>
        implements IRfUserProductBrowseHistoryService {

    @Autowired
    private IRfProductService rfProductService;

    @Autowired
    private ISysUserService sysUserService;

    @Override
    public Page<RfUserProductBrowseHistory> selectPageWithCondition(Page<RfUserProductBrowseHistory> page,
            RfUserProductBrowseHistory condition) {
        LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();

        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserProductBrowseHistory::getUserId, condition.getUserId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfUserProductBrowseHistory::getProductId, condition.getProductId());
            }
            if (condition.getBrowseTime() != null) {
                queryWrapper.ge(RfUserProductBrowseHistory::getBrowseTime, condition.getBrowseTime());
            }
        }

        queryWrapper.eq(RfUserProductBrowseHistory::getIsDelete, false)
                .orderByDesc(RfUserProductBrowseHistory::getBrowseTime);
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfUserProductBrowseHistory> selectListWithCondition(RfUserProductBrowseHistory condition) {
        LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();

        if (condition != null) {
            if (condition.getUserId() != null) {
                queryWrapper.eq(RfUserProductBrowseHistory::getUserId, condition.getUserId());
            }
            if (condition.getProductId() != null) {
                queryWrapper.eq(RfUserProductBrowseHistory::getProductId, condition.getProductId());
            }
            if (condition.getBrowseTime() != null) {
                queryWrapper.ge(RfUserProductBrowseHistory::getBrowseTime, condition.getBrowseTime());
            }
        }

        queryWrapper.eq(RfUserProductBrowseHistory::getIsDelete, false)
                .orderByDesc(RfUserProductBrowseHistory::getBrowseTime);
        return this.list(queryWrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean recordBrowseHistory(Long userId, Long productId) {
        try {
            // 检查是否已存在相同的浏览记录
            LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();
            queryWrapper.eq(RfUserProductBrowseHistory::getUserId, userId)
                    .eq(RfUserProductBrowseHistory::getProductId, productId)
                    .eq(RfUserProductBrowseHistory::getIsDelete, false);

            RfUserProductBrowseHistory existingRecord = getOne(queryWrapper);

            if (existingRecord != null) {
                // 如果已存在，更新浏览时间
                existingRecord.setBrowseTime(LocalDateTime.now());
                existingRecord.setUpdateTime(LocalDateTime.now());
                return updateById(existingRecord);
            } else {
                // 如果不存在，创建新记录
                RfUserProductBrowseHistory newRecord = new RfUserProductBrowseHistory();
                newRecord.setUserId(userId);
                newRecord.setProductId(productId);
                newRecord.setBrowseTime(LocalDateTime.now());
                newRecord.setCreateTime(LocalDateTime.now());
                newRecord.setUpdateTime(LocalDateTime.now());
                newRecord.setIsDelete(false);
                return save(newRecord);
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to record browse history: " + e.getMessage());
        }
    }

    @Override
    public Page<RfUserProductBrowseHistory> getUserBrowseHistory(Long userId, Integer page, Integer size) {
        // 创建分页对象
        Page<RfUserProductBrowseHistory> pageInfo = new Page<>(page, size);

        // 构建查询条件
        LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserProductBrowseHistory::getUserId, userId)
                .eq(RfUserProductBrowseHistory::getIsDelete, false)
                .orderByDesc(RfUserProductBrowseHistory::getBrowseTime);

        // 执行分页查询
        Page<RfUserProductBrowseHistory> result = page(pageInfo, queryWrapper);

        // 填充商品信息
        if (result.getRecords() != null && !result.getRecords().isEmpty()) {
            result.getRecords().forEach(record -> {
                RfProduct product = rfProductService.getById(record.getProductId());
                record.setProductInfo(product);
            });
        }

        return result;
    }

    @Override
    public List<RfUserProductBrowseHistory> getRecentBrowseHistory(Long userId, Integer limit) {
        // 构建查询条件
        LambdaQueryWrapper<RfUserProductBrowseHistory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(RfUserProductBrowseHistory::getUserId, userId)
                .eq(RfUserProductBrowseHistory::getIsDelete, false)
                .orderByDesc(RfUserProductBrowseHistory::getBrowseTime)
                .last("LIMIT " + limit);

        // 执行查询
        List<RfUserProductBrowseHistory> result = list(queryWrapper);

        // 填充商品信息
        if (result != null && !result.isEmpty()) {
            result.forEach(record -> {
                RfProduct product = rfProductService.getById(record.getProductId());
                record.setProductInfo(product);
            });
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteBrowseHistory(Long userId, Long productId) {
        try {
            LambdaUpdateWrapper<RfUserProductBrowseHistory> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(RfUserProductBrowseHistory::getUserId, userId)
                    .set(RfUserProductBrowseHistory::getIsDelete, true)
                    .set(RfUserProductBrowseHistory::getUpdateTime, LocalDateTime.now());

            if (productId != null) {
                updateWrapper.eq(RfUserProductBrowseHistory::getProductId, productId);
            }

            return update(updateWrapper);
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete browse history: " + e.getMessage());
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean clearUserBrowseHistory(Long userId) {
        try {
            LambdaUpdateWrapper<RfUserProductBrowseHistory> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(RfUserProductBrowseHistory::getUserId, userId)
                    .set(RfUserProductBrowseHistory::getIsDelete, true)
                    .set(RfUserProductBrowseHistory::getUpdateTime, LocalDateTime.now());

            return update(updateWrapper);
        } catch (Exception e) {
            throw new RuntimeException("Failed to clear user browse history: " + e.getMessage());
        }
    }
}