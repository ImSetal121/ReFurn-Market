package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfBalanceDetail;
import org.charno.reflip.service.IRfBalanceDetailService;
import org.charno.common.core.R;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 余额明细控制器
 */
@RestController
@RequestMapping("/api/rf/balance-detail")
public class RfBalanceDetailController {

    @Autowired
    private IRfBalanceDetailService rfBalanceDetailService;

    /**
     * 创建余额明细记录（自动维护双链表）
     */
    @PostMapping("/create")
    public R<Boolean> createBalanceDetail(@RequestBody RfBalanceDetail rfBalanceDetail) {
        boolean result = rfBalanceDetailService.createBalanceDetail(rfBalanceDetail);
        return result ? R.ok(result) : R.fail("创建失败");
    }

    /**
     * 根据ID删除余额明细
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfBalanceDetailService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除余额明细
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfBalanceDetailService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新余额明细
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfBalanceDetail rfBalanceDetail) {
        boolean result = rfBalanceDetailService.updateById(rfBalanceDetail);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询余额明细
     */
    @GetMapping("/{id}")
    public R<RfBalanceDetail> getById(@PathVariable Long id) {
        RfBalanceDetail rfBalanceDetail = rfBalanceDetailService.getById(id);
        return R.ok(rfBalanceDetail);
    }

    /**
     * 根据用户ID查询余额明细
     */
    @GetMapping("/user/{userId}")
    public R<List<RfBalanceDetail>> getByUserId(@PathVariable Long userId) {
        List<RfBalanceDetail> result = rfBalanceDetailService.getByUserId(userId);
        return R.ok(result);
    }

    /**
     * 分页查询用户余额明细
     */
    @GetMapping("/user/{userId}/page")
    public R<Page<RfBalanceDetail>> getByUserIdPage(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<RfBalanceDetail> page = new Page<>(current, size);
        Page<RfBalanceDetail> result = rfBalanceDetailService.getByUserIdPage(page, userId);
        return R.ok(result);
    }

    /**
     * 根据用户ID和交易类型查询余额明细
     */
    @GetMapping("/user/{userId}/type/{transactionType}")
    public R<List<RfBalanceDetail>> getByUserIdAndType(
            @PathVariable Long userId, 
            @PathVariable String transactionType) {
        List<RfBalanceDetail> result = rfBalanceDetailService.getByUserIdAndType(userId, transactionType);
        return R.ok(result);
    }

    /**
     * 根据时间范围查询用户余额明细
     */
    @GetMapping("/user/{userId}/time-range")
    public R<List<RfBalanceDetail>> getByUserIdAndTimeRange(
            @PathVariable Long userId,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startTime,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endTime) {
        List<RfBalanceDetail> result = rfBalanceDetailService.getByUserIdAndTimeRange(userId, startTime, endTime);
        return R.ok(result);
    }

    /**
     * 获取用户最新的余额明细记录
     */
    @GetMapping("/user/{userId}/latest")
    public R<RfBalanceDetail> getLatestByUserId(@PathVariable Long userId) {
        RfBalanceDetail result = rfBalanceDetailService.getLatestByUserId(userId);
        return R.ok(result);
    }

    /**
     * 获取用户当前余额
     */
    @GetMapping("/user/{userId}/current-balance")
    public R<BigDecimal> getCurrentBalance(@PathVariable Long userId) {
        BigDecimal balance = rfBalanceDetailService.getCurrentBalance(userId);
        return R.ok(balance);
    }

    /**
     * 根据交易类型统计用户总金额
     */
    @GetMapping("/user/{userId}/sum/{transactionType}")
    public R<BigDecimal> sumAmountByUserIdAndType(
            @PathVariable Long userId, 
            @PathVariable String transactionType) {
        BigDecimal sum = rfBalanceDetailService.sumAmountByUserIdAndType(userId, transactionType);
        return R.ok(sum);
    }

    /**
     * 获取上一条明细记录
     */
    @GetMapping("/{detailId}/prev")
    public R<RfBalanceDetail> getPrevDetail(@PathVariable Long detailId) {
        RfBalanceDetail result = rfBalanceDetailService.getPrevDetail(detailId);
        return R.ok(result);
    }

    /**
     * 获取下一条明细记录
     */
    @GetMapping("/{detailId}/next")
    public R<RfBalanceDetail> getNextDetail(@PathVariable Long detailId) {
        RfBalanceDetail result = rfBalanceDetailService.getNextDetail(detailId);
        return R.ok(result);
    }

    /**
     * 分页条件查询余额明细
     */
    @GetMapping("/page")
    public R<Page<RfBalanceDetail>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfBalanceDetail condition) {
        Page<RfBalanceDetail> page = new Page<>(current, size);
        Page<RfBalanceDetail> result = rfBalanceDetailService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询余额明细
     */
    @GetMapping("/list")
    public R<List<RfBalanceDetail>> selectListWithCondition(RfBalanceDetail condition) {
        List<RfBalanceDetail> result = rfBalanceDetailService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有余额明细
     */
    @GetMapping("/all")
    public R<List<RfBalanceDetail>> list() {
        List<RfBalanceDetail> result = rfBalanceDetailService.list();
        return R.ok(result);
    }
} 