package org.charno.reflip.service;

import org.charno.reflip.entity.RfUserAddress;
import java.util.List;

/**
 * 用户地址业务接口（用户端）
 */
public interface IUserAddressService {
    
    /**
     * 获取当前用户的地址列表
     */
    List<RfUserAddress> getUserAddressList();
    
    /**
     * 获取当前用户的默认地址
     */
    RfUserAddress getDefaultAddress();
    
    /**
     * 根据ID获取当前用户的地址详情
     */
    RfUserAddress getAddressById(Long id);
    
    /**
     * 添加地址
     */
    boolean addAddress(RfUserAddress address);
    
    /**
     * 更新地址
     */
    boolean updateAddress(RfUserAddress address);
    
    /**
     * 删除地址
     */
    boolean deleteAddress(Long id);
    
    /**
     * 设置默认地址
     */
    boolean setDefaultAddress(Long id);
} 