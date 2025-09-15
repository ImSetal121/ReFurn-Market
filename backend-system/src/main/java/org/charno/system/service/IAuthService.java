package org.charno.system.service;

import com.alibaba.fastjson2.JSONObject;
import org.charno.common.security.LoginUser;
import org.charno.common.entity.SysUser;

public interface IAuthService {
    LoginUser login(JSONObject loginRequest);

    void logout(String token);

    SysUser register(JSONObject registerRequest);
}
