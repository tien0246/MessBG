#import <Foundation/Foundation.h>

@interface SharedManager : NSObject
@property (nonatomic, strong) NSString *tempName;
+ (instancetype)sharedInstance;
- (BOOL)hasImage;
@end