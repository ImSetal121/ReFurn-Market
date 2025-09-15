package org.charno.system.service.impl;

import org.charno.common.utils.JwtUtils;
import org.charno.common.utils.RedisUtils;
import com.alibaba.fastjson2.JSONObject;
import org.charno.common.entity.SysRole;
import org.charno.common.entity.SysUser;
import org.charno.system.mapper.SysRoleMapper;
import org.charno.system.mapper.SysUserMapper;
import org.charno.common.security.LoginUser;
import org.charno.system.service.IAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;

import java.time.LocalDateTime;

@Service
public class AuthServiceImpl implements IAuthService {

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysRoleMapper roleMapper;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private RedisUtils redisUtils;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public LoginUser login(JSONObject loginRequest) {
        // 查询用户
        QueryWrapper<SysUser> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", loginRequest.getString("username"))
                .eq("is_delete", false);
        SysUser user = userMapper.selectOne(queryWrapper);

        // 验证用户存在
        if (user == null) {
            throw new RuntimeException("用户名或密码错误");
        }

        // 检查用户是否绑定了Google账号
        if (user.getGoogleSub() != null && !user.getGoogleSub().isEmpty()) {
            throw new RuntimeException("该账号已绑定Google登录，请使用Google登录");
        }

        // 验证密码正确
        if (!passwordEncoder.matches(loginRequest.getString("password"), user.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }

        // 生成token
        String token = jwtUtils.generateToken();

        // 获取角色信息
        SysRole role = roleMapper.selectById(user.getRoleId());

        // 创建登录用户对象
        LoginUser loginUser = new LoginUser(user, token);

        // 更新用户登录信息
        user.setLastLoginDate(LocalDateTime.now());
        userMapper.updateById(user);

        // 存入Redis
        redisUtils.setLoginUser(token, loginUser);

        return loginUser;
    }

    @Override
    public void logout(String token) {
        redisUtils.deleteLoginUser(token);
    }

    @Override
    public SysUser register(JSONObject registerRequest) {
        String username = registerRequest.getString("username");
        String email = registerRequest.getString("email");
        String phoneNumber = registerRequest.getString("phoneNumber");
        String password = registerRequest.getString("password");
        String nickname = registerRequest.getString("nickname");

        // 检查用户名是否已存在
        QueryWrapper<SysUser> usernameQuery = new QueryWrapper<>();
        usernameQuery.eq("username", username)
                .eq("is_delete", false);
        if (userMapper.exists(usernameQuery)) {
            throw new RuntimeException("用户名已存在");
        }

        // 检查邮箱是否已存在（如果提供了邮箱）
        if (email != null && !email.trim().isEmpty()) {
            QueryWrapper<SysUser> emailQuery = new QueryWrapper<>();
            emailQuery.eq("email", email)
                    .eq("is_delete", false);
            if (userMapper.exists(emailQuery)) {
                throw new RuntimeException("邮箱已被使用");
            }
        }

        // 检查手机号是否已存在（如果提供了手机号）
        if (phoneNumber != null && !phoneNumber.trim().isEmpty()) {
            QueryWrapper<SysUser> phoneQuery = new QueryWrapper<>();
            phoneQuery.eq("phone_number", phoneNumber)
                    .eq("is_delete", false);
            if (userMapper.exists(phoneQuery)) {
                throw new RuntimeException("手机号已被使用");
            }
        }

        // 验证必填字段
        if (username == null || username.trim().isEmpty()) {
            throw new RuntimeException("用户名不能为空");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new RuntimeException("密码不能为空");
        }
        if (password.length() < 6) {
            throw new RuntimeException("密码长度至少6位");
        }

        // 创建新用户
        SysUser user = new SysUser();
        user.setUsername(username.trim());
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email != null && !email.trim().isEmpty() ? email.trim() : null);
        user.setPhoneNumber(phoneNumber != null && !phoneNumber.trim().isEmpty() ? phoneNumber.trim() : null);
        user.setNickname(nickname != null && !nickname.trim().isEmpty() ? nickname.trim() : username.trim());
        user.setCreateTime(LocalDateTime.now());
        user.setIsDelete(false);

        // 设置默认角色（假设默认角色的id为1）
        user.setRoleId(1);

        userMapper.insert(user);
        
        // 清除密码后返回
        user.setPassword(null);
        return user;
    }
}
