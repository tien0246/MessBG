#import "Tweak.h"

NSString *headerName;

@implementation Tweak
+ (instancetype)sharedInstance {
    static Tweak *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Tweak alloc] init];
    });
    return sharedInstance;
}

- (NSComparisonResult)compareVersion:(NSString *)version1 withVersion:(NSString *)version2 {
    NSArray *version1Components = [version1 componentsSeparatedByString:@"."];
    NSArray *version2Components = [version2 componentsSeparatedByString:@"."];
    
    NSUInteger count = MAX(version1Components.count, version2Components.count);
    
    for (NSUInteger i = 0; i < count; i++) {
        NSInteger v1 = (i < version1Components.count) ? [version1Components[i] integerValue] : 0;
        NSInteger v2 = (i < version2Components.count) ? [version2Components[i] integerValue] : 0;

        if (v1 > v2) {
            return NSOrderedDescending;
        } else if (v1 < v2) {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}
@end

%hook MSGMessageListView
    - (void)setDelegate:(id)arg1 {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *key = headerName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", headerName]]] ? headerName : @"SwitchStates";
        NSDictionary *switchStates = [defaults dictionaryForKey:key];
		BOOL isBackgroundEnabled = [[switchStates objectForKey:@"Toggle Background"] boolValue];
		if (isBackgroundEnabled) {
            NSString *imagePath = [documentsPath stringByAppendingPathComponent: (headerName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", headerName]]]) ? [NSString stringWithFormat:@"image/%@", headerName] : @"image/0"];


			UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
			CGRect screenBounds = [UIScreen mainScreen].bounds;
			
			UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
			imageView.contentMode = UIViewContentModeScaleAspectFill;
			imageView.clipsToBounds = YES;
			imageView.frame = screenBounds;
			[self addSubview:imageView];
		}
		%orig;
	}
%end

%hook UIButton
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
        %orig;
        if (self.frame.origin.x == 0 &&
            self.frame.origin.y == 0 &&
            self.superview &&
            [self.superview isKindOfClass:NSClassFromString(@"_UITAMICAdaptorView")]) {
            [SharedManager sharedInstance].tempName = nil;
            UIWindow *keyWindow = nil;
            for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    keyWindow = windowScene.windows.firstObject;
                    break;
                }
            }

            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MessBG\ntien0246"
                                                                                message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];

            UIAlertAction *customBackgroundAction = [UIAlertAction actionWithTitle:@"Settings"
                                                                            style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *action) {
                if (keyWindow) {
                    UIViewController *rootViewController = keyWindow.rootViewController;
                    SettingsView *settingsView = [[SettingsView alloc] initWithFrame:rootViewController.view.bounds
                                                                    presentingViewController:rootViewController];
                    UIViewController *settingsViewController = [[UIViewController alloc] init];
                    settingsViewController.view = settingsView;
                    [rootViewController presentViewController:settingsViewController animated:YES completion:nil];
                }
            }];

            UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:@"Change Image"
                                                                    style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
                [[ImagePickerManager sharedManager] presentImagePickerFromViewController:keyWindow.rootViewController];
            }];

            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Image"
                                                                style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:@"image/0"] error:nil];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *key = @"SwitchStates";
                [defaults removeObjectForKey:key];
                [defaults synchronize];
            }];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                style:UIAlertActionStyleCancel
                                                                handler:nil];
            [actionSheet addAction:customBackgroundAction];
            [actionSheet addAction:pickImageAction];
            [actionSheet addAction:deleteAction];
            [actionSheet addAction:cancelAction];

            if (keyWindow) {
                [keyWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];
            }
        }
    }
%end

%hook UIStackView
    BOOL isCustomButton = NO;
    %new
    - (void)customButtonTapped {
        UIWindow *keyWindow = nil;
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                keyWindow = windowScene.windows.firstObject;
                break;
            }
        }

        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MessBG\ntien0246"
                                                                            message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *customBackgroundAction = [UIAlertAction actionWithTitle:@"Settings"
                                                                        style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
            if (keyWindow) {
                UIViewController *rootViewController = keyWindow.rootViewController;
                SettingsView *settingsView = [[SettingsView alloc] initWithFrame:rootViewController.view.bounds
                                                                presentingViewController:rootViewController];
                UIViewController *settingsViewController = [[UIViewController alloc] init];
                settingsViewController.view = settingsView;
                [rootViewController presentViewController:settingsViewController animated:YES completion:nil];
            }
        }];

        UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:@"Change Image"
                                                                style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
            [[ImagePickerManager sharedManager] presentImagePickerFromViewController:keyWindow.rootViewController];
        }];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Image"
                                                            style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *action) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", [SharedManager sharedInstance].tempName]] error:nil];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *key = [SharedManager sharedInstance].tempName;
            [defaults removeObjectForKey:key];
            [defaults synchronize];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                            handler:nil];

        [actionSheet addAction:customBackgroundAction];
        [actionSheet addAction:pickImageAction];
        [actionSheet addAction:deleteAction];
        [actionSheet addAction:cancelAction];

        if (keyWindow) {
            [keyWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];
        }
    }

    - (void)layoutSubviews {
        %orig;
        if (self.superview && 
        [self.superview isKindOfClass:NSClassFromString(@"MDSHorizontalStackItemCell")]
        && !isCustomButton) {
            UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];

            [customButton setTitle:@"MeesBG" forState:UIControlStateNormal];
            [customButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
            customButton.titleLabel.font = [UIFont systemFontOfSize:12];

            CGFloat buttonWidth = customButton.titleLabel.intrinsicContentSize.width;
            CGFloat buttonHeight = self.frame.size.height;
            CGFloat spacing = 30;
            customButton.frame = CGRectMake(self.frame.size.width + spacing, 0, buttonWidth, buttonHeight);

            UIImage *icon = [UIImage systemImageNamed:@"pencil.circle.fill"];
            UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
            iconView.frame = CGRectMake((buttonWidth - 40) / 2, 0, 40, 40);
            iconView.tintColor = [UIColor labelColor];
            [customButton addSubview:iconView];

            customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            customButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

            customButton.titleEdgeInsets = UIEdgeInsetsMake(buttonHeight - customButton.titleLabel.intrinsicContentSize.height, -customButton.imageView.frame.size.width, 0, 0);

            [customButton addTarget:self action:@selector(customButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:customButton];
            self.frame = CGRectMake(self.frame.origin.x - (buttonWidth + spacing) / 2, self.frame.origin.y, self.frame.size.width + buttonWidth + spacing, self.frame.size.height);
            isCustomButton = YES;
        }
    }

    -(void)dealloc { // BIG PROBLEM: it's not work but i still keep it here UwU
        if (isCustomButton && self.subviews.count == 3) {
            isCustomButton = NO;
        }
        headerName = nil;
        %orig;
    }
%end

%hook MDSLabel
    -(void)setText:(NSString *)arg1 {
        %orig;
        if (self.superview && [self.superview isKindOfClass:NSClassFromString(@"MDSListLabel")]) {
            [SharedManager sharedInstance].tempName = arg1;
        } else if (self.superview && [self.superview isKindOfClass:NSClassFromString(@"UIStackView")]) {
            headerName = arg1;
        }
    }
%end

/* ~~~~~~~~ Header & Footer Opacity ~~~~~~~~ */
%hook _UIBarBackground
    - (void)setLayout:(id)arg1 {
        %orig;
        if (self.frame.origin.x == 0 &&
            self.frame.origin.y < 0 &&
            self.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *key = headerName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", headerName]]] ? headerName : @"SwitchStates";
            NSDictionary *switchStates = [defaults dictionaryForKey:key];
            CGFloat alpha = [[switchStates objectForKey:@"Header & Footer Opacity"] floatValue];
            NSLog(@"[MessBG] Name: %@, Alpha: %f", headerName, alpha);
            if (headerName) {
                self.alpha = alpha;
            }
        }
    }
%end

%hook MDSBlurView
    - (id)initWithBlurViewStyle:(long long)arg1 {
        self = %orig;
        if (self &&
            arg1 == 2) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *key = headerName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", headerName]]] ? headerName : @"SwitchStates";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *switchStates = [defaults dictionaryForKey:key];
            CGFloat alpha = [[switchStates objectForKey:@"Header & Footer Opacity"] floatValue];
            if (headerName) {
                self.alpha = alpha;
            }
        }
        return self;
    }
%end

%ctor {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if ([[Tweak sharedInstance] compareVersion:appVersion withVersion:@"445.0.0"] == NSOrderedAscending) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MessBG\ntien0246"
                                                                               message:@"This tweak only supports Messenger version 445.0.0 and above."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:nil];
                [alert addAction:okAction];

                UIWindow *alertWindow = nil;
                for (UIWindowScene *windowScene in [UIApplication.sharedApplication connectedScenes]) {
                    if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                        alertWindow = windowScene.windows.firstObject;
                        break;
                    }
                }
                if (alertWindow) {
                    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                }
            });
        }
    });
}