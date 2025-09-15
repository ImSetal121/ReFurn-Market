package org.charno.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.charno.common.entity.SysRole;
import org.charno.system.mapper.SysRoleMapper;
import org.charno.system.service.ISysRoleService;
import org.springframework.stereotype.Service;

@Service
public class SysRoleServiceImpl extends ServiceImpl<SysRoleMapper, SysRole> implements ISysRoleService {
}
