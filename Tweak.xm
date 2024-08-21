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
		BOOL isBackgroundEnabled = [[switchStates objectForKey:@"ToggleBackground"] boolValue];
		if (isBackgroundEnabled) {
            NSString *imagePath = [documentsPath stringByAppendingPathComponent: (headerName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", headerName]]]) ? [NSString stringWithFormat:@"image/%@", headerName] : @"image/0"];
            CGFloat alpha = [[switchStates objectForKey:@"BackgroundOpacity"] floatValue] * 25;
            BOOL isBlacked = [[switchStates objectForKey:@"BlackOverlay"] boolValue];
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            CGRect screenBounds = [UIScreen mainScreen].bounds;

            CIImage *ciImage = [[CIImage alloc] initWithImage:image];

            CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [blurFilter setValue:ciImage forKey:kCIInputImageKey];
            [blurFilter setValue:@(alpha) forKey:kCIInputRadiusKey];

            CIImage *outputCIImage = [blurFilter outputImage];
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:[ciImage extent]];

            UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);

            UIImageView *imageView = [[UIImageView alloc] initWithImage:blurredImage];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.frame = screenBounds;
            [self addSubview:imageView];

            if (isBlacked) {
                UIView *blackOverlay = [[UIView alloc] initWithFrame:screenBounds];
                blackOverlay.backgroundColor = [UIColor secondarySystemBackgroundColor];
                blackOverlay.alpha = 0.3;
                [imageView addSubview:blackOverlay];
            }
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

            UIAlertAction *customBackgroundAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Settings"]
                                                                            style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *action) {
                if (keyWindow) {
                    UIViewController *rootViewController = keyWindow.rootViewController;
                    SettingsView *settingsView = [[SettingsView alloc] initWithFrame:rootViewController.view.bounds
                                                                    presentingViewController:rootViewController
                                                                    isGlobal:YES];
                    UIViewController *settingsViewController = [[UIViewController alloc] init];
                    settingsViewController.view = settingsView;
                    [rootViewController presentViewController:settingsViewController animated:YES completion:nil];
                }
            }];

            UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Change Image"]
                                                                    style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
                [[ImagePickerManager sharedManager] presentImagePickerFromViewController:keyWindow.rootViewController];
            }];

            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Delete Image"]
                                                                style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:@"image/0"] error:nil];

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *key = @"SwitchStates";
                [defaults removeObjectForKey:key];
                [defaults synchronize];
            }];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Cancel"]
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

        UIAlertAction *customBackgroundAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Settings"]
                                                                        style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
            if (keyWindow) {
                UIViewController *rootViewController = keyWindow.rootViewController;
                SettingsView *settingsView = [[SettingsView alloc] initWithFrame:rootViewController.view.bounds
                                                                presentingViewController:rootViewController
                                                                isGlobal:NO];
                UIViewController *settingsViewController = [[UIViewController alloc] init];
                settingsViewController.view = settingsView;
                [rootViewController presentViewController:settingsViewController animated:YES completion:nil];
            }
        }];

        UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Change Image"]
                                                                style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
            [[ImagePickerManager sharedManager] presentImagePickerFromViewController:keyWindow.rootViewController];
        }];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Delete Image"]
                                                            style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *action) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", [SharedManager sharedInstance].tempName]] error:nil];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *key = [SharedManager sharedInstance].tempName;
            [defaults removeObjectForKey:key];
            [defaults synchronize];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey :@"Cancel"]
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
            CGFloat alpha = [[switchStates objectForKey:@"HeaderFooterOpacity"] floatValue];
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
            CGFloat alpha = [[switchStates objectForKey:@"HeaderFooterOpacity"] floatValue];
            if (headerName) {
                self.alpha = alpha;
            }
        }
        return self;
    }
%end


/* ~~~~~~~~ Custom Background Home ~~~~~~~~ */
%hook UITableViewCellContentView
    - (void)setBackgroundColor:(UIColor *)arg1 {
        arg1 = [UIColor clearColor];
        %orig;
    }
%end

%hook UICollectionView
    - (void)setBackgroundColor:(UIColor *)arg1 {
        if (self.superview &&
        ([self.superview isKindOfClass:NSClassFromString(@"MDSSegmentedControl")] ||
        [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellContentView")])) {
            arg1 = [UIColor clearColor];
        }
        %orig;
    }
%end

%hook UIView
    - (void)setBackgroundColor:(UIColor *)arg1 {
        if (self.superview &&
        [self.superview isKindOfClass:NSClassFromString(@"UITableView")]) {
            arg1 = [UIColor clearColor];
        }
        %orig;
    }
%end

%hook _UIVisualEffectContentView
    - (void)setBackgroundColor:(UIColor *)arg1 {
        if (self.superview &&
        [self.superview isKindOfClass:NSClassFromString(@"UIVisualEffectView")] &&
        self.subviews.count == 0 &&
        self.frame.origin.x == 0 &&
        self.frame.origin.y == 0 &&
        self.frame.size.width == [UIScreen mainScreen].bounds.size.width) {
            arg1 = [UIColor clearColor];
        }
        %orig;
    }
%end

%hook UITableView
    BOOL isAddBackGround = NO;
    - (void)addSubview:(UIView *)arg1 {
        %orig;

        NSDictionary *switchStates = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SwitchStates"];
        BOOL isBackgroundEnabled = [[switchStates objectForKey:@"ToggleBackgroundMessenger"] boolValue];
        BOOL isOnlyHome = [[switchStates objectForKey:@"ToggleOnlyMainBackground"] boolValue];
        if (!isAddBackGround && isBackgroundEnabled) {
            if (isOnlyHome) isAddBackGround = YES;
            NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"image/0"];
            CGFloat alpha = [[switchStates objectForKey:@"BackgroundOpacity"] floatValue] * 25;
            BOOL isBlacked = [[switchStates objectForKey:@"BlackOverlay"] boolValue];

            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            CIImage *ciImage = [[CIImage alloc] initWithImage:image];
            CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [blurFilter setValue:ciImage forKey:kCIInputImageKey];
            [blurFilter setValue:@(alpha) forKey:kCIInputRadiusKey];

            CIImage *outputCIImage = [blurFilter outputImage];
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:[ciImage extent]];

            UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);

            UIImageView *imageView = [[UIImageView alloc] initWithImage:blurredImage];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.frame = [UIScreen mainScreen].bounds;
            self.backgroundView = imageView;
            self.backgroundColor = [UIColor clearColor];

            if (isBlacked) {
                UIView *blackOverlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
                blackOverlay.backgroundColor = [UIColor secondarySystemBackgroundColor];
                blackOverlay.alpha = 0.3;
                [imageView addSubview:blackOverlay];
            }
        }
    }
%end

/* ~~~~~~~~ Hidden feature ~~~~~~~~ */
%hook NSNotificationCenter
    - (void)postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
        if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"]) {
            return;
        }
        %orig;
    }
%end

%hook UIScreen
    - (BOOL)isCaptured {
        return NO;
    }
%end


/* ~~~~~~~~ Fix border radius black but it added more bugs ~_~ nah, skip it ~~~~~~~~ */
// %hook MDSTheme
//     int count = 0;
//     - (id)colorForMDSColor:(long long)arg1 forTraitCollection:(id)arg2 {
//         if (arg1 == 10051 && arg2 != nil && count > 50) {
//             NSLog(@"MDSTheme: %@", arg2);
//             arg1 = 10000;
//         } else if (arg1 == 10051 && arg2 != nil) {
//             count++;
//         }
//         return %orig;
//     }
// %end
// %hook LSView
// - (void)layoutSubviews {
//     %orig;
//     if (self.superview &&
//     [self.superview isKindOfClass:NSClassFromString(@"MSGMessageBodyView")] &&
//     self.subviews.count == 2 &&
//     self.subviews[0].hidden == NO &&
//     self.subviews[0].clipsToBounds == NO) {
//         UIImageView *subview2 = self.subviews[1];
//         UIImage *image = subview2.image;
//         CGImageRef imageRef = [image CGImage];
//         CGContextRef context = CGBitmapContextCreate(NULL, 1, 1, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
//         CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), imageRef);
//         const UInt8 *data = (const UInt8 *)CGBitmapContextGetData(context);
//         if (data[3] == 255) return;

//         UIView *subview1 = self.subviews[0];
//         UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:subview1.bounds
//                                                          byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight)
//                                                                cornerRadii:CGSizeMake(12.0, 12.0)];
//         CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//         maskLayer.frame = subview1.bounds;
//         maskLayer.path = roundedPath.CGPath;
//         subview1.layer.mask = maskLayer;
//     }
// }
// %end



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