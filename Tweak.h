#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "SettingsView/SettingsView.h"
#import "ImagePickerManager/ImagePickerManager.h"
#import "SharedManager/SharedManager.h"
#import "Languages/Languages.h"

@interface Tweak : NSObject
    + (instancetype)sharedInstance;
    - (NSComparisonResult)compareVersion:(NSString *)version1 withVersion:(NSString *)version2;

    - (void)showActionSheetInView:(UIView *)view isGlobal:(BOOL)isGlobal;

    - (NSString *)imagePath;
    - (UIImage *)blurredImageWithPath:(NSString *)imagePath alpha:(CGFloat)alpha;
    - (UIView *)createBlackOverlayWithFrame:(CGRect)frame alpha:(CGFloat)alpha;
    - (void)applyBackgroundImage:(UIImage *)image withOverlay:(UIView *)overlay toView:(UIView *)view;
    - (void)changeBackground:(UIView *)view;
@end

@interface CustomButton : UIButton
@end

@interface MSGMessageListView: UIView
@end

@interface MDSLabel: UILabel
@end

@interface _UIBarBackground: UIView
@end

@interface MDSBlurView: UIVisualEffectView
@end

@interface UITableViewCellContentView: UIView
@end

@interface _UIVisualEffectContentView: UIView
@end

@interface UITableView (MessBG)
- (void)changeBackground;
@end

// @interface LSView: UIView
// @end
