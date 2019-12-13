

> 如需运行 demo，可直接 clone 或下载后打开 TestVCPicker2 工程


# VCPicker

Find and navi to your controller fast

also see the article 
[开发利器：控制器传送门（已通过半年使用和上线验证，附demo）](http://www.jianshu.com/p/60357c77a9ed)

# 0 背景
在项目早期开发阶段，还不需要接入后台网络数据，主要工作的界面的开发。
随着业务页面的深入，要查看二级、三级页面的效果就需要编译后跳转两三次甚至更多，不断地重复这个过程相对来说，就没有可以直接启动就查看那个页面来得那么高效。

# 1 解决方案
## 1.1 简单粗暴的方式
常见的做法是在application:didFinishLaunchWithOptions:时直接push到想要到达的页面，如下：
``` objective-c
 //  获取到可以展示的容器控制器
UINavigationViewController *naviVC = [self getNavigationVC];
// 创建想要跳转的控制器
TargetViewController *targetVC = [[TargetViewController alloc] init]; 
// 跳转到目标页面
[naviVC pushViewController:targetVC animated:YES]; 
```
这样可以在程序启动时便捷地跳转了，但在多个工程师协同合作时有一个潜在的问题
- 是会污染其他同事的代码
- 而多个同事都写了这样的便捷页面跳转而不小心提交到公共代码库就会出代码冲突

## 1.2 传送门方案VCPicker
为了方便每个协同开发的工程师跳转任意页面，一个更效率的方式有一个入口可以随时找到某一个ViewController页面的类，跳转过去即可，顺着这个思路需要做两个事情：
- 找到工程里所有的ViewController控制器类
- 设置一个统一的入口

实现的途径：
- 利用```objc-runtime```机制获取项目中所有的类，再筛选出所有UIViewController的子类，以字符串的形式保存类名，以列表的形式展现，当点击某一个类时，通过类初始化一个实例即可实现目标页面的跳转
``` objective-c
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
```
- 传送门入口的设计，最初是想通过摇一摇来实现从而不影响原有UI的效果，但是不便于模拟器上的使用，所以借鉴了苹果的辅助手势```Assist touch```悬浮球设计，在程序的keyWindow上悬浮一个可以挪动的小球从而在编译进入程序后可以第一时间点击查看控制器列表选择想要跳转的控制器。
```
// 创建悬浮效果
[[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
```
# 2 优化
在使用的过程中逐步衍生并优化了一些有用的功能
## 2.1 使用class-prefix
由于通过runtime获取到的类有很多是系统的私有类，甚至不响应NSObject协议的，在操作这些类时则会非常危险，此外一些UI的控制器类（比如图片选择、通讯录获取）是需要权限才能访问和创建实例的，而我们实际的项目中一般都有类前缀```class-prefix```（外包的同学不服....），通过类前缀可以快速地筛选出实际项目中的业务页面
## 2.2 展示方式
根据具体的业务场景基本上分为带导航和不带导航两种，因此使用presentViewController的方法，一种会创建导航控制器后present，另一种则是直接present；
## 2.3 获取title
有的小伙伴提出，看到的是茫茫的一片类名而不知道业务title不方便同事之间学习，通过分析大部分都会在viewDidLoad方法设置title，或者navigationItem.title或者tabbarItem.title，因此需要实例化一个控制器对象，尝试调用viewDidLoad方法，实践证明如此是不安全的，一方面是viewDidLoad是控制器的生命周期方法原则上是父类调用的，再者很多同学还在viewDidLoad进行了KVO和通知的监听的监听，手动调用viewDidLoad会导致重复监听的问题，而调用[controller view]方法则可以完美地解决这个问题，调用[controller view]方法会在内部依次触发[controller loadView]和[controller viewDidLoad]方法，之后就能获取到想要的title信息；此外，在实例化对象调用view属性触发viewDidLoad时可能因为初始化参数不足的问题抛出异常，因此需要在此处代码块进行@try-catch保护，并保存异常信息提醒当前页面存在潜在异常。
``` objective-c
// 创建实例，获取title
            UIViewController *controller = nil;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            @try {
                if (_needTitle) {
                    controller = [[NSClassFromString(className) alloc] init]; // nil
                    [controller view]; // to active viewDidLoad so we can get conroller.title
                }
                
            } @catch (NSException *exception) {
                NSLog(@"[VCPicker <%@> exception: %@]", className, exception);
                dic[kErrorKey] = exception.description;
                
            } @finally {
                dic[kNameKey] = className;
                dic[kTitleKey] = controller.title ?: (controller.navigationItem.title ?: (controller.tabBarItem.title ?: className));
                [self refreshHistoryForControllerInfo:dic];
                [array addObject:dic];
            }
```
# 2.4 增加历史记录和搜索功能
从众多的类列表中，经过排序可以方便查找，更方便的方法是提供搜索功能，下次再进入时如果保存了历史记录就更好了，所以这些都要有，所以都有了

### 感谢开发过程中Zoro和Ace同学的极好的建议
在实际开发项目中进行应用，内部实现使用```DEBUG```宏进行预编译的判断，确保上线时不会出问题，使用VCPicker不用移除也可以正常审核上线App store。
﻿
# 3 效果图

![传送门悬浮球效果](http://upload-images.jianshu.io/upload_images/73339-ea9a99f28cf83ae1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![类列表效果](http://upload-images.jianshu.io/upload_images/73339-adc420ddd7718458.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![页面展示效果](http://upload-images.jianshu.io/upload_images/73339-d4707d87c372a718.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

