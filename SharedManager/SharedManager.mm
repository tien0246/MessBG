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
    NSString *filePath = [imageDirectory stringByAppendingPathComponent:self.tempName];
    return self.tempName && [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end