package org.charno.start.filter;

import org.charno.common.utils.JwtUtils;
import org.charno.common.utils.RedisUtils;
import org.charno.common.security.LoginUser;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Component
public class AuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private RedisUtils redisUtils;

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    // 不需要验证的路径
    private final List<String> excludePath = Arrays.asList(
            "/auth/login",
            "/auth/register",
            "/auth/google/authorization-url",
            "/auth/google/login",
            "/auth/google/mobile-login",
            "/api/visitor/**",
            "/payment/stripe/webhook",
            "/chat/websocket",
            "/error");

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        logger.debug("用户请求:" + request.getRequestURI());
        // 放行预检请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }

        // 检查是否是不需要验证的路径
        String requestURI = request.getRequestURI();
        if (isExcludePath(requestURI)) {
            filterChain.doFilter(request, response);
            return;
        }

        // 获取token
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || authHeader.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 提取实际的token（支持Bearer前缀和直接token两种格式）
        String actualToken;
        if (authHeader.startsWith("Bearer ")) {
            actualToken = authHeader.substring(7); // 移除"Bearer "前缀
        } else {
            actualToken = authHeader; // 直接使用token（兼容旧格式）
        }

        // 验证token
        if (!jwtUtils.validateToken(actualToken)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 获取用户信息
        LoginUser loginUser = (LoginUser) redisUtils.getLoginUser(actualToken);
        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 设置用户认证信息到SecurityContext
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(loginUser, null,
                null);
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 刷新token过期时间
        redisUtils.refreshToken(actualToken);

        filterChain.doFilter(request, response);
    }

    private boolean isExcludePath(String requestURI) {
        return excludePath.stream()
                .anyMatch(pattern -> pathMatcher.match(pattern, requestURI));
    }
}
