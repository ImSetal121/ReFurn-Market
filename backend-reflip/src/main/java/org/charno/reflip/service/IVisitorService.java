package org.charno.reflip.service;

import org.charno.reflip.entity.RfProduct;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import java.util.List;

/**
 * 访客业务接口
 */
public interface IVisitorService {
    
    /**
     * 搜索商品
     * 支持多条件查询和分页
     * 
     * @param keyword 搜索关键词
     * @param type 商品类型
     * @param category 商品类别
     * @param minPrice 最低价格
     * @param maxPrice 最高价格
     * @param sortBy 排序方式
     * @param page 页码
     * @param size 每页大小
     * @return 分页搜索结果
     */
    Page<RfProduct> searchProducts(String keyword, String type, String category, 
                                 Double minPrice, Double maxPrice, String sortBy, 
                                 Integer page, Integer size);

    /**
     * 获取热门搜索关键词
     * 
     * @return 热门关键词列表
     */
    List<String> getHotKeywords();

    /**
     * 获取商品详情
     * 
     * @param productId 商品ID
     * @return 商品详情
     */
    RfProduct getProductDetail(Long productId);
} 