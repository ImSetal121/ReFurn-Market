-- 用户商品浏览记录表
CREATE TABLE rf_user_product_browse_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    browse_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- 创建时间和更新时间
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- 外键约束
    CONSTRAINT fk_browse_history_user FOREIGN KEY (user_id) REFERENCES sys_user(id),
    CONSTRAINT fk_browse_history_product FOREIGN KEY (product_id) REFERENCES rf_product(id)
);

-- 创建索引
-- 用户ID索引，用于查询用户的浏览记录
CREATE INDEX idx_browse_history_user_id ON rf_user_product_browse_history(user_id);

-- 商品ID索引，用于查询商品的浏览记录
CREATE INDEX idx_browse_history_product_id ON rf_user_product_browse_history(product_id);

-- 浏览时间索引，用于按时间排序
CREATE INDEX idx_browse_history_browse_time ON rf_user_product_browse_history(browse_time DESC);

-- 用户ID和浏览时间组合索引，用于查询用户的浏览历史（按时间倒序）
CREATE INDEX idx_browse_history_user_time ON rf_user_product_browse_history(user_id, browse_time DESC);

-- 用户ID和商品ID组合索引，用于查询用户是否浏览过某个商品
CREATE INDEX idx_browse_history_user_product ON rf_user_product_browse_history(user_id, product_id);

-- 软删除索引，用于过滤已删除的记录
CREATE INDEX idx_browse_history_is_delete ON rf_user_product_browse_history(is_delete);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_browse_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器，在更新记录时自动更新update_time字段
CREATE TRIGGER trigger_update_browse_history_updated_at
    BEFORE UPDATE ON rf_user_product_browse_history
    FOR EACH ROW
    EXECUTE FUNCTION update_browse_history_updated_at();

-- 添加表注释
COMMENT ON TABLE rf_user_product_browse_history IS '用户商品浏览记录表';
COMMENT ON COLUMN rf_user_product_browse_history.id IS '主键';
COMMENT ON COLUMN rf_user_product_browse_history.user_id IS '用户ID';
COMMENT ON COLUMN rf_user_product_browse_history.product_id IS '商品ID';
COMMENT ON COLUMN rf_user_product_browse_history.browse_time IS '浏览时间';
COMMENT ON COLUMN rf_user_product_browse_history.is_delete IS '是否删除';
COMMENT ON COLUMN rf_user_product_browse_history.create_time IS '创建时间';
COMMENT ON COLUMN rf_user_product_browse_history.update_time IS '更新时间'; 