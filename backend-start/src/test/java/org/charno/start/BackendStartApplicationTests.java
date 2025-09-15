package org.charno.start;

import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.charno.common.entity.SysUser;
import org.charno.system.mapper.SysUserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;

@SpringBootTest
class BackendStartApplicationTests {

    @Autowired
    private SysUserMapper  userMapper;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    void contextLoads() {
    }

//    @Test
//    void register() {
//        JSONObject registerRequest = new JSONObject();
//        registerRequest.put("username", "root");
//        registerRequest.put("password", "123456");
//        registerRequest.put("email", "root@charno.com");
//        registerRequest.put("phoneNumber", "1234567890");
//        registerRequest.put("nickname", "超级管理员");
//        registerRequest.put("roleId", 1);
//
//        // 检查用户名是否已存在
//        QueryWrapper<SysUser> queryWrapper = new QueryWrapper<>();
//        queryWrapper.eq("username", registerRequest.getString("username"))
//                .eq("is_delete", false);
//        if (userMapper.exists(queryWrapper)) {
//            throw new RuntimeException("用户名已存在");
//        }
//
//        // 创建新用户
//        SysUser user = new SysUser();
//        user.setUsername(registerRequest.getString("username"));
//        user.setPassword(passwordEncoder.encode(registerRequest.getString("password")));
//        user.setEmail(registerRequest.getString("email"));
//        user.setPhoneNumber(registerRequest.getString("phoneNumber"));
//        user.setNickname(registerRequest.getString("nickname"));
//        user.setCreateTime(LocalDateTime.now());
//        user.setIsDelete(false);
//
//        // 设置默认角色（假设默认角色的id为1）
//        user.setRoleId(1);
//
//        userMapper.insert(user);
//    }
}
