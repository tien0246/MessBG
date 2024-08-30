#import <Foundation/Foundation.h>

@interface SharedManager : NSObject
@property (nonatomic, strong) NSString *tempName;
@property (nonatomic) BOOL isLightMode;
+ (instancetype)sharedInstance;
- (BOOL)hasImage;
@end