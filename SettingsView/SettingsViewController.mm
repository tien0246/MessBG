#import "SettingsViewController.h"

@implementation SettingsViewController

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(20, 20, frame.size.width - 40, frame.size.height - 40);
        self.view = [[SettingsView alloc] initWithFrame:frame];
    }
    return self;
}

@end