#import <Foundation/Foundation.h>

static char kKey;

@interface Languages : NSObject

+ (instancetype)sharedInstance;
- (NSDictionary *)localizedStrings;
- (NSString *)localizedStringForKey:(NSString *)key;

@end