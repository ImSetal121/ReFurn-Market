package org.charno.reflip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.charno.common.service.IBaseService;
import org.charno.reflip.entity.RfUserProductBrowseHistory;
import java.util.List;

/**
 * 用户商品浏览记录业务接口
 */
public interface IRfUserProductBrowseHistoryService extends IBaseService<RfUserProductBrowseHistory> {

    /**
     * 分页条件查询
     */
    Page<RfUserProductBrowseHistory> selectPageWithCondition(Page<RfUserProductBrowseHistory> page,
            RfUserProductBrowseHistory condition);

    /**
     * 不分页条件查询
     */
    List<RfUserProductBrowseHistory> selectListWithCondition(RfUserProductBrowseHistory condition);

    /**
     * 记录用户浏览商品
     * 
     * @param userId    用户ID
     * @param productId 商品ID
     * @return 是否记录成功
     */
    boolean recordBrowseHistory(Long userId, Long productId);

    /**
     * 获取用户浏览历史（分页）
     * 
     * @param userId 用户ID
     * @param page   页码
     * @param size   每页大小
     * @return 浏览历史分页数据
     */
    Page<RfUserProductBrowseHistory> getUserBrowseHistory(Long userId, Integer page, Integer size);

    /**
     * 获取用户最近浏览的商品
     * 
     * @param userId 用户ID
     * @param limit  限制数量
     * @return 最近浏览的商品列表
     */
    List<RfUserProductBrowseHistory> getRecentBrowseHistory(Long userId, Integer limit);

    /**
     * 删除用户浏览记录
     * 
     * @param userId    用户ID
     * @param productId 商品ID（可选，如果为空则删除该用户所有记录）
     * @return 是否删除成功
     */
    boolean deleteBrowseHistory(Long userId, Long productId);

    /**
     * 清空用户浏览历史
     * 
     * @param userId 用户ID
     * @return 是否清空成功
     */
    boolean clearUserBrowseHistory(Long userId);
}