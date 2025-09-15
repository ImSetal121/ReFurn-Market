package org.charno.reflip.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.charno.common.core.R;
import org.charno.reflip.dto.AuditReturnRequestDto;
import org.charno.reflip.service.IPlatformService;

/**
 * 平台管理控制器
 */
@RestController
@RequestMapping("/api/platform")
@CrossOrigin(origins = "*")
public class PlatformController {
    
    @Autowired
    private IPlatformService platformService;
    
    /**
     * 审批退货申请
     * @param auditRequest 审批请求数据
     * @return 审批结果
     */
    @PostMapping("/audit-return")
    public R<Boolean> auditReturnRequest(@RequestBody AuditReturnRequestDto auditRequest) {
        try {
            // 参数校验
            if (auditRequest.getReturnRecordId() == null) {
                return R.fail("退货记录ID不能为空");
            }
            
            if (auditRequest.getAuditResult() == null || auditRequest.getAuditResult().trim().isEmpty()) {
                return R.fail("审核结果不能为空");
            }
            
            if (!"APPROVED".equals(auditRequest.getAuditResult()) && !"REJECTED".equals(auditRequest.getAuditResult())) {
                return R.fail("审核结果只能是APPROVED或REJECTED");
            }
            
            if (auditRequest.getAuditDetail() == null || auditRequest.getAuditDetail().trim().isEmpty()) {
                return R.fail("审核详细说明不能为空");
            }
            
            if (auditRequest.getFreightBearer() == null || auditRequest.getFreightBearer().trim().isEmpty()) {
                return R.fail("运费承担方不能为空");
            }
            
            if (!"SELLER".equals(auditRequest.getFreightBearer()) && 
                !"BUYER".equals(auditRequest.getFreightBearer()) && 
                !"PLATFORM".equals(auditRequest.getFreightBearer())) {
                return R.fail("运费承担方只能是SELLER、BUYER或PLATFORM");
            }
            
            // 如果需要赔偿商品，则赔偿承担方不能为空
            if (auditRequest.getNeedCompensateProduct() != null && auditRequest.getNeedCompensateProduct()) {
                if (auditRequest.getCompensationBearer() == null || auditRequest.getCompensationBearer().trim().isEmpty()) {
                    return R.fail("当需要赔偿商品时，赔偿承担方不能为空");
                }
                
                if (!"SELLER".equals(auditRequest.getCompensationBearer()) && 
                    !"BUYER".equals(auditRequest.getCompensationBearer()) && 
                    !"PLATFORM".equals(auditRequest.getCompensationBearer())) {
                    return R.fail("赔偿承担方只能是SELLER、BUYER或PLATFORM");
                }
            }
            
            // 调用业务层处理
            boolean result = platformService.auditReturnRequest(auditRequest);
            
            if (result) {
                return R.ok(true, "审批成功");
            } else {
                return R.fail("审批失败");
            }
            
        } catch (IllegalArgumentException e) {
            return R.fail("参数错误: " + e.getMessage());
        } catch (RuntimeException e) {
            return R.fail("业务错误: " + e.getMessage());
        } catch (Exception e) {
            return R.fail("系统错误: " + e.getMessage());
        }
    }
} 