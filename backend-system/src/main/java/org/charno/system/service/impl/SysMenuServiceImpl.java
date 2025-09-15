package org.charno.system.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.charno.common.entity.SysMenu;
import org.charno.system.mapper.SysMenuMapper;
import org.charno.system.service.ISysMenuService;
import org.springframework.stereotype.Service;

@Service
public class SysMenuServiceImpl extends ServiceImpl<SysMenuMapper, SysMenu> implements ISysMenuService {
}
