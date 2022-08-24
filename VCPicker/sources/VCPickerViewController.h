//
//  VCPickerViewController.h
//  VCPicker
//
//  Created by beforeold on 16/3/24.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG

NS_ASSUME_NONNULL_BEGIN

@protocol VCPickerCustomPresenting <NSObject>

@optional
/// 实现此方法，自定义展示的行为
+ (void)vcpicker_customShow;


/// 自定义需要 present 的控制器
+ (__kindof UIViewController *)vcpicker_customViewController;

@end

/**
 *  Find and navigate to your viewController fast
 *  用此类搜索和选择你想要跳转的控制器
 *
 */
@interface VCPickerViewController : UIViewController


/**
 *  activate VCPicker
 *  启用 VCPicker
 */
+ (void)activateWhenDebug;

/**
 *  activate for prefixes, more efficiently，启用 VCPicker，携带类前缀信息，查找工程内控制器的效率更高
 *
 *  @param prefixes class prefixes, can be nil 类前缀，可为nil
 */
+ (void)activateWhenDebugWithClassPrefixes:(NSArray <NSString *> *_Nullable)prefixes;

/// 显示 exceptArray 外的所有 prefix 的控制器
+ (void)activateWhenDebugWithClassPrefixes:(NSArray <NSString *> *_Nullable)prefixes except:(NSArray <NSString *> *_Nullable)exceptArray;

+ (void)activateWhenDebugWithClassPrefixes:(NSArray <NSString *> *_Nullable)prefixes
                                    except:(NSArray <NSString *> *_Nullable)exceptArray
                                 needTitle:(BOOL)needTitle;

@end

NS_ASSUME_NONNULL_END

#endif
