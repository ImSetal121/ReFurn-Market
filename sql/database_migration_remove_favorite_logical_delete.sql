-- 移除用户收藏商品表的逻辑删除功能
-- 删除重复记录，只保留最新的记录，然后移除is_delete列

-- 1. 首先备份表（可选）
-- CREATE TABLE rf_user_favorite_product_backup AS SELECT * FROM rf_user_favorite_product;

-- 2. 删除已标记为删除的记录
DELETE FROM rf_user_favorite_product WHERE is_delete = true;

-- 3. 对于每个用户-商品组合，只保留最新的记录（以防有重复）
DELETE FROM rf_user_favorite_product a
WHERE a.id NOT IN (
    SELECT MAX(b.id)
    FROM rf_user_favorite_product b
    WHERE b.user_id = a.user_id 
    AND b.product_id = a.product_id
    GROUP BY b.user_id, b.product_id
);

-- 4. 移除is_delete列
ALTER TABLE rf_user_favorite_product DROP COLUMN IF EXISTS is_delete;

-- 5. 验证结果
SELECT COUNT(*) as total_records FROM rf_user_favorite_product;
SELECT user_id, product_id, COUNT(*) as count 
FROM rf_user_favorite_product 
GROUP BY user_id, product_id 
HAVING COUNT(*) > 1; 