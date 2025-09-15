package org.charno.reflip.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import lombok.extern.slf4j.Slf4j;

/**
 * 处理Stripe Connect账户设置后的重定向
 */
@Slf4j
@Controller
@RequestMapping("/stripe/account")
public class StripeRedirectController {
    
    /**
     * 处理账户链接过期时的刷新请求
     * 
     * @param state 状态参数（通常包含用户标识）
     * @return 重定向结果页面
     */
    @GetMapping("/refresh")
    public ModelAndView handleRefresh(@RequestParam(required = false) String state) {
        log.info("Stripe账户设置链接已过期，请求刷新。State: {}", state);
        
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("stripe_redirect");
        modelAndView.addObject("title", "链接已过期");
        modelAndView.addObject("message", "请返回应用并点击'刷新链接'按钮");
        modelAndView.addObject("status", "expired");
        return modelAndView;
    }
    
    /**
     * 处理账户设置完成后的返回请求
     * 
     * @param state 状态参数（通常包含用户标识）
     * @return 重定向结果页面
     */
    @GetMapping("/return")
    public ModelAndView handleReturn(@RequestParam(required = false) String state) {
        log.info("Stripe账户设置已完成，用户已返回。State: {}", state);
        
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("stripe_redirect");
        modelAndView.addObject("title", "设置完成");
        modelAndView.addObject("message", "您的收款账户设置已完成，请返回应用查看结果");
        modelAndView.addObject("status", "success");
        return modelAndView;
    }
    
    /**
     * 提供一个简单的API端点，返回纯文本信息
     * 
     * @return 纯文本响应
     */
    @GetMapping("/refresh-text")
    public ResponseEntity<String> handleRefreshText() {
        return ResponseEntity.ok("账户链接已过期，请返回应用并刷新链接");
    }
    
    /**
     * 提供一个简单的API端点，返回纯文本信息
     * 
     * @return 纯文本响应
     */
    @GetMapping("/return-text")
    public ResponseEntity<String> handleReturnText() {
        return ResponseEntity.ok("账户设置完成，请返回应用");
    }
} 