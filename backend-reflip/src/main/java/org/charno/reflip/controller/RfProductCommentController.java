package org.charno.reflip.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.reflip.entity.RfProductComment;
import org.charno.reflip.service.IRfProductCommentService;
import org.charno.common.core.R;

import java.util.List;

/**
 * 商品留言控制器
 */
@RestController
@RequestMapping("/api/rf/product-comment")
public class RfProductCommentController {

    @Autowired
    private IRfProductCommentService rfProductCommentService;

    /**
     * 新增商品留言
     */
    @PostMapping
    public R<Boolean> save(@RequestBody RfProductComment rfProductComment) {
        boolean result = rfProductCommentService.save(rfProductComment);
        return result ? R.ok(result) : R.fail("新增失败");
    }

    /**
     * 根据ID删除商品留言
     */
    @DeleteMapping("/{id}")
    public R<Boolean> removeById(@PathVariable Long id) {
        boolean result = rfProductCommentService.removeById(id);
        return result ? R.ok(result) : R.fail("删除失败");
    }

    /**
     * 批量删除商品留言
     */
    @DeleteMapping("/batch")
    public R<Boolean> removeByIds(@RequestBody List<Long> ids) {
        boolean result = rfProductCommentService.removeByIds(ids);
        return result ? R.ok(result) : R.fail("批量删除失败");
    }

    /**
     * 更新商品留言
     */
    @PutMapping
    public R<Boolean> updateById(@RequestBody RfProductComment rfProductComment) {
        boolean result = rfProductCommentService.updateById(rfProductComment);
        return result ? R.ok(result) : R.fail("更新失败");
    }

    /**
     * 根据ID查询商品留言
     */
    @GetMapping("/{id}")
    public R<RfProductComment> getById(@PathVariable Long id) {
        RfProductComment rfProductComment = rfProductCommentService.getById(id);
        return R.ok(rfProductComment);
    }

    /**
     * 分页条件查询商品留言
     */
    @GetMapping("/page")
    public R<Page<RfProductComment>> selectPageWithCondition(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            RfProductComment condition) {
        Page<RfProductComment> page = new Page<>(current, size);
        Page<RfProductComment> result = rfProductCommentService.selectPageWithCondition(page, condition);
        return R.ok(result);
    }

    /**
     * 不分页条件查询商品留言
     */
    @GetMapping("/list")
    public R<List<RfProductComment>> selectListWithCondition(RfProductComment condition) {
        List<RfProductComment> result = rfProductCommentService.selectListWithCondition(condition);
        return R.ok(result);
    }

    /**
     * 查询所有商品留言
     */
    @GetMapping("/all")
    public R<List<RfProductComment>> list() {
        List<RfProductComment> result = rfProductCommentService.list();
        return R.ok(result);
    }
} 