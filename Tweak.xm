#import "Tweak.h"

/*
    0 - Light
    1 - Dark
*/

@implementation CustomButton
    - (CGSize)intrinsicContentSize {
        CGSize imageSize = CGSizeMake(40, 40);
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeZero];
        
        CGFloat totalHeight = imageSize.height + titleSize.height + 4;
        CGFloat totalWidth = MAX(imageSize.width, titleSize.width);
        
        return CGSizeMake(totalWidth, totalHeight);
    }
    - (void)layoutSubviews {
        [super layoutSubviews];

        UIImageView *iconView = self.subviews.lastObject;
        UILabel *titleLabel = self.titleLabel;

        CGFloat totalWidth = self.bounds.size.width;

        iconView.center = CGPointMake(totalWidth / 2, iconView.frame.size.height / 2);

        CGRect titleFrame = titleLabel.frame;
        titleFrame.origin.x = (totalWidth - titleFrame.size.width) / 2;
        titleLabel.frame = titleFrame;
    }
@end

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

    - (void)showActionSheetInView:(UIView *)view isGlobal:(BOOL)isGlobal {
        UIWindow *keyWindow = nil;
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                keyWindow = windowScene.windows.firstObject;
                break;
            }
        }
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"MessBG"
                                                                            message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *customBackgroundAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey:@"Settings"]
                                                                        style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction *action) {
            if (keyWindow) {
                UIViewController *rootViewController = keyWindow.rootViewController;
                SettingsView *settingsView = [[SettingsView alloc] initWithFrame:rootViewController.view.bounds
                                                        presentingViewController:rootViewController
                                                                        isGlobal:isGlobal];
                UIViewController *settingsViewController = [[UIViewController alloc] init];
                settingsViewController.view = settingsView;
                [rootViewController presentViewController:settingsViewController animated:YES completion:nil];
            }
        }];
        
        UIAlertAction *pickImageAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey:@"Change Image"]
                                                                style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
            [[ImagePickerManager sharedManager] presentImagePickerFromViewController:keyWindow.rootViewController];
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey:@"Delete Image"]
                                                            style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *action) {
            [[NSFileManager defaultManager] removeItemAtPath:[self imagePath] error:nil];
        }];

        UIAlertAction *deleteImageFolderAction = nil;
        if (isGlobal) {
            deleteImageFolderAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey:@"Delete Image Folder"]
                                                                style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:@"image"] error:nil];
            }];
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[[Languages sharedInstance] localizedStringForKey:@"Cancel"]
                                                            style:UIAlertActionStyleCancel
                                                            handler:nil];
        
        [actionSheet addAction:customBackgroundAction];
        [actionSheet addAction:pickImageAction];
        [actionSheet addAction:deleteAction];
        if (isGlobal) [actionSheet addAction:deleteImageFolderAction];
        [actionSheet addAction:cancelAction];
        
        if (keyWindow) {
            [keyWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];
        }
    }

    - (UIButton *)createSettingButton {
        UIButton *settingButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [settingButton setTitle:@"MeesBG" forState:UIControlStateNormal];
        [settingButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
        settingButton.titleLabel.font = [UIFont systemFontOfSize:12];
        settingButton.tag = 9999;

        CGFloat iconSize = 40.0;

        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        backgroundView.backgroundColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:58/245.0]; // I'm trying calculate it but it's not same with original color :((
        backgroundView.layer.cornerRadius = iconSize / 2;
        backgroundView.userInteractionEnabled = NO;

        UIImage *icon = [[UIImage systemImageNamed:@"pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.tintColor = [UIColor labelColor];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.frame = CGRectMake(8, 8, iconSize - 16, iconSize - 16);
        iconView.userInteractionEnabled = NO;

        [backgroundView addSubview:iconView];
        [settingButton addSubview:backgroundView];

        settingButton.titleEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(backgroundView.frame) + 4, -CGRectGetWidth(backgroundView.frame), 0, 0);

        return settingButton;
    }

    // I wrote it, but now idk how it works :) if theme is light, it will return 0, else return 1, but if image 0 not exist, it will return remaining image
    - (NSString *)imagePath {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

        NSString *defaultImageKey = [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[SharedManager sharedInstance].isLightMode ? @"image/0" : @"image/1"]] ?
            [SharedManager sharedInstance].isLightMode ? @"image/0" : @"image/1" :
            [SharedManager sharedInstance].isLightMode ? @"image/1" : @"image/0";
        
        NSString *headerPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", [SharedManager sharedInstance].tempName]];
        headerPath = [[NSFileManager defaultManager] fileExistsAtPath:[headerPath stringByAppendingString:[SharedManager sharedInstance].isLightMode ? @"0" : @"1"]] ?
            [headerPath stringByAppendingString:[SharedManager sharedInstance].isLightMode ? @"0" : @"1"] :
            [headerPath stringByAppendingString:[SharedManager sharedInstance].isLightMode ? @"1" : @"0"];

        return ([SharedManager sharedInstance].tempName && [[NSFileManager defaultManager] fileExistsAtPath:headerPath]) ? headerPath : [documentsPath stringByAppendingPathComponent:defaultImageKey];
    }

    - (UIImage *)blurredImageWithPath:(NSString *)imagePath alpha:(CGFloat)alpha {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (!image) {
            return nil;
        }

        CIImage *ciImage = [[CIImage alloc] initWithImage:image];
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setValue:ciImage forKey:kCIInputImageKey];
        [blurFilter setValue:@(alpha) forKey:kCIInputRadiusKey];

        CIImage *outputCIImage = [blurFilter outputImage];
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:[ciImage extent]];

        UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);

        return blurredImage;
    }

    - (UIView *)createBlackOverlayWithFrame:(CGRect)frame alpha:(CGFloat)alpha {
        UIView *blackOverlay = [[UIView alloc] initWithFrame:frame];
        blackOverlay.backgroundColor = [UIColor secondarySystemBackgroundColor];
        blackOverlay.alpha = alpha;
        return blackOverlay;
    }

    - (void)applyBackgroundImage:(UIImage *)image withOverlay:(UIView *)overlay toView:(UIView *)view {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.frame = [UIScreen mainScreen].bounds;
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.backgroundView = imageView;
            tableView.backgroundColor = [UIColor clearColor];
        } else {
            if ([view.subviews.firstObject isKindOfClass:NSClassFromString(@"UIImageView")]) {
                [view.subviews.firstObject removeFromSuperview];
            }
            [view insertSubview:imageView atIndex:0];
        }
        if (overlay) {
            [imageView addSubview:overlay];
        }
    }

    - (void)changeBackground:(UIView *)view {
        NSString *key = [[SharedManager sharedInstance] hasImage] ? [SharedManager sharedInstance].tempName : @"SwitchStates";
        NSDictionary *switchStates = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
        // NSLog(@"key: %@", key);
        BOOL isBackgroundEnabled = [[switchStates objectForKey:@"ToggleBackground"] boolValue];

        if ([view isKindOfClass:[UITableView class]]) {
            switchStates = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SwitchStates"];
            isBackgroundEnabled = [[switchStates objectForKey:@"ToggleBackgroundMessenger"] boolValue];
            [SharedManager sharedInstance].tempName = nil;
        }
        
        if (isBackgroundEnabled) {
            NSString *imagePath = [self imagePath];
            CGFloat alpha = [[switchStates objectForKey:@"BackgroundOpacity"] floatValue] * 25;
            BOOL isBlacked = [[switchStates objectForKey:@"BlackOverlay"] boolValue];

            UIImage *blurredImage = [self blurredImageWithPath:imagePath alpha:alpha];
            UIView *blackOverlay = isBlacked ? [self createBlackOverlayWithFrame:[UIScreen mainScreen].bounds alpha:0.3] : nil;

            [self applyBackgroundImage:blurredImage withOverlay:blackOverlay toView:view];
        }
    }
@end

%hook MSGMessageListView
    - (void)setDelegate:(id)arg1 {
		%orig;
        [[Tweak sharedInstance] changeBackground:self];
	}

    - (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
        %orig;
        if ([SharedManager sharedInstance].isLightMode != self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ||
            self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
            [[Tweak sharedInstance] changeBackground:self];
        }
    }
%end

%hook UITabBar
    - (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
        NSMutableArray *newItems = [items mutableCopy];
        UITabBarItem *menuTabBarItem = [[UITabBarItem alloc] initWithTitle:@"MessBG"
                                                                    image:[UIImage systemImageNamed:@"pencil.circle.fill"]
                                                                    tag:9999];

        [newItems addObject:menuTabBarItem];

        %orig(newItems, animated);
    }

    - (void)setSelectedItem:(UITabBarItem *)selectedItem {
        %orig(selectedItem);
        if (selectedItem.tag == 9999) {
            [SharedManager sharedInstance].tempName = nil;
            [[Tweak sharedInstance] showActionSheetInView:self isGlobal:YES];
        }
    }
%end

%hook UIStackView
    %new
    - (void)settingButtonTapped {
        [[Tweak sharedInstance] showActionSheetInView:self isGlobal:NO];
    }

    - (void)layoutSubviews {
        %orig;

        UIButton *settingButton = [self viewWithTag:9999];
        if (self.superview && 
            [self.superview isKindOfClass:NSClassFromString(@"MDSHorizontalStackItemCell")]
            && !settingButton) {

            settingButton = [[Tweak sharedInstance] createSettingButton];
            [settingButton addTarget:self action:@selector(settingButtonTapped) forControlEvents:UIControlEventTouchUpInside];

            [self addArrangedSubview:settingButton];
        }
    }
%end

%hook MDSLabel
    - (void)setText:(NSString *)arg1 {
        %orig;
        if (self.superview &&
        ([self.superview isKindOfClass:NSClassFromString(@"MDSListLabel")] ||
        ([self.superview isKindOfClass:NSClassFromString(@"UIStackView")] &&
        self.superview.subviews.count == 2))) {
            [SharedManager sharedInstance].tempName = arg1;
        }
    }

    - (void)dealloc {
        if (self.text == [SharedManager sharedInstance].tempName) {
            [SharedManager sharedInstance].tempName = nil;
        }
        %orig;
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
            NSString *key = [SharedManager sharedInstance].tempName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", [SharedManager sharedInstance].tempName]]] ? [SharedManager sharedInstance].tempName : @"SwitchStates";
            NSDictionary *switchStates = [defaults dictionaryForKey:key];
            CGFloat alpha = [[switchStates objectForKey:@"HeaderFooterOpacity"] floatValue];
            if ([SharedManager sharedInstance].tempName) {
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
            NSString *key = [SharedManager sharedInstance].tempName && [[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", [SharedManager sharedInstance].tempName]]] ? [SharedManager sharedInstance].tempName : @"SwitchStates";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *switchStates = [defaults dictionaryForKey:key];
            CGFloat alpha = [[switchStates objectForKey:@"HeaderFooterOpacity"] floatValue];
            if ([SharedManager sharedInstance].tempName) {
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
    NSMutableSet *views = [NSMutableSet set];
    - (void)layoutSubviews {
        %orig;

        if ([views containsObject:self]) return;

        BOOL isOnlyHome = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SwitchStates"] objectForKey:@"ToggleOnlyMainBackground"] boolValue];

        if (!isAddBackGround) {
            if (isOnlyHome) isAddBackGround = YES;
            [[Tweak sharedInstance] changeBackground:self];
            [views addObject:self];
        }
    }

    - (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
        %orig;
        if ([views containsObject:self]) {
            // if (![self isKindOfClass:NSClassFromString(@"MSGContentSizeIgnoringTableView")]) [SharedManager sharedInstance].tempName = nil;

            [[Tweak sharedInstance] changeBackground:self];
        }
    }
%end

%hook UIView
    - (void)setBackgroundColor:(UIColor *)arg1 {
        [SharedManager sharedInstance].isLightMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight; // Just drop random code here
        if (self.superview &&
        [self.superview isKindOfClass:NSClassFromString(@"UITableView")]) {
            arg1 = [UIColor clearColor];
        }
        %orig;
    }

    - (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
        [SharedManager sharedInstance].isLightMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight;
        %orig;
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