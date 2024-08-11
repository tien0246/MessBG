#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "SettingsView/SettingsView.h"
#import "ImagePickerManager/ImagePickerManager.h"
#import "SharedManager/SharedManager.h"

@interface MDSLabel: UILabel
@end

@interface _UIBarBackground: UIView
@end

@interface MDSBlurView: UIVisualEffectView
@end

@interface Tweak : NSObject
    + (instancetype)sharedInstance;
    - (NSComparisonResult)compareVersion:(NSString *)version1 withVersion:(NSString *)version2;
@end