//
//  AddItemRequitedViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AddItemRequitedViewController.h"
#import "AddItemOptionalViewController.h"
#import "ARequitedItemListingView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImagePopupViewController.h"
#import "AddItemFinishViewController.h"
#import "ImageSquareCropperViewController.h"
#import "PhotoTweaksViewController.h"
#import <AVFoundation/AVFoundation.h>

#define CAMERA_PERMISSION_ALERT 1234
#define SELECT_PHOTO            2345
#define SELECT_POST_TYPE        7890

@interface AddItemRequitedViewController () <SlideNavigationControllerDelegate, ARequitedItemListingViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagesScrollViewDelegate, ImageCropperDelegate, UIAlertViewDelegate, PhotoTweaksViewControllerDelegate>
@property (nonatomic, assign) IBOutlet UIScrollView             *scvMainScroll;
@property (nonatomic, strong) ARequitedItemListingView          *itemView;
@property (nonatomic, assign) IBOutlet UIButton                 *btnPostItNow;
@property (nonatomic, assign) IBOutlet UIButton                 *btnContinue;
@property (nonatomic, assign) IBOutlet UIButton                 *btnDone;
@property (nonatomic, strong) UIImage *imageToUse;
@end

@implementation AddItemRequitedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    
    [self setNavigationBarTitle:NSLocalizedString(@"post_something", @"") andTextColor:BLACK_COLOR_TEXT];
    UIImage *leftImage = [UIImage imageNamed:@"purple_menu"];
    if (self.createdItem.isEdit) {
        leftImage = [UIImage imageNamed:@"purple_back_button"];
    }
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:leftImage
                       andFrame:CGRectMake(15, 5, 40, 50)];
    
    [self.btnDone setHidden:![self.createdItem isEdit]];
    [self.btnPostItNow setHidden:[self.createdItem isEdit]];
    [self.btnContinue setHidden:[self.createdItem isEdit]];
    
    self.itemView = [[[UINib nibWithNibName:NSStringFromClass([ARequitedItemListingView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.itemView.delegate = self;
    self.itemView.scvImages.aDelegate = self;
    self.itemView.createdItem = self.createdItem;
    self.itemView.valueTags = [[AppManager sharedInstance] getTags:self.createdItem.isService];
    [self.itemView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scvMainScroll addSubview:self.itemView];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[UIScreen mainScreen].bounds.size.width];
    [self.itemView addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.itemView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scvMainScroll attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.scvMainScroll addConstraint:lc];
    
    [[AppManager sharedInstance] updateTags:YES andListener:self];
    
    if (!self.createdItem.isEdit) {
        [self showPostTypeAlert];
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)showPostTypeAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"post_something_type", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"product", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"talent", @"")];
    alert.tag = SELECT_POST_TYPE;
    [alert show];
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    if (self.createdItem.isEdit) {
        if ([self.createdItem checkRequiredFields]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
            self.itemView.allowEnableRequired = YES;
            [self.itemView shouldEnableRequired];
        }
    }
    else {
        [self handleTouchToMainMenuButton];
    }
}

- (IBAction)handlePostItNowButton:(id)sender {
    if ([self.createdItem checkRequiredFields]) {
        [[OperationManager shareInstance] dispatchNormalThreadWithTarget:self selector:@selector(executePostAnItem:threadObj:) argument:@""];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        self.itemView.allowEnableRequired = YES;
        [self.itemView shouldEnableRequired];
    }
}

- (IBAction)handleContinueButton:(id)sender {
    if ([self.createdItem checkRequiredFields]) {
        AddItemOptionalViewController *vc = [[AddItemOptionalViewController alloc] init];
        vc.createdItem = self.createdItem;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        self.itemView.allowEnableRequired = YES;
        [self.itemView shouldEnableRequired];
    }
    
}
- (IBAction)handleDoneButton:(id)sender {
    if ([self.createdItem checkRequiredFields]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [Utils showAlertNoInteractiveWithTitle:NSLocalizedString(@"alert_title_info", @"") message:NSLocalizedString(@"alert_enter_required_fields", @"")];
        self.itemView.allowEnableRequired = YES;
        [self.itemView shouldEnableRequired];
    }
}

- (void)willOpenLeftMenu {
    [super willOpenLeftMenu];
    [self.itemView.tfTitle resignFirstResponder];
}

#pragma mark - Private Method
- (void)executePostAnItem:(id)dummy threadObj:(id<OperationProtocol>)threadObj {
    [self startSpinnerWithWaitingText];
    Response *response = [CloudManager addNewItem:self.createdItem];
    if (![threadObj isCancelled] && [self isResponseSuccessful:response]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *dict = response.getJsonObject;
            [[CachedManager sharedInstance] removeAllCachedTempImages];
            AddItemFinishViewController *vc = [[AddItemFinishViewController alloc] init];
            vc.itemId = [[dict objectForKey:@"id"] description];
            [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc
                                                                  withSlideOutAnimation:NO
                                                                          andCompletion:nil];
        });
    }
    [self stopSpinner];
    [threadObj releaseOperation];
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldSwipeLeftMenu {
    return !self.createdItem.isEdit;
}

#pragma mark - ARequitedItemListingViewDelegate
- (void)didSelectPurchase:(NSString *)purchase {
    [self.btnPostItNow setEnabled:[self.createdItem isForFun]];
}

- (void)choosePhotosInCameraRoll {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        [self presentViewController:mediaUI animated:YES completion:nil];
    }
}

- (BOOL)checkCameraPermission {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
                        DLog(@"Granted access to %@", AVMediaTypeVideo);
        return true;
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        return false;
                        DLog(@"Not granted access to %@", AVMediaTypeVideo);
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
                        DLog(@"Not granted access to %@", AVMediaTypeVideo);
                return false;
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        return false;
    } else {
        // impossible, unknown authorization status
                        DLog(@"Not granted access to %@", AVMediaTypeVideo);
                return false;
    }
    return false;
}

- (void)takePhoto {
    if ([self checkCameraPermission]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraUI.allowsEditing = NO;
            cameraUI.delegate = self;
            [self presentViewController:cameraUI animated:YES completion:nil];
        }
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
                    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                    cameraUI.allowsEditing = NO;
                    cameraUI.delegate = self;
                    [self presentViewController:cameraUI animated:YES completion:nil];
                }
            }
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
    }
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^ {
        //        [self.itemView addImage:imageToUse animate:YES];
        CGSize cropFrame = self.itemView.scvImages.frame.size;
        DLog(@"CropFrame:%@", NSStringFromCGSize(cropFrame));
        //        ImageSquareCropperViewController *imgCropperVC = [[ImageSquareCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        //        ImageSquareCropperViewController *imgCropperVC = [[ImageSquareCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, cropFrame.width, cropFrame.height) limitScaleRatio:3.0];
        //        imgCropperVC.isRoundCroped = NO;
        //        imgCropperVC.delegate = self;
        //        [self presentViewController:imgCropperVC animated:YES completion:nil];
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"alert_crop_image", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"alert_button_no", @"") otherButtonTitles:NSLocalizedString(@"alert_button_yes", @""), nil];
        [alertView setTag:SELECT_PHOTO];
        self.imageToUse = imageToUse;
        [alertView show];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImageCropperDelegate
- (void)imageCropper:(ImageSquareCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    editedImage = [editedImage scaleByWidth:IMAGE_ITEM_WIDTH];
    
    //    NSString *filePath = [[CachedManager sharedInstance] cacheTempJPEGImage:editedImage withFileName:@"IMG.JPEG"];
    //    self.creativeAccount.avatar = filePath;
    //    [self setAvatarImage:[UIImage imageWithContentsOfFile:filePath]];
    //    [self justChangeAvatar];
    //    [self.itemView addImage:[UIImage imageWithContentsOfFile:filePath] animate:YES];
    [self.itemView addImage:editedImage animate:YES];
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(ImageSquareCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImagesScrollViewDelegate
- (void)removedImageAtIndex:(NSInteger)index {
    [self.itemView removeImageAtIndex:index];
}

- (void)popupZoomingImages:(NSArray *)images currentIndex:(NSInteger)index {
    ImagePopupViewController *vc = [[ImagePopupViewController alloc] init];
    vc.images = images;
    vc.currentIndex = index;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - AppManagerProtocol
- (void)didFinishDownloadingTags:(NSDictionary *)tags {
    if (!self.createdItem.isService) {
        self.itemView.valueTags = tags;
    }
}

- (void)didFinishDownloadingServiceTags:(NSDictionary *)tags {
    if (self.createdItem.isService) {
        self.itemView.valueTags = tags;
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == CAMERA_PERMISSION_ALERT) {
        if ([buttonTitle isEqualToString:@"Settings"]) {
//            NSURL(string: UIApplicationOpenSettingsURLString)];
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString]];
        }
    } else if (alertView.tag == SELECT_PHOTO) {
        if  ([buttonTitle isEqualToString:NSLocalizedString(@"alert_button_yes", @"")]) {
            PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:_imageToUse];
            photoTweaksViewController.delegate = self;
            photoTweaksViewController.autoSaveToLibray = YES;
            [self presentViewController:photoTweaksViewController animated:YES completion:nil];
        }
        if ([buttonTitle isEqualToString:NSLocalizedString(@"alert_button_no", @"")]) {
            [self.itemView addImage:_imageToUse animate:YES];
        }
    } else if (alertView.tag == SELECT_POST_TYPE) {
        if ([buttonTitle isEqualToString:NSLocalizedString(@"product", @"")]) {
            [self.itemView.selectionView selectProducType:YES];
        } else if ([buttonTitle isEqualToString:NSLocalizedString(@"talent", @"")]) {
            [self.itemView.selectionView selectProducType:NO];
        }
    }
}

#pragma mark PhotoTweaksViewControllerDelegate
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [self.itemView addImage:croppedImage animate:YES];
    //[cropperViewController dismissViewControllerAnimated:YES completion:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
    //    //croppedImage = [croppedImage scaleByWidth:IMAGE_ITEM_WIDTH];
    //    [self.itemView addImage:croppedImage animate:YES];
    //    //[cropperViewController dismissViewControllerAnimated:YES completion:nil];
    //    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
    [self.itemView addImage:_imageToUse animate:YES];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
