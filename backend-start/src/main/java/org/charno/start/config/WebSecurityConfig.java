package org.charno.start.config;

import org.charno.start.filter.AuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutFilter;
import org.springframework.web.filter.CorsFilter;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    private final CorsFilter corsFilter;
    private final AuthenticationFilter authenticationFilter;

    public WebSecurityConfig(CorsFilter corsFilter, AuthenticationFilter authenticationFilter) {
        this.corsFilter = corsFilter;
        this.authenticationFilter = authenticationFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                // 禁用CSRF，因为我们使用JWT
                .csrf(csrf -> csrf.disable())
                // 基于token，不需要session
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 设置未授权和未登录时的处理
                .exceptionHandling(handling -> handling
                        .authenticationEntryPoint((request, response, e) -> {
                            response.setStatus(401);
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"message\":\"未授权\"}");
                        }))
                // 设置权限
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/login", "/auth/register", 
                                       "/auth/google/authorization-url", "/auth/google/login",
                                       "/auth/google/mobile-login",
                                        "/api/visitor/**",
                                        "/payment/stripe/webhook",
                                        "/chat/websocket"
                                ).permitAll()
                        .anyRequest().authenticated())
                // 禁用默认登录页
                .formLogin(form -> form.disable())
                // 添加JWT过滤器和跨域过滤器
                .addFilterBefore(corsFilter, LogoutFilter.class)
                .addFilterBefore(authenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }
}
