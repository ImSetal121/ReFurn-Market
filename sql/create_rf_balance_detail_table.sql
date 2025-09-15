-- 余额明细表(rf_balance_detail)
CREATE TABLE rf_balance_detail (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    prev_detail_id BIGINT NULL,
    next_detail_id BIGINT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_before DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    description VARCHAR(500),
    transaction_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_delete BOOLEAN DEFAULT FALSE,
    
    -- 添加约束
    CONSTRAINT chk_amount_positive CHECK (amount != 0),
    CONSTRAINT chk_balance_non_negative CHECK (balance_before >= 0 AND balance_after >= 0)
);

-- 创建索引
CREATE INDEX idx_rf_balance_detail_user_id ON rf_balance_detail(user_id);
CREATE INDEX idx_rf_balance_detail_user_time ON rf_balance_detail(user_id, transaction_time);
CREATE INDEX idx_rf_balance_detail_transaction_type ON rf_balance_detail(transaction_type);
CREATE INDEX idx_rf_balance_detail_transaction_time ON rf_balance_detail(transaction_time);
CREATE INDEX idx_rf_balance_detail_prev ON rf_balance_detail(prev_detail_id);
CREATE INDEX idx_rf_balance_detail_next ON rf_balance_detail(next_detail_id);

-- 添加表注释
COMMENT ON TABLE rf_balance_detail IS '用户余额明细表，采用双链表结构记录用户余额变动历史';
COMMENT ON COLUMN rf_balance_detail.id IS '主键';
COMMENT ON COLUMN rf_balance_detail.user_id IS '用户ID';
COMMENT ON COLUMN rf_balance_detail.prev_detail_id IS '上一个明细ID（双链表前指针）';
COMMENT ON COLUMN rf_balance_detail.next_detail_id IS '下一个明细ID（双链表后指针）';
COMMENT ON COLUMN rf_balance_detail.transaction_type IS '交易类型：RECHARGE-充值，WITHDRAWAL-提现，CONSUMPTION-消费，REFUND-退款，COMMISSION-佣金收入，REWARD-平台奖励';
COMMENT ON COLUMN rf_balance_detail.amount IS '交易金额';
COMMENT ON COLUMN rf_balance_detail.balance_before IS '交易前余额';
COMMENT ON COLUMN rf_balance_detail.balance_after IS '交易后余额';
COMMENT ON COLUMN rf_balance_detail.description IS '交易描述';
COMMENT ON COLUMN rf_balance_detail.transaction_time IS '交易时间';
COMMENT ON COLUMN rf_balance_detail.create_time IS '创建时间';
COMMENT ON COLUMN rf_balance_detail.update_time IS '更新时间';
COMMENT ON COLUMN rf_balance_detail.is_delete IS '是否删除';

-- 创建触发器函数，用于自动更新update_time
CREATE OR REPLACE FUNCTION update_rf_balance_detail_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 创建触发器
CREATE TRIGGER trigger_rf_balance_detail_updated_at
    BEFORE UPDATE ON rf_balance_detail
    FOR EACH ROW
    EXECUTE FUNCTION update_rf_balance_detail_updated_at(); 