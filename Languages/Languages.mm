#import "Languages.h"

@implementation Languages

+ (instancetype)sharedInstance {
    static Languages *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Languages alloc] init];
    });
    return sharedInstance;
}

- (NSDictionary *)localizedStrings {
    return @{
        @"en": @{
            @"Settings": @"Settings",
            @"Change Image": @"Change Image",
            @"Delete Image": @"Delete Image",
            @"Cancel": @"Cancel",
            @"Save": @"Save",
            @"Toggle Background": @"Background message",
            @"Enable or disable the background": @"Background in messages",
            @"Header & Footer Opacity": @"Header & Footer Opacity",
            @"Adjust the opacity of the header and footer": @"Adjust the opacity of the header and footer",
            @"Background Opacity": @"Background Opacity",
            @"Adjust the opacity of the background": @"Adjust the opacity of the background",
            @"Black Overlay": @"Overlay background",
            @"Enable or disable the black overlay": @"The overlay of the background",
            @"Toggle Background Messenger": @"Background Messenger",
            @"Enable or disable the background Messenger": @"Background of Messenger",
            @"Toggle only main background": @"Only home background",
            @"Enable or disable the main background": @"Only the home background changes",
        },
        @"vi": @{
            @"Settings": @"Cài đặt",
            @"Change Image": @"Thay ảnh",
            @"Delete Image": @"Xóa ảnh",
            @"Cancel": @"Hủy",
            @"Save": @"Lưu",
            @"Toggle Background": @"Nền tin nhắn",
            @"Enable or disable the background": @"Nền ở chỗ nhắn tin",
            @"Header & Footer Opacity": @"Độ mờ của Tiêu đề & Chân trang",
            @"Adjust the opacity of the header and footer": @"Điều chỉnh độ mờ của tiêu đề và chân trang",
            @"Background Opacity": @"Độ mờ của Nền",
            @"Adjust the opacity of the background": @"Điều chỉnh độ mờ của nền",
            @"Black Overlay": @"Lớp phủ nền",
            @"Enable or disable the black overlay": @"Lớp phủ của nền",
            @"Toggle Background Messenger": @"Nền Messenger",
            @"Enable or disable the background Messenger": @"Nền của Messenger",
            @"Toggle only main background": @"Chỉ nền chính",
            @"Enable or disable the main background": @"Chỉ nền chính thay đổi, các nền khác vẫn mặc định",
        }
    };
}
- (NSString *)localizedStringForKey:(NSString *)key {
    NSString *languageCode = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSDictionary *languageDict = [self localizedStrings][languageCode];
    if (!languageDict) {
        languageDict = [self localizedStrings][@"en"];
    }
    return languageDict[key] ?: key;
}
@end