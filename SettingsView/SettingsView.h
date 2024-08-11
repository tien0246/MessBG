#import <UIKit/UIKit.h>
#import "../SharedManager/SharedManager.h"

@interface SettingsView : UIView

@property (nonatomic, assign) UIViewController *presentingViewController;
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIButton *backButton;

- (instancetype)initWithFrame:(CGRect)frame presentingViewController:(UIViewController *)viewController;
- (void)backButtonTapped;
- (void)saveSwitchStates;
- (void)loadSwitchStates;
- (UILabel *)findLabelForSwitch:(UISwitch *)Switch;
- (void)addSwitch:(UIView *)parentView frame:(CGRect)frame switchName:(NSString *)name description:(NSString *)description;


@end