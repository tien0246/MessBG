#import "SettingsView.h"

@implementation SettingsView

- (instancetype)initWithFrame:(CGRect)frame presentingViewController:(UIViewController *)viewController {
    self = [super initWithFrame:frame];
    if (self) {
        self.presentingViewController = viewController;

        self.backgroundColor = [UIColor systemBackgroundColor];

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        headerView.backgroundColor = [UIColor secondarySystemBackgroundColor];

        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        headerLabel.text = @"MessBG";
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.textColor = [UIColor labelColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        [headerView addSubview:headerLabel];

        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        backButton.frame = CGRectMake(0, 0, frame.size.width - 20, 60);
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [backButton setTitle:@"Save" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:backButton];

        [self addSubview:headerView];

        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60)];

        [self addSwitch:_bodyView frame:CGRectMake(10, 10, frame.size.width, 40) switchName:@"Toggle Background" description:@"Enable or disable the background"];

        [self addSlider:_bodyView frame:CGRectMake(10, 60, frame.size.width, 40) sliderName:@"Header & Footer Opacity" description:@"Adjust the opacity of the header and footer"];

        [self addSubview:_bodyView];

        [self loadSwitchStates];
    }
    return self;
}

- (void)backButtonTapped {
    [self saveSwitchStates];
    [self removeFromSuperview];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSwitchStates {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [[SharedManager sharedInstance] hasImage] ? [SharedManager sharedInstance].tempName : @"SwitchStates";
    NSMutableDictionary *switchStates = [[defaults dictionaryForKey:key] mutableCopy] ?: [NSMutableDictionary dictionary];

    for (UIView *subview in self.bodyView.subviews) {
        if ([subview isKindOfClass:[UISwitch class]]) {
            UISwitch *aSwitch = (UISwitch *)subview;
            UILabel *label = [self findLabelForSwitch:aSwitch];
            if (label) {
                NSString *labelText = label.text;
                if (labelText) {
                    [switchStates setObject:@(aSwitch.isOn) forKey:labelText];
                }
            }
        } else if ([subview isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)subview;
            UILabel *label = [self findLabelForSlider:slider];
            if (label) {
                NSString *labelText = label.text;
                if (labelText) {
                    [switchStates setObject:@(slider.value) forKey:labelText];
                }
            }
        }
    }

    [defaults setObject:switchStates forKey:key];
    [defaults synchronize];
}


- (void)loadSwitchStates {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [[SharedManager sharedInstance] hasImage] ? [SharedManager sharedInstance].tempName : @"SwitchStates";
    NSDictionary *switchStates = [defaults dictionaryForKey:key];

    for (UIView *subview in self.bodyView.subviews) {
        if ([subview isKindOfClass:[UISwitch class]]) {
            UISwitch *Switch = (UISwitch *)subview;
            UILabel *label = [self findLabelForSwitch:Switch];
            if (label) {
                NSString *labelText = label.text;
                NSNumber *switchState = [switchStates objectForKey:labelText];
                if (switchState) {
                    Switch.on = [switchState boolValue];
                }
            }
        } else if ([subview isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)subview;
            UILabel *label = [self findLabelForSlider:slider];
            if (label) {
                NSString *labelText = label.text;
                NSNumber *sliderValue = [switchStates objectForKey:labelText];
                if (sliderValue) {
                    slider.value = [sliderValue floatValue];
                }
            }
        }
    }
}

- (UILabel *)findLabelForSwitch:(UISwitch *)Switch {
    UIView *parentView = Switch.superview;
    
    for (int i = 0; i < parentView.subviews.count - 1; i++) {
        UIView *subview = parentView.subviews[i];
        UIView *nextSubview = parentView.subviews[i + 1];
        if ([nextSubview isKindOfClass:[UILabel class]] && [subview isKindOfClass:[UISwitch class]] && subview == Switch) {
            return (UILabel *)nextSubview;
        }
    }
    return nil;
}

- (UILabel *)findLabelForSlider:(UISlider *)slider {
    UIView *parentView = slider.superview;
    
    for (int i = 0; i < parentView.subviews.count - 1; i++) {
        UIView *subview = parentView.subviews[i];
        UIView *nextSubview = parentView.subviews[i + 1];
        if ([nextSubview isKindOfClass:[UILabel class]] && [subview isKindOfClass:[UISlider class]] && subview == slider) {
            return (UILabel *)nextSubview;
        }
    }
    return nil;
}

- (void)addSwitch:(UIView *)parentView frame:(CGRect)frame switchName:(NSString *)name description:(NSString *)description {
    CGFloat switchWidth = 51.0;
    CGFloat switchHeight = 31.0;

    UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width - switchWidth - 20, frame.origin.y + (frame.size.height - switchHeight) / 2, switchWidth, switchHeight)];
    [parentView addSubview:toggleSwitch];

    UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, frame.origin.y + (frame.size.height - switchHeight) / 2, frame.size.width - switchWidth - 20, 20)];
    switchLabel.text = name;
    switchLabel.textColor = [UIColor labelColor];
    switchLabel.font = [UIFont systemFontOfSize:16];
    [parentView addSubview:switchLabel];

    UILabel *switchDescription = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(switchLabel.frame) + 2, frame.size.width - switchWidth - 20, 20)];
    switchDescription.text = description;
    switchDescription.textColor = [UIColor secondaryLabelColor];
    switchDescription.font = [UIFont systemFontOfSize:12];
    [parentView addSubview:switchDescription];
}

- (void)addSlider:(UIView *)parentView frame:(CGRect)frame sliderName:(NSString *)name description:(NSString *)description {
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, frame.origin.y + 10, frame.size.width - 40, 20)];
    [parentView addSubview:slider];

    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(slider.frame) + 2, frame.size.width - 40, 20)];
    sliderLabel.text = name;
    sliderLabel.textColor = [UIColor labelColor];
    sliderLabel.font = [UIFont systemFontOfSize:16];
    [parentView addSubview:sliderLabel];

    UILabel *sliderDescription = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(sliderLabel.frame) + 2, frame.size.width - 40, 20)];
    sliderDescription.text = description;
    sliderDescription.textColor = [UIColor secondaryLabelColor];
    sliderDescription.font = [UIFont systemFontOfSize:12];
    [parentView addSubview:sliderDescription];
}

@end