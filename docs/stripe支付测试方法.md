在Stripe沙盒环境下，您可以使用特定的测试卡号来模拟不同的支付场景。这里是完整的测试指南：

## 🧪 测试支付成功

### 成功支付的测试卡号
```
✅ 基本成功测试卡号：
- 4242424242424242 (Visa)
- 5555555555554444 (Mastercard) 
- 378282246310005 (American Express)
- 6011111111111117 (Discover)

✅ 国际卡测试：
- 4000000000000077 (需要CVC验证)
- 4000000000000010 (需要邮编验证)
```

### 卡片信息填写（任意值）
```
过期日期：任何未来日期 (如 12/34)
CVC：任何3位数字 (如 123)
邮编：任何邮编 (如 12345)
姓名：任何姓名 (如 Test User)
```

## ❌ 测试支付失败

### 1. 卡被拒绝
```
4000000000000002 - 通用拒绝
4000000000000069 - 过期卡
4000000000000127 - CVC错误
4000000000000119 - 处理错误
```

### 2. 资金不足
```
4000000000009995 - 资金不足
4000000000009987 - CVC验证失败
4000000000009979 - 过期卡拒绝
```

### 3. 其他错误场景
```
4000000000000341 - 需要认证（3D Secure）
4000000000000259 - 风险拒绝
4000000000000036 - 账户关闭
```

## 🔍 具体测试流程

### 测试成功支付：

1. **启动应用**
```bash
# 终端1：后端
mvn spring-boot:run

# 终端2：Stripe CLI
stripe listen --forward-to localhost:8080/payment/stripe/webhook

# 终端3：Flutter
flutter run
```

2. **在Flutter应用中**
   - 选择商品进入订单确认页面
   - 填写地址和取件时间
   - 点击"Pay Now"

3. **在支付界面中输入**
```
卡号：4242424242424242
过期：12/34
CVC：123
邮编：12345
```

4. **预期结果**
```bash
# Stripe CLI应该显示：
payment_intent.succeeded [evt_xxx]
<-- [200] POST http://localhost:8080/payment/stripe/webhook

# 后端日志应该显示：
支付成功 - 商品ID: 123, 支付意图ID: pi_xxxxx

# Flutter应该显示：
✅ 支付成功！
```

### 测试失败支付：

1. **测试卡被拒绝**
```
卡号：4000000000000002
其他信息：随意填写
```

2. **预期结果**
```bash
# Stripe CLI显示：
payment_intent.payment_failed [evt_xxx]
<-- [200] POST http://localhost:8080/payment/stripe/webhook

# 后端日志显示：
支付失败 - 商品ID: 123, 支付意图ID: pi_xxxxx

# Flutter显示：
❌ 支付失败，请检查支付信息
```

## 📊 在Stripe Dashboard中查看

### 1. 查看测试支付记录
- 进入 [Stripe Dashboard](https://dashboard.stripe.com/)
- 确保左下角显示"测试模式"
- 进入 **Payments** 页面
- 查看支付记录和状态

### 2. 查看Webhook事件
- 进入 **Developers** → **Webhooks**
- 点击您的Webhook端点
- 查看"事件"标签页
- 确认事件发送成功（绿色勾号）

## 🧪 高级测试场景

### 1. 测试网络错误
```bash
# 故意停止后端服务，测试Webhook重试
# Stripe会自动重试失败的Webhook
```

### 2. 测试3D Secure认证
```
卡号：4000000000000341
# 会弹出3D Secure认证窗口
```

### 3. 手动触发Webhook事件
```bash
# 使用Stripe CLI手动触发事件
stripe trigger payment_intent.succeeded
stripe trigger payment_intent.payment_failed
```

## 🐛 调试技巧

### 1. 查看详细错误信息
在Flutter的StripeService中添加调试日志：

```dart
} on StripeException catch (e) {
  print('Stripe错误详情: ${e.error.code}');
  print('错误消息: ${e.error.message}');
  print('错误类型: ${e.error.type}');
  // ...
}
```

### 2. 查看后端支付意图创建
在PaymentServiceImpl中添加日志：

```java
@Override
public PaymentResponse createPaymentIntent(PaymentRequest paymentRequest) throws Exception {
    System.out.println("创建支付意图 - 金额: " + paymentRequest.getAmount());
    System.out.println("商品ID: " + paymentRequest.getProductId());
    
    // ... 现有代码
    
    System.out.println("支付意图创建成功 - ID: " + paymentIntent.getId());
    return new PaymentResponse(/*...*/);
}
```

### 3. 模拟不同金额的支付
```dart
// 在Flutter中可以修改金额来测试不同场景
final paymentRequest = PaymentRequest(
  productId: productId,
  amount: 1.00, // 测试小额支付
  // amount: 999999.99, // 测试大额支付
  description: 'Purchase: $productName',
);
```

## 📝 测试检查清单

### ✅ 支付成功测试
- [ ] 使用4242424242424242成功支付
- [ ] 后端收到payment_intent.succeeded事件
- [ ] Webhook返回200状态码
- [ ] Flutter显示成功提示
- [ ] Stripe Dashboard显示成功记录

### ❌ 支付失败测试  
- [ ] 使用4000000000000002失败支付
- [ ] 后端收到payment_intent.payment_failed事件
- [ ] Flutter显示失败提示
- [ ] 用户可以重新尝试支付

### 🔄 边界情况测试
- [ ] 网络中断时的重试机制
- [ ] 重复支付的处理
- [ ] 超时场景的处理

## 💡 推荐测试顺序

1. **先测试成功流程** - 确保基本功能正常
2. **测试常见失败场景** - 卡被拒绝、资金不足等
3. **测试边界情况** - 网络问题、重复提交等
4. **压力测试** - 快速连续支付测试

这样可以系统性地验证您的支付系统在各种情况下的表现！