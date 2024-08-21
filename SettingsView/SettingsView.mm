#import "SettingsView.h"

@implementation SettingsView

- (instancetype)initWithFrame:(CGRect)frame presentingViewController:(UIViewController *)viewController isGlobal:(BOOL)isGlobal {
    self = [super initWithFrame:frame];
    _languages = [Languages sharedInstance];
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
        [backButton setTitle:[_languages localizedStringForKey:@"Save"] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:backButton];

        [self addSubview:headerView];

        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60)];

        [self addSwitch:_bodyView frame:CGRectMake(10, 10, frame.size.width, 40) switchKey:@"ToggleBackground" switchName:[_languages localizedStringForKey:@"Toggle Background"] description:[_languages localizedStringForKey:@"Enable or disable the background"]];

        [self addSlider:_bodyView frame:CGRectMake(10, 60, frame.size.width, 40) sliderKey:@"HeaderFooterOpacity" sliderName:[_languages localizedStringForKey:@"Header & Footer Opacity"] description:[_languages localizedStringForKey:@"Adjust the opacity of the header and footer"]];

        [self addSlider:_bodyView frame:CGRectMake(10, 140, frame.size.width, 40) sliderKey:@"BackgroundOpacity" sliderName:[_languages localizedStringForKey:@"Background Opacity"] description:[_languages localizedStringForKey:@"Adjust the opacity of the background"]];

        [self addSwitch:_bodyView frame:CGRectMake(10, 220, frame.size.width, 40) switchKey:@"BlackOverlay" switchName:[_languages localizedStringForKey:@"Black Overlay"] description:[_languages localizedStringForKey:@"Enable or disable the black overlay"]];

        if (isGlobal) {
            [self addSwitch:_bodyView frame:CGRectMake(10, 270, frame.size.width, 40) switchKey:@"ToggleBackgroundMessenger" switchName:[_languages localizedStringForKey:@"Toggle Background Messenger"] description:[_languages localizedStringForKey:@"Enable or disable the background Messenger"]];

            [self addSwitch:_bodyView frame:CGRectMake(10, 320, frame.size.width, 40) switchKey:@"ToggleOnlyMainBackground" switchName:[_languages localizedStringForKey:@"Toggle only main background"] description:[_languages localizedStringForKey:@"Enable or disable the main background"]];

            [self addCredits:_bodyView frame:CGRectMake(0, 370, frame.size.width, 40) credits:@"© 2024 MessBG by tien0246 with ❤️\nUwU"];
        } else {
            [self addCredits:_bodyView frame:CGRectMake(0, 270, frame.size.width, 40) credits:@"© 2024 MessBG by tien0246 with ❤️\nUwU"];
        }

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
            NSString *switchKey = objc_getAssociatedObject(aSwitch, &kKey);
            if (switchKey) {
                [switchStates setObject:@(aSwitch.isOn) forKey:switchKey];
            }
        } else if ([subview isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)subview;
            NSString *sliderKey = objc_getAssociatedObject(slider, &kKey);
            if (sliderKey) {
                [switchStates setObject:@(slider.value) forKey:sliderKey];
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
            NSString *switchKey = objc_getAssociatedObject(Switch, &kKey);
            NSNumber *switchState = [switchStates objectForKey:switchKey];
            if (switchState) {
                Switch.on = [switchState boolValue];
            }
        } else if ([subview isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)subview;
            NSString *sliderKey = objc_getAssociatedObject(slider, &kKey);
            NSNumber *sliderValue = [switchStates objectForKey:sliderKey];
            if (sliderValue) {
                slider.value = [sliderValue floatValue];
            }
        }
    }
}

- (void)addSwitch:(UIView *)parentView frame:(CGRect)frame switchKey:(NSString *)key switchName:(NSString *)name description:(NSString *)description {
    CGFloat switchWidth = 51.0;
    CGFloat switchHeight = 31.0;

    UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width - switchWidth - 20, frame.origin.y + (frame.size.height - switchHeight) / 2, switchWidth, switchHeight)];
    objc_setAssociatedObject(toggleSwitch, &kKey, key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

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

- (void)addSlider:(UIView *)parentView frame:(CGRect)frame sliderKey:(NSString *)key sliderName:(NSString *)name description:(NSString *)description {
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, frame.origin.y + 10, frame.size.width - 40, 20)];
    objc_setAssociatedObject(slider, &kKey, key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [parentView addSubview:slider];

    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(slider.frame) + 5, frame.size.width - 40, 20)];
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

- (void)addCredits:(UIView *)parentView frame:(CGRect)frame credits:(NSString *)credits {
    UILabel *creditsLabel = [[UILabel alloc] initWithFrame:frame];
    creditsLabel.text = credits;
    creditsLabel.numberOfLines = 0;
    creditsLabel.textColor = [UIColor secondaryLabelColor];
    creditsLabel.font = [UIFont systemFontOfSize:12];
    creditsLabel.textAlignment = NSTextAlignmentCenter;
    [parentView addSubview:creditsLabel];
}

@end