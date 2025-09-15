package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;
import org.charno.reflip.entity.RfProductCategory;
import org.charno.reflip.mapper.RfProductCategoryMapper;
import org.charno.reflip.service.IRfProductCategoryService;
import java.util.List;

/**
 * 商品分类业务实现类
 */
@Service
public class RfProductCategoryServiceImpl extends ServiceImpl<RfProductCategoryMapper, RfProductCategory> implements IRfProductCategoryService {

    @Override
    public Page<RfProductCategory> selectPageWithCondition(Page<RfProductCategory> page, RfProductCategory condition) {
        LambdaQueryWrapper<RfProductCategory> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfProductCategory::getName, condition.getName());
            }
        }
        
        return this.page(page, queryWrapper);
    }

    @Override
    public List<RfProductCategory> selectListWithCondition(RfProductCategory condition) {
        LambdaQueryWrapper<RfProductCategory> queryWrapper = new LambdaQueryWrapper<>();
        
        if (condition != null) {
            if (condition.getName() != null && !condition.getName().isEmpty()) {
                queryWrapper.like(RfProductCategory::getName, condition.getName());
            }
        }
        
        return this.list(queryWrapper);
    }
} 