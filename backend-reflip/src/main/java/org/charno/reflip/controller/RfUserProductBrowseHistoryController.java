package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfUserProductBrowseHistory;
import org.charno.reflip.service.IRfUserProductBrowseHistoryService;
import org.charno.common.core.R;
import org.charno.common.utils.SecurityUtils;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import java.util.List;

/**
 * 用户商品浏览记录控制器
 */
@RestController
@RequestMapping("/api/browse-history")
public class RfUserProductBrowseHistoryController {

    @Autowired
    private IRfUserProductBrowseHistoryService rfUserProductBrowseHistoryService;

    /**
     * 记录用户浏览商品
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    @PostMapping("/record/{productId}")
    public R<String> recordBrowseHistory(@PathVariable Long productId) {
        try {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return R.fail("User not logged in");
            }

            boolean success = rfUserProductBrowseHistoryService.recordBrowseHistory(userId, productId);
            if (success) {
                return R.ok("Browse history recorded successfully");
            } else {
                return R.fail("Failed to record browse history");
            }
        } catch (Exception e) {
            return R.fail("Failed to record browse history: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户的浏览历史（分页）
     * 
     * @param page 页码 (默认1)
     * @param size 每页大小 (默认10)
     * @return 浏览历史分页数据
     */
    @GetMapping("/list")
    public R<Page<RfUserProductBrowseHistory>> getUserBrowseHistory(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return R.fail("User not logged in");
            }

            Page<RfUserProductBrowseHistory> result = rfUserProductBrowseHistoryService.getUserBrowseHistory(userId,
                    page, size);
            return R.ok(result, "Browse history retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve browse history: " + e.getMessage());
        }
    }

    /**
     * 获取当前用户最近浏览的商品
     * 
     * @param limit 限制数量 (默认10)
     * @return 最近浏览的商品列表
     */
    @GetMapping("/recent")
    public R<List<RfUserProductBrowseHistory>> getRecentBrowseHistory(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return R.fail("User not logged in");
            }

            List<RfUserProductBrowseHistory> result = rfUserProductBrowseHistoryService.getRecentBrowseHistory(userId,
                    limit);
            return R.ok(result, "Recent browse history retrieved successfully");
        } catch (Exception e) {
            return R.fail("Failed to retrieve recent browse history: " + e.getMessage());
        }
    }

    /**
     * 删除特定商品的浏览记录
     * 
     * @param productId 商品ID
     * @return 操作结果
     */
    @DeleteMapping("/delete/{productId}")
    public R<String> deleteBrowseHistory(@PathVariable Long productId) {
        try {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return R.fail("User not logged in");
            }

            boolean success = rfUserProductBrowseHistoryService.deleteBrowseHistory(userId, productId);
            if (success) {
                return R.ok("Browse history deleted successfully");
            } else {
                return R.fail("Failed to delete browse history");
            }
        } catch (Exception e) {
            return R.fail("Failed to delete browse history: " + e.getMessage());
        }
    }

    /**
     * 清空当前用户的所有浏览历史
     * 
     * @return 操作结果
     */
    @DeleteMapping("/clear")
    public R<String> clearUserBrowseHistory() {
        try {
            Long userId = SecurityUtils.getUserId();
            if (userId == null) {
                return R.fail("User not logged in");
            }

            boolean success = rfUserProductBrowseHistoryService.clearUserBrowseHistory(userId);
            if (success) {
                return R.ok("Browse history cleared successfully");
            } else {
                return R.fail("Failed to clear browse history");
            }
        } catch (Exception e) {
            return R.fail("Failed to clear browse history: " + e.getMessage());
        }
    }
}