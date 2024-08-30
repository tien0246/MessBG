#import "SharedManager.h"

@implementation SharedManager

+ (instancetype)sharedInstance {
    static SharedManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)hasImage {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:@"image"];
    NSString *imagePath0 = [imageDirectory stringByAppendingPathComponent:[_tempName stringByAppendingString:@"0"]];
    NSString *imagePath1 = [imageDirectory stringByAppendingPathComponent:[_tempName stringByAppendingString:@"1"]];
    return _tempName && ([[NSFileManager defaultManager] fileExistsAtPath:imagePath0] || [[NSFileManager defaultManager] fileExistsAtPath:imagePath1]);
}

@end