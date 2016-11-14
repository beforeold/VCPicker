//
//  VCPicker.h

//
//  Created by ibeforeold on 16/3/24.
//
//also see the article 
// [开发利器：控制器传送门（已通过半年使用和上线验证，附demo）](http://www.jianshu.com/p/60357c77a9ed)
// [github](https://github.com/beforeold)

#import <UIKit/UIKit.h>

/**
 *  Find and navigate to your viewController fast
 *  用此类搜索和选择你想要跳转的控制器
 *
 */
@interface VCPicker : UIViewController

/**
 *  activate VCPicker
 *  启用 VCPicker
 */
+ (void)activateWhenDebug:(BOOL)needTitle;

/**
 *  activate for prefixes, more efficiently，启用 VCPicker，携带类前缀信息，查找工程内控制器的效率更高
 *
 *  @param prefixes class prefixes, can be nil 类前缀，可为nil
 */
+ (void)activateWithClassPrefixesWhenDebug:(NSArray <NSString *> *)prefixes needTitle:(BOOL)needTitle;

@end
