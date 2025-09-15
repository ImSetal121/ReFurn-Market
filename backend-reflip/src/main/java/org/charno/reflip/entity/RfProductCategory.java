package org.charno.reflip.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

/**
 * 商品分类实体
 */
@Data
@TableName("rf_product_category")
public class RfProductCategory {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String name;
    
    @TableLogic
    private Boolean isDelete;
} 