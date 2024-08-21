#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../SharedManager/SharedManager.h"
#import "../Languages/Languages.h"

@interface SettingsView : UIView

@property (nonatomic, assign) UIViewController *presentingViewController;
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) Languages *languages;

- (instancetype)initWithFrame:(CGRect)frame presentingViewController:(UIViewController *)viewController isGlobal:(BOOL)isGlobal;
- (void)backButtonTapped;
- (void)saveSwitchStates;
- (void)loadSwitchStates;
- (void)addSwitch:(UIView *)parentView frame:(CGRect)frame switchKey:(NSString *)key switchName:(NSString *)name description:(NSString *)description;
- (void)addSlider:(UIView *)parentView frame:(CGRect)frame sliderKey:(NSString *)key sliderName:(NSString *)name description:(NSString *)description;

@end