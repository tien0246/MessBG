#import "ImagePickerManager.h"

@implementation ImagePickerManager

+ (instancetype)sharedManager {
    static ImagePickerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)presentImagePickerFromViewController:(UIViewController *)viewController {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = NO;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [viewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image withName:(NSString *)fileName {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *imageDirectory = [documentsPath stringByAppendingPathComponent:@"image"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [imageDirectory stringByAppendingPathComponent:fileName];
        [imageData writeToFile:filePath options:NSDataWritingAtomic error:nil];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    NSString *imageName = [SharedManager sharedInstance].tempName;
    if (imageName) {
        [self saveImage:selectedImage withName:imageName];
    } else {
        [self saveImage:selectedImage withName:@"0"];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end