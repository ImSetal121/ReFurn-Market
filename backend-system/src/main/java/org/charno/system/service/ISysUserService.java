package org.charno.system.service;

import org.charno.common.service.IBaseService;
import org.charno.common.entity.SysUser;

public interface ISysUserService extends IBaseService<SysUser> {
    
    /**
     * 获取用户公开信息
     * @param userId 用户ID
     * @return 用户公开信息
     */
    SysUser getPublicUserInfo(Long userId);
}
