package org.charno.common.security;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.charno.common.entity.SysUser;
import java.io.Serializable;

@Data
@NoArgsConstructor
public class LoginUser implements Serializable {
    private static final long serialVersionUID = 1L;

    private SysUser user;
    private String token;

    public LoginUser(SysUser user, String token) {
        this.user = user;
        this.token = token;
    }
}
