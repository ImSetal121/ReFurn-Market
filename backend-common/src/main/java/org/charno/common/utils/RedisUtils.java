package org.charno.common.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class RedisUtils {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    private static final String TOKEN_PREFIX = "reflip:login_token:";
    private static final long TOKEN_EXPIRE = 60 * 24 * 1; // 30分钟过期

    public void setLoginUser(String token, Object loginUser) {
        String key = TOKEN_PREFIX + token;
        redisTemplate.opsForValue().set(key, loginUser, TOKEN_EXPIRE, TimeUnit.MINUTES);
    }

    public Object getLoginUser(String token) {
        String key = TOKEN_PREFIX + token;
        return redisTemplate.opsForValue().get(key);
    }

    public void deleteLoginUser(String token) {
        String key = TOKEN_PREFIX + token;
        redisTemplate.delete(key);
    }

    public void refreshToken(String token) {
        String key = TOKEN_PREFIX + token;
        redisTemplate.expire(key, TOKEN_EXPIRE, TimeUnit.MINUTES);
    }
}
