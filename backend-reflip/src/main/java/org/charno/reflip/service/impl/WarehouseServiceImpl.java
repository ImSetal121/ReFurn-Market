package org.charno.reflip.service.impl;

import org.charno.reflip.entity.RfProduct;
import org.charno.reflip.entity.RfWarehouseStock;
import org.charno.reflip.service.IWarehouseService;
import org.charno.reflip.service.IRfProductService;
import org.charno.reflip.service.IRfWarehouseStockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 仓库服务实现
 */
@Service
public class WarehouseServiceImpl implements IWarehouseService {

    @Autowired
    private IRfProductService rfProductService;
    
    @Autowired
    private IRfWarehouseStockService rfWarehouseStockService;

    @Override
    @Transactional
    public boolean warehouseIn(Long productId, String inType) {
        try {
            // 查询商品信息
            RfProduct product = rfProductService.getById(productId);
            if (product == null) {
                return false;
            }

            // 创建仓库库存记录
            RfWarehouseStock warehouseStock = new RfWarehouseStock();
            warehouseStock.setWarehouseId(product.getWarehouseId());
            warehouseStock.setProductId(productId);
            warehouseStock.setStockQuantity(1); // 默认数量为1
            warehouseStock.setInType(inType);
            warehouseStock.setInTime(LocalDateTime.now());
            warehouseStock.setStatus("IN_STOCK");

            boolean saveResult = rfWarehouseStockService.save(warehouseStock);

            product.setWarehouseStockId(warehouseStock.getId());
            rfProductService.updateById(product);

            return saveResult;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    @Transactional
    public boolean warehouseOut(Long warehouseStockId, String outType) {
        try {
            // 查询仓库库存记录
            RfWarehouseStock warehouseStock = rfWarehouseStockService.getById(warehouseStockId);
            if (warehouseStock == null || !"IN_STOCK".equals(warehouseStock.getStatus())) {
                return false;
            }

            // 更新出库信息
            warehouseStock.setOutType(outType);
            warehouseStock.setOutTime(LocalDateTime.now());
            warehouseStock.setStatus("OUT_OF_STOCK");

            return rfWarehouseStockService.updateById(warehouseStock);
        } catch (Exception e) {
            return false;
        }
    }
} 