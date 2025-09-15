-- 用户地址表
CREATE TABLE rf_user_address (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    receiver_name VARCHAR(50) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    province VARCHAR(20) NOT NULL,
    city VARCHAR(20) NOT NULL,
    district VARCHAR(20) NOT NULL,
    detail_address VARCHAR(255) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE
);

-- 创建索引
CREATE INDEX idx_rf_user_address_user_id ON rf_user_address(user_id);
CREATE INDEX idx_rf_user_address_is_default ON rf_user_address(is_default);
CREATE INDEX idx_rf_user_address_is_delete ON rf_user_address(is_delete);

-- 添加注释
COMMENT ON TABLE rf_user_address IS '用户地址表';
COMMENT ON COLUMN rf_user_address.id IS '主键';
COMMENT ON COLUMN rf_user_address.user_id IS '用户ID';
COMMENT ON COLUMN rf_user_address.receiver_name IS '收货人姓名';
COMMENT ON COLUMN rf_user_address.receiver_phone IS '收货人电话';
COMMENT ON COLUMN rf_user_address.province IS '省份';
COMMENT ON COLUMN rf_user_address.city IS '城市';
COMMENT ON COLUMN rf_user_address.district IS '区县';
COMMENT ON COLUMN rf_user_address.detail_address IS '详细地址';
COMMENT ON COLUMN rf_user_address.is_default IS '是否默认地址';
COMMENT ON COLUMN rf_user_address.create_time IS '创建时间';
COMMENT ON COLUMN rf_user_address.update_time IS '更新时间';
COMMENT ON COLUMN rf_user_address.is_delete IS '是否删除'; 