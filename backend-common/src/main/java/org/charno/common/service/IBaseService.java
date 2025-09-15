package org.charno.common.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;

public interface IBaseService<T> extends IService<T> {
    /**
     * 分页条件查询
     * 
     * @param page    分页参数
     * @param wrapper 查询条件
     * @return 分页结果
     */
    default Page<T> pageQuery(Page<T> page, QueryWrapper<T> wrapper) {
        return page(page, wrapper);
    }

    /**
     * 条件查询（不分页）
     * 
     * @param wrapper 查询条件
     * @return 查询结果列表
     */
    default java.util.List<T> listQuery(QueryWrapper<T> wrapper) {
        return list(wrapper);
    }
}
