package org.charno.reflip.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.service.IVisitorService;
import org.charno.reflip.service.IBuyerService;
import org.charno.reflip.service.IRfProductService;
import org.charno.system.service.ISysUserService;
import org.charno.common.entity.SysUser;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 访客业务实现类
 */
@Service
public class VisitorServiceImpl implements IVisitorService {

    @Autowired
    private IRfProductService rfProductService;
    
    @Autowired
    private ISysUserService sysUserService;
    
    @Autowired
    private IBuyerService buyerService;

    @Override
    public Page<RfProduct> searchProducts(String keyword, String type, String category,
                                        Double minPrice, Double maxPrice, String sortBy,
                                        Integer page, Integer size) {
        // 创建分页对象
        Page<RfProduct> pageInfo = new Page<>(page, size);
        
        // 构建查询条件
        QueryWrapper<RfProduct> queryWrapper = new QueryWrapper<>();
        
        // 只查询已上架且未删除的商品
        queryWrapper.eq("status", "LISTED");
        
        // 关键词搜索 - 在商品名称和描述中搜索
        if (StringUtils.hasText(keyword)) {
            queryWrapper.and(wrapper -> wrapper
                .like("name", keyword)
                .or()
                .like("description", keyword)
            );
        }
        
        // 商品类型筛选
        if (StringUtils.hasText(type)) {
            queryWrapper.eq("type", type);
        }
        
        // 商品类别筛选
        if (StringUtils.hasText(category)) {
            queryWrapper.eq("category", category);
        }
        
        // 价格区间筛选
        if (minPrice != null && minPrice > 0) {
            queryWrapper.ge("price", BigDecimal.valueOf(minPrice));
        }
        if (maxPrice != null && maxPrice > 0) {
            queryWrapper.le("price", BigDecimal.valueOf(maxPrice));
        }
        
        // 排序处理
        applySorting(queryWrapper, sortBy);
        
        // 执行分页查询
        Page<RfProduct> result = rfProductService.page(pageInfo, queryWrapper);
        
        // 过滤被锁定的商品，但保持原有的total值以维持正确的分页逻辑
        List<RfProduct> filteredProducts = result.getRecords().stream()
            .filter(product -> !buyerService.isProductLocked(product.getId()))
            .collect(Collectors.toList());
        
        // 更新结果 - 只更新records，保持原有的total、pages等分页信息
        result.setRecords(filteredProducts);
        // 注意：不修改total值，保持分页逻辑正确
        
        // 为每个商品填充用户信息
        for (RfProduct product : result.getRecords()) {
            if (product.getUserId() != null) {
                SysUser userInfo = sysUserService.getById(product.getUserId());
                if (userInfo != null) {
                    // 清空敏感信息
                    userInfo.setPassword(null);
                    userInfo.setWechatOpenId(null);
                    userInfo.setGoogleSub(null);
                    userInfo.setAppleSub(null);
                    product.setUserInfo(userInfo);
                }
            }
        }
        
        return result;
    }

    /**
     * 应用排序规则
     */
    private void applySorting(QueryWrapper<RfProduct> queryWrapper, String sortBy) {
        switch (sortBy.toLowerCase()) {
            case "price_asc":
                queryWrapper.orderByAsc("price");
                break;
            case "price_desc":
                queryWrapper.orderByDesc("price");
                break;
            case "distance":
                // TODO: 实现距离排序，需要用户位置信息
                queryWrapper.orderByDesc("create_time");
                break;
            case "condition":
                // TODO: 实现按商品状况排序
                queryWrapper.orderByDesc("create_time");
                break;
            case "recommended":
            default:
                // 推荐排序：综合考虑创建时间、价格等因素
                queryWrapper.orderByDesc("create_time")
                           .orderByAsc("price");
                break;
        }
    }

    @Override
    public List<String> getHotKeywords() {
        // 返回热门搜索关键词
        // TODO: 可以从数据库统计用户搜索记录来动态生成
        return Arrays.asList(
            "Sofa",
            "Chair", 
            "Table",
            "Bed",
            "Desk",
            "Bookshelf",
            "Wardrobe",
            "Coffee Table",
            "Dining Set",
            "TV Stand"
        );
    }

    @Override
    public RfProduct getProductDetail(Long productId) {
        if (productId == null) {
            throw new IllegalArgumentException("Product ID cannot be null");
        }
        
        // 查询商品详情，只返回已上架且未删除的商品
        QueryWrapper<RfProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("id", productId)
                   .eq("status", "LISTED");
        
        RfProduct product = rfProductService.getOne(queryWrapper);
        
        // 填充用户信息
        if (product != null && product.getUserId() != null) {
            SysUser userInfo = sysUserService.getById(product.getUserId());
            if (userInfo != null) {
                // 清空敏感信息
                userInfo.setPassword(null);
                userInfo.setWechatOpenId(null);
                userInfo.setGoogleSub(null);
                userInfo.setAppleSub(null);
                product.setUserInfo(userInfo);
            }
        }
        
        return product;
    }
} 