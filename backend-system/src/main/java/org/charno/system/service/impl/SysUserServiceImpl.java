package org.charno.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.charno.common.entity.SysUser;
import org.charno.system.mapper.SysUserMapper;
import org.charno.system.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements ISysUserService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public boolean save(SysUser entity) {
        // 新增用户时，对密码进行加密
        if (StringUtils.hasText(entity.getPassword())) {
            entity.setPassword(passwordEncoder.encode(entity.getPassword()));
        }
        
        // 设置创建时间
        if (entity.getCreateTime() == null) {
            entity.setCreateTime(LocalDateTime.now());
        }
        
        // 设置默认删除状态
        if (entity.getIsDelete() == null) {
            entity.setIsDelete(false);
        }
        
        return super.save(entity);
    }

    @Override
    public boolean updateById(SysUser entity) {
        // 修改用户时，只有当密码字段不为空时才进行加密
        if (StringUtils.hasText(entity.getPassword())) {
            // 获取原始用户信息
            SysUser originalUser = getById(entity.getId());
            if (originalUser != null) {
                // 如果密码与原密码不同，说明是要修改密码，需要加密
                if (!entity.getPassword().equals(originalUser.getPassword())) {
                    entity.setPassword(passwordEncoder.encode(entity.getPassword()));
                }
            } else {
                // 如果找不到原用户，直接加密新密码
                entity.setPassword(passwordEncoder.encode(entity.getPassword()));
            }
        }
        
        // 设置更新时间
        entity.setUpdateTime(LocalDateTime.now());
        
        return super.updateById(entity);
    }

    @Override
    public SysUser getPublicUserInfo(Long userId) {
        if (userId == null) {
            return null;
        }
        
        // 使用 MyBatis-Plus 的 LambdaQueryWrapper 构建查询条件
        LambdaQueryWrapper<SysUser> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.select(
                SysUser::getId,
                SysUser::getUsername,
                SysUser::getNickname,
                SysUser::getAvatar,
                SysUser::getEmail,
                SysUser::getCreateTime
            )
            .eq(SysUser::getId, userId);
        
        return this.getOne(queryWrapper);
    }
}
