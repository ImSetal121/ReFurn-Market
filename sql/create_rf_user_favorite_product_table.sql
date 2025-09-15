-- 创建用户收藏商品表
CREATE TABLE rf_user_favorite_product (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    favorite_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- 创建唯一约束，防止用户重复收藏同一商品
    CONSTRAINT uk_user_product_favorite UNIQUE (user_id, product_id)
    
    -- 外键约束（如果需要的话，可以根据实际情况启用）
    -- CONSTRAINT fk_user_favorite_user FOREIGN KEY (user_id) REFERENCES sys_user(id),
    -- CONSTRAINT fk_user_favorite_product FOREIGN KEY (product_id) REFERENCES rf_product(id)
);

-- 创建索引以提升查询性能
CREATE INDEX idx_rf_user_favorite_product_user_id ON rf_user_favorite_product(user_id);
CREATE INDEX idx_rf_user_favorite_product_product_id ON rf_user_favorite_product(product_id);
CREATE INDEX idx_rf_user_favorite_product_favorite_time ON rf_user_favorite_product(favorite_time);

-- 添加表注释
COMMENT ON TABLE rf_user_favorite_product IS '用户收藏商品表';
COMMENT ON COLUMN rf_user_favorite_product.id IS '主键';
COMMENT ON COLUMN rf_user_favorite_product.user_id IS '用户ID';
COMMENT ON COLUMN rf_user_favorite_product.product_id IS '商品ID';
COMMENT ON COLUMN rf_user_favorite_product.favorite_time IS '收藏时间';
COMMENT ON COLUMN rf_user_favorite_product.is_delete IS '是否删除'; 