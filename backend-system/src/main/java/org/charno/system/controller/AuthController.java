package org.charno.system.controller;

import com.alibaba.fastjson2.JSONObject;
import org.charno.common.core.R;
import org.charno.common.core.ResultCode;
import org.charno.common.entity.SysMenu;
import org.charno.common.entity.SysRole;
import org.charno.common.security.LoginUser;
import org.charno.common.utils.SecurityUtils;
import org.charno.system.mapper.SysRoleMapper;
import org.charno.system.service.IAuthService;
import org.charno.system.service.IGoogleAuthService;
import org.charno.system.service.ISysRoleMenuService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private IAuthService authService;

    @Autowired
    private IGoogleAuthService googleAuthService;

    @Autowired
    private ISysRoleMenuService roleMenuService;

    @Autowired
    private SysRoleMapper roleMapper;

    @GetMapping("/menus")
    public R<?> getMenus() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null) {
            return R.fail(ResultCode.UNAUTHORIZED);
        }

        Integer roleId = loginUser.getUser().getRoleId();
        if (roleId == null) {
            return R.fail("用户未分配角色");
        }

        List<SysMenu> menus = roleMenuService.getMenusByRoleId(roleId);
        return R.ok(menus);
    }

    @PostMapping("/login")
    public R<?> login(@RequestBody JSONObject loginRequest) {
        try {
            LoginUser loginUser = authService.login(loginRequest);
            JSONObject response = new JSONObject();
            response.put("token", loginUser.getToken());
            response.put("user", loginUser.getUser());
            return R.ok(response);
        } catch (Exception e) {
            return R.fail(ResultCode.USERNAME_OR_PASSWORD_ERROR, e.getMessage());
        }
    }

    @PostMapping("/logout")
    public R<?> logout(@RequestHeader("Authorization") String token) {
        try {
            authService.logout(token);
            return R.ok();
        } catch (Exception e) {
            return R.fail(e.getMessage());
        }
    }

    @PostMapping("/register")
    public R<?> register(@RequestBody JSONObject registerRequest) {
        try {
            return R.ok(authService.register(registerRequest));
        } catch (Exception e) {
            return R.fail(e.getMessage());
        }
    }

    @GetMapping("/info")
    public R<?> getUserInfo() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null) {
            return R.fail(ResultCode.UNAUTHORIZED);
        }

        Integer roleId = loginUser.getUser().getRoleId();
        if (roleId != null) {
            // 查询角色信息
            SysRole role = roleMapper.selectById(roleId);
            if (role != null) {
                JSONObject userInfo = new JSONObject();
                userInfo.put("user", loginUser.getUser());
                userInfo.put("role", role);
                return R.ok(userInfo);
            }
        }

        return R.ok(loginUser.getUser());
    }

    /**
     * 获取Google授权URL
     */
    @GetMapping("/google/authorization-url")
    public R<?> getGoogleAuthorizationUrl() {
        try {
            String authUrl = googleAuthService.getAuthorizationUrl();
            return R.ok(authUrl);
        } catch (Exception e) {
            return R.fail("获取Google授权URL失败: " + e.getMessage());
        }
    }

    /**
     * Google登录 (Web端授权码方式)
     */
    @PostMapping("/google/login")
    public R<?> googleLogin(@RequestBody JSONObject request) {
        try {
            String authCode = request.getString("code");
            if (authCode == null || authCode.trim().isEmpty()) {
                return R.fail("授权码不能为空");
            }

            LoginUser loginUser = googleAuthService.googleLogin(authCode);
            JSONObject response = new JSONObject();
            response.put("token", loginUser.getToken());
            response.put("user", loginUser.getUser());
            response.put("isNewUser", loginUser.getUser().getCreateTime().isAfter(
                    loginUser.getUser().getLastLoginDate().minusMinutes(1)
            )); // 简单判断是否为新用户
            
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Google登录失败: " + e.getMessage());
        }
    }

    /**
     * Google移动端登录 (ID Token方式)
     */
    @PostMapping("/google/mobile-login")
    public R<?> googleMobileLogin(@RequestBody JSONObject request) {
        try {
            String idToken = request.getString("idToken");
            String clientType = request.getString("clientType"); // ios 或 android
            
            if (idToken == null || idToken.trim().isEmpty()) {
                return R.fail("ID Token不能为空");
            }
            
            if (clientType == null || clientType.trim().isEmpty()) {
                clientType = "ios"; // 默认为iOS
            }

            LoginUser loginUser = googleAuthService.googleMobileLogin(idToken, clientType);
            JSONObject response = new JSONObject();
            response.put("token", loginUser.getToken());
            response.put("user", loginUser.getUser());
            response.put("isNewUser", loginUser.getUser().getCreateTime().isAfter(
                    loginUser.getUser().getLastLoginDate().minusMinutes(1)
            )); // 简单判断是否为新用户
            
            return R.ok(response);
        } catch (Exception e) {
            return R.fail("Google移动端登录失败: " + e.getMessage());
        }
    }
}
