-- ReFlip APP 业务实体建表语句
-- 数据库: PostgreSQL

-- 商品品类表
CREATE TABLE rf_product_category (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT uk_product_category_name UNIQUE (name)
);

-- 商品表
CREATE TABLE rf_product (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id BIGINT,
    category_name VARCHAR(255),
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    description TEXT,
    image_url_json TEXT,
    is_auction BOOLEAN DEFAULT FALSE,
    is_self_pickup BOOLEAN DEFAULT FALSE,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES rf_product_category(id)
);

-- 仓库表
CREATE TABLE rf_warehouse (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    monthly_warehouse_cost DECIMAL(10,2),
    status VARCHAR(50) DEFAULT '启用',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT chk_warehouse_status CHECK (status IN ('启用', '停用'))
);

-- 商品出售记录表
CREATE TABLE rf_product_sell_record (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    seller_user_id BIGINT NOT NULL,
    buyer_user_id BIGINT,
    final_product_price DECIMAL(10,2),
    is_auction BOOLEAN DEFAULT FALSE,
    product_warehouse_shipment_id BIGINT,
    is_self_pickup BOOLEAN DEFAULT FALSE,
    product_self_pickup_logistics_id BIGINT,
    buyer_receipt_image_url_json TEXT,
    seller_return_image_url_json TEXT,
    status VARCHAR(50) DEFAULT '待发货',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_sell_record_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_sell_record_seller FOREIGN KEY (seller_user_id) REFERENCES sys_user(id),
    CONSTRAINT fk_sell_record_buyer FOREIGN KEY (buyer_user_id) REFERENCES sys_user(id),
    CONSTRAINT chk_sell_record_status CHECK (status IN ('待发货', '待收货', '已完成', '发起退货', '退回仓库', '退回卖家', '已退回'))
);

-- 商品退货记录表
CREATE TABLE rf_product_return_record (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT NOT NULL,
    return_reason_type VARCHAR(100),
    return_reason_detail TEXT,
    audit_result VARCHAR(50),
    audit_detail TEXT,
    freight_bearer VARCHAR(50),
    freight_bearer_user_id BIGINT,
    need_compensate_product BOOLEAN DEFAULT FALSE,
    compensation_bearer VARCHAR(50),
    compensation_bearer_user_id BIGINT,
    is_auction BOOLEAN DEFAULT FALSE,
    is_use_logistics_service BOOLEAN DEFAULT FALSE,
    appointment_pickup_time TIMESTAMP,
    internal_logistics_task_id BIGINT,
    external_logistics_service_name VARCHAR(255),
    external_logistics_order_number VARCHAR(255),
    status VARCHAR(50) DEFAULT '发起退货',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_return_record_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_return_record_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_return_record_freight_bearer_user FOREIGN KEY (freight_bearer_user_id) REFERENCES sys_user(id),
    CONSTRAINT fk_return_record_compensation_bearer_user FOREIGN KEY (compensation_bearer_user_id) REFERENCES sys_user(id),
    CONSTRAINT chk_return_audit_result CHECK (audit_result IN ('拒绝', '同意')),
    CONSTRAINT chk_return_freight_bearer CHECK (freight_bearer IN ('卖方', '买方', '平台')),
    CONSTRAINT chk_return_compensation_bearer CHECK (compensation_bearer IN ('卖方', '买方', '平台')),
    CONSTRAINT chk_return_status CHECK (status IN ('发起退货', '退回仓库', '退回卖家', '已退回'))
);

-- 商品寄卖物流记录表
CREATE TABLE rf_product_auction_logistics (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    pickup_address TEXT,
    warehouse_id BIGINT,
    warehouse_address TEXT,
    is_use_logistics_service BOOLEAN DEFAULT FALSE,
    appointment_pickup_time TIMESTAMP,
    internal_logistics_task_id BIGINT,
    external_logistics_service_name VARCHAR(255),
    external_logistics_order_number VARCHAR(255),
    status VARCHAR(50) DEFAULT '待上门',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_auction_logistics_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_auction_logistics_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_auction_logistics_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT chk_auction_logistics_status CHECK (status IN ('待上门', '待入库', '已入库'))
);

-- 商品仓库发货记录表
CREATE TABLE rf_product_warehouse_shipment (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    warehouse_address TEXT,
    buyer_receipt_address TEXT,
    shipment_time TIMESTAMP,
    internal_logistics_task_id BIGINT,
    shipment_image_url_json TEXT,
    status VARCHAR(50) DEFAULT '待出库',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_shipment_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_shipment_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_warehouse_shipment_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT chk_warehouse_shipment_status CHECK (status IN ('待出库', '待收货', '已签收'))
);

-- 商品自提物流记录表
CREATE TABLE rf_product_self_pickup_logistics (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT NOT NULL,
    pickup_address TEXT,
    buyer_receipt_address TEXT,
    external_logistics_service_name VARCHAR(255),
    external_logistics_order_number VARCHAR(255),
    status VARCHAR(50) DEFAULT '已发货',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_self_pickup_logistics_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_self_pickup_logistics_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT chk_self_pickup_logistics_status CHECK (status IN ('已发货', '已签收'))
);

-- 仓库入库申请表
CREATE TABLE rf_warehouse_in_apply (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    source VARCHAR(50),
    apply_quantity INTEGER DEFAULT 1,
    apply_time TIMESTAMP,
    product_image_url_json TEXT,
    audit_result VARCHAR(50),
    audit_detail TEXT,
    status VARCHAR(50) DEFAULT '待审批',
    warehouse_in_id BIGINT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_in_apply_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT fk_warehouse_in_apply_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_in_apply_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT chk_warehouse_in_apply_source CHECK (source IN ('卖方寄卖', '买房退货')),
    CONSTRAINT chk_warehouse_in_apply_audit_result CHECK (audit_result IN ('批准入库', '拒绝入库')),
    CONSTRAINT chk_warehouse_in_apply_status CHECK (status IN ('待审批', '已审批'))
);

-- 仓库入库表
CREATE TABLE rf_warehouse_in (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    in_quantity INTEGER DEFAULT 1,
    in_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    stock_position VARCHAR(255),
    product_image_url_json TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_in_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT fk_warehouse_in_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_in_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id)
);

-- 仓库出库表
CREATE TABLE rf_warehouse_out (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    stock_position VARCHAR(255),
    out_quantity INTEGER DEFAULT 1,
    out_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_image_url_json TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_out_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT fk_warehouse_out_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_out_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id)
);

-- 仓库库存表
CREATE TABLE rf_warehouse_stock (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    stock_position VARCHAR(255),
    warehouse_in_apply_id BIGINT,
    warehouse_in_id BIGINT,
    in_time TIMESTAMP,
    warehouse_out_id BIGINT,
    out_time TIMESTAMP,
    status VARCHAR(50) DEFAULT '库存中',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_stock_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT fk_warehouse_stock_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_stock_in_apply FOREIGN KEY (warehouse_in_apply_id) REFERENCES rf_warehouse_in_apply(id),
    CONSTRAINT fk_warehouse_stock_in FOREIGN KEY (warehouse_in_id) REFERENCES rf_warehouse_in(id),
    CONSTRAINT fk_warehouse_stock_out FOREIGN KEY (warehouse_out_id) REFERENCES rf_warehouse_out(id),
    CONSTRAINT chk_warehouse_stock_status CHECK (status IN ('库存中', '已出库'))
);

-- 仓储费用表
CREATE TABLE rf_warehouse_cost (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    cost_type VARCHAR(100),
    cost DECIMAL(10,2),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_warehouse_cost_warehouse FOREIGN KEY (warehouse_id) REFERENCES rf_warehouse(id),
    CONSTRAINT fk_warehouse_cost_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_warehouse_cost_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id)
);

-- 内部物流任务表
CREATE TABLE rf_internal_logistics_task (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    task_type VARCHAR(50),
    logistics_user_id BIGINT,
    source_address TEXT,
    source_address_image_url_json TEXT,
    target_address TEXT,
    target_address_image_url_json TEXT,
    logistics_cost DECIMAL(10,2),
    status VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_internal_logistics_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_internal_logistics_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_internal_logistics_user FOREIGN KEY (logistics_user_id) REFERENCES sys_user(id),
    CONSTRAINT chk_internal_logistics_task_type CHECK (task_type IN ('上门取货', '仓库发货', '商品退货'))
);

-- 账单项表
CREATE TABLE rf_bill_item (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    cost_type VARCHAR(50),
    cost_description TEXT,
    cost DECIMAL(10,2),
    pay_subject VARCHAR(100),
    is_platform_pay BOOLEAN DEFAULT FALSE,
    pay_user_id BIGINT,
    status VARCHAR(50),
    pay_time TIMESTAMP,
    payment_record_id BIGINT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_bill_item_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_bill_item_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_bill_item_pay_user FOREIGN KEY (pay_user_id) REFERENCES sys_user(id),
    CONSTRAINT chk_bill_item_cost_type CHECK (cost_type IN ('商品费用', '仓储费用', '物流费用', '上门安装费用', '服务费用'))
);

-- 支付记录表
CREATE TABLE rf_payment_record (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_sell_record_id BIGINT,
    pay_subject VARCHAR(100),
    is_platform_pay BOOLEAN DEFAULT FALSE,
    pay_user_id BIGINT,
    payment_method VARCHAR(50),
    payment_amount DECIMAL(10,2),
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_proof TEXT,
    payment_status VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_payment_record_product FOREIGN KEY (product_id) REFERENCES rf_product(id),
    CONSTRAINT fk_payment_record_sell_record FOREIGN KEY (product_sell_record_id) REFERENCES rf_product_sell_record(id),
    CONSTRAINT fk_payment_record_pay_user FOREIGN KEY (pay_user_id) REFERENCES sys_user(id)
);

-- 聊天消息表
CREATE TABLE chat_message (
    id BIGSERIAL PRIMARY KEY,
    sender_user_id BIGINT NOT NULL,
    receiver_user_id BIGINT NOT NULL,
    message_type VARCHAR(50),
    message_content TEXT,
    send_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_chat_message_sender FOREIGN KEY (sender_user_id) REFERENCES sys_user(id),
    CONSTRAINT fk_chat_message_receiver FOREIGN KEY (receiver_user_id) REFERENCES sys_user(id),
    CONSTRAINT chk_chat_message_type CHECK (message_type IN ('文本', '图片url', '视频url', '商品链接'))
);

-- 添加外键约束（延迟添加以避免循环依赖）
ALTER TABLE rf_product_sell_record 
ADD CONSTRAINT fk_sell_record_warehouse_shipment 
FOREIGN KEY (product_warehouse_shipment_id) REFERENCES rf_product_warehouse_shipment(id);

ALTER TABLE rf_product_sell_record 
ADD CONSTRAINT fk_sell_record_self_pickup_logistics 
FOREIGN KEY (product_self_pickup_logistics_id) REFERENCES rf_product_self_pickup_logistics(id);

ALTER TABLE rf_product_return_record 
ADD CONSTRAINT fk_return_record_internal_logistics 
FOREIGN KEY (internal_logistics_task_id) REFERENCES rf_internal_logistics_task(id);

ALTER TABLE rf_product_auction_logistics 
ADD CONSTRAINT fk_auction_logistics_internal_logistics 
FOREIGN KEY (internal_logistics_task_id) REFERENCES rf_internal_logistics_task(id);

ALTER TABLE rf_product_warehouse_shipment 
ADD CONSTRAINT fk_warehouse_shipment_internal_logistics 
FOREIGN KEY (internal_logistics_task_id) REFERENCES rf_internal_logistics_task(id);

ALTER TABLE rf_warehouse_in_apply 
ADD CONSTRAINT fk_warehouse_in_apply_warehouse_in 
FOREIGN KEY (warehouse_in_id) REFERENCES rf_warehouse_in(id);

ALTER TABLE rf_bill_item 
ADD CONSTRAINT fk_bill_item_payment_record 
FOREIGN KEY (payment_record_id) REFERENCES rf_payment_record(id);

-- 创建索引
CREATE INDEX idx_product_category_id ON rf_product(category_id);
CREATE INDEX idx_product_is_delete ON rf_product(is_delete);
CREATE INDEX idx_sell_record_product_id ON rf_product_sell_record(product_id);
CREATE INDEX idx_sell_record_seller_user_id ON rf_product_sell_record(seller_user_id);
CREATE INDEX idx_sell_record_buyer_user_id ON rf_product_sell_record(buyer_user_id);
CREATE INDEX idx_sell_record_status ON rf_product_sell_record(status);
CREATE INDEX idx_warehouse_stock_warehouse_id ON rf_warehouse_stock(warehouse_id);
CREATE INDEX idx_warehouse_stock_product_id ON rf_warehouse_stock(product_id);
CREATE INDEX idx_chat_message_sender_receiver ON chat_message(sender_user_id, receiver_user_id);
CREATE INDEX idx_chat_message_send_time ON chat_message(send_time);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_time_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要自动更新update_time的表创建触发器
CREATE TRIGGER update_rf_product_updated_time BEFORE UPDATE ON rf_product FOR EACH ROW EXECUTE FUNCTION update_updated_time_column();
CREATE TRIGGER update_rf_product_category_updated_time BEFORE UPDATE ON rf_product_category FOR EACH ROW EXECUTE FUNCTION update_updated_time_column();
CREATE TRIGGER update_rf_product_sell_record_updated_time BEFORE UPDATE ON rf_product_sell_record FOR EACH ROW EXECUTE FUNCTION update_updated_time_column();
CREATE TRIGGER update_rf_warehouse_updated_time BEFORE UPDATE ON rf_warehouse FOR EACH ROW EXECUTE FUNCTION update_updated_time_column(); 