package org.charno.reflip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.charno.reflip.entity.RfUserAddress;
import org.charno.reflip.service.IRfUserAddressService;
import org.charno.reflip.service.IUserAddressService;
import org.charno.common.utils.SecurityUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户地址业务实现类（用户端）
 */
@Service
public class UserAddressServiceImpl implements IUserAddressService {

    @Autowired
    private IRfUserAddressService rfUserAddressService;

    @Override
    public List<RfUserAddress> getUserAddressList() {
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        RfUserAddress condition = new RfUserAddress();
        condition.setUserId(currentUserId);
        return rfUserAddressService.selectListWithCondition(condition);
    }

    @Override
    public RfUserAddress getDefaultAddress() {
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        RfUserAddress condition = new RfUserAddress();
        condition.setUserId(currentUserId);
        condition.setIsDefault(true);
        
        List<RfUserAddress> addresses = rfUserAddressService.selectListWithCondition(condition);
        return addresses.isEmpty() ? null : addresses.get(0);
    }

    @Override
    public RfUserAddress getAddressById(Long id) {
        if (id == null) {
            throw new RuntimeException("地址ID不能为空");
        }
        
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        RfUserAddress address = rfUserAddressService.getById(id);
        if (address == null) {
            throw new RuntimeException("地址不存在");
        }
        
        if (!currentUserId.equals(address.getUserId())) {
            throw new RuntimeException("无权限访问该地址");
        }
        
        return address;
    }

    @Override
    @Transactional
    public boolean addAddress(RfUserAddress address) {
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        // 数据验证
        validateAddress(address);
        
        // 设置用户ID和创建时间
        address.setUserId(currentUserId);
        address.setCreateTime(LocalDateTime.now());
        address.setUpdateTime(LocalDateTime.now());
        
        // 检查是否是第一个地址，如果是则设为默认
        List<RfUserAddress> existingAddresses = getUserAddressList();
        if (existingAddresses.isEmpty()) {
            address.setIsDefault(true);
        } else {
            // 如果设置为默认地址，需要取消其他地址的默认状态
            if (address.getIsDefault() != null && address.getIsDefault() == Boolean.TRUE) {
                clearDefaultAddress(currentUserId);
            } else {
                address.setIsDefault(false);
            }
        }
        
        return rfUserAddressService.save(address);
    }

    @Override
    @Transactional
    public boolean updateAddress(RfUserAddress address) {
        if (address.getId() == null) {
            throw new RuntimeException("地址ID不能为空");
        }
        
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        // 验证地址是否属于当前用户
        RfUserAddress existingAddress = getAddressById(address.getId());
        
        // 数据验证
        validateAddress(address);
        
        // 设置更新时间，不允许修改用户ID
        address.setUserId(currentUserId);
        address.setUpdateTime(LocalDateTime.now());
        
        // 如果设置为默认地址，需要取消其他地址的默认状态
        if (address.getIsDefault() != null && address.getIsDefault() == Boolean.TRUE) {
            clearDefaultAddress(currentUserId);
        }
        
        return rfUserAddressService.updateById(address);
    }

    @Override
    @Transactional
    public boolean deleteAddress(Long id) {
        if (id == null) {
            throw new RuntimeException("地址ID不能为空");
        }
        
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        // 验证地址是否属于当前用户
        RfUserAddress address = getAddressById(id);
        
        boolean result = rfUserAddressService.removeById(id);
        
        // 如果删除的是默认地址，需要重新设置默认地址
        if (result && address.getIsDefault() == Boolean.TRUE) {
            List<RfUserAddress> remainingAddresses = getUserAddressList();
            if (!remainingAddresses.isEmpty()) {
                setDefaultAddress(remainingAddresses.get(0).getId());
            }
        }
        
        return result;
    }

    @Override
    @Transactional
    public boolean setDefaultAddress(Long id) {
        if (id == null) {
            throw new RuntimeException("地址ID不能为空");
        }
        
        Long currentUserId = SecurityUtils.getUserId();
        if (currentUserId == null) {
            throw new RuntimeException("用户未登录");
        }
        
        // 验证地址是否属于当前用户
        getAddressById(id);
        
        // 先清除当前用户的所有默认地址
        clearDefaultAddress(currentUserId);
        
        // 设置新的默认地址
        RfUserAddress updateAddress = new RfUserAddress();
        updateAddress.setId(id);
        updateAddress.setIsDefault(true);
        updateAddress.setUpdateTime(LocalDateTime.now());
        
        return rfUserAddressService.updateById(updateAddress);
    }
    
    /**
     * 清除当前用户的所有默认地址
     */
    private void clearDefaultAddress(Long userId) {
        LambdaUpdateWrapper<RfUserAddress> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(RfUserAddress::getUserId, userId)
                    .eq(RfUserAddress::getIsDefault, true)
                    .set(RfUserAddress::getIsDefault, false)
                    .set(RfUserAddress::getUpdateTime, LocalDateTime.now());
        
        rfUserAddressService.update(updateWrapper);
    }
    
    /**
     * 验证地址信息
     */
    private void validateAddress(RfUserAddress address) {
        if (address == null) {
            throw new RuntimeException("Address information cannot be empty");
        }
        
        if (address.getReceiverName() == null || address.getReceiverName().trim().isEmpty()) {
            throw new RuntimeException("Receiver name cannot be empty");
        }
        
        if (address.getReceiverPhone() == null || address.getReceiverPhone().trim().isEmpty()) {
            throw new RuntimeException("Contact phone cannot be empty");
        }
        
        if (address.getRegion() == null || address.getRegion().trim().isEmpty()) {
            throw new RuntimeException("Region cannot be empty");
        }
        
        // 电话号码验证 - 支持国际格式
        String phone = address.getReceiverPhone().trim();
        
        // 移除所有非数字字符进行验证
        String digitsOnly = phone.replaceAll("[^\\d]", "");
        
        // 验证至少包含7位数字，最多20位数字（支持国际号码）
        if (digitsOnly.length() < 7 || digitsOnly.length() > 20) {
            throw new RuntimeException("Please enter a valid phone number (7-20 digits)");
        }
        
        // 可选：支持常见的国际格式
        // +1 1234567890, 1234567890, +86 13812345678, 等等
        if (!phone.matches("^[+]?[\\d\\s\\-\\(\\)]{7,25}$")) {
            throw new RuntimeException("Please enter a valid phone number format");
        }
    }
} 