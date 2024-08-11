#import <UIKit/UIKit.h>
#import "../SharedManager/SharedManager.h"

@interface ImagePickerManager : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedManager;

- (void)presentImagePickerFromViewController:(UIViewController *)viewController;
- (void)saveImage:(UIImage *)image withName:(NSString *)fileName;

@end