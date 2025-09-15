package org.charno.reflip.service;

/**
 * 仓库服务接口
 */
public interface IWarehouseService {
    
    /**
     * 商品入库
     * @param productId 商品ID
     * @param inType 入库类型
     * @return 是否成功
     */
    boolean warehouseIn(Long productId, String inType);
    
    /**
     * 商品出库
     * @param warehouseStockId 仓库库存ID
     * @param outType 出库类型
     * @return 是否成功
     */
    boolean warehouseOut(Long warehouseStockId, String outType);
} 