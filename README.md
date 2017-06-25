# OJNotification

模仿 iOS 10 系统通知样式，创建可以在程序内弹出的通知样式。效果如下：

![Figure](./screenshots/figure.png)

# Usage

## 简单使用

展示最基础的模型，没有指定任何 model （项目中不建议依次方式运行，仅在测试显示效果时使用，*程序没有对nil进行强制校验*）

```objective-c
[OJNotificationWindow showNotificationWithModel:nil];
```

## 传入通知模型

通知模型为 `OJNotificationModel` 及其子类。

创建通知模型

```objective-c
OJNotificationModel *notification = [[OJNotificationModel alloc] init];
notification.time = @"刚刚";
notification.title = @"用药提醒";
notification.detail = @"您预约了后天（2017年6月10日）在华西体检，请不要错过哦！";
notification.type = @"华西健康";
```

展示通知

```objective-c
[OJNotificationWindow showNotificationWithModel:notification];
```

# TODO

1. [ ] 屏幕旋转适配
2. [x] 应用数据模型
3. [ ] 开放API，可轻松自定义自己的通知视图
