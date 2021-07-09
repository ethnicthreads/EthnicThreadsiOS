//
//  CreateProfileViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/20/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "CreateProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AnimatedTransitioning.h"
#import "ImageCropperViewController.h"

@interface CreateProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropperDelegate> {
    
}

- (IBAction)handleBackButton:(id)sender;
- (IBAction)handleTakePictureButton:(id)sender;
@end

@implementation CreateProfileViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.creativeAccount.avatar.length > 0 && ![self.creativeAccount.avatar hasPrefix:@"http"]) {
        [self setAvatarImage:[UIImage imageWithContentsOfFile:self.creativeAccount.avatar]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:LIGHT_GRAY_COLOR];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"update_profile", @"") andTextColor:BLACK_COLOR_TEXT];
    
    self.containView.layer.cornerRadius = 3;
    [self.btnAvatar boderWidth:3 andColor:[UIColor whiteColor].CGColor];
    
    [self.btnAvatar setBackgroundImage:[UIImage imageNamed:@"take_picture_button"] forState:UIControlStateNormal];
    if ([self.creativeAccount.avatar hasPrefix:@"http"]) {
        [self setAvatarImage:[[DownloadManager shareInstance] getCachedImageForUrl:self.creativeAccount.avatar]];
    }
    else {
        [self setAvatarImage:[UIImage imageWithContentsOfFile:self.creativeAccount.avatar]];
    }
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (IBAction)handleBackButton:(id)sender {
    
}

- (IBAction)handleTakePictureButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"take_photo", @""), NSLocalizedString(@"choose_from_photo_library", @""), nil];
    [sheet showInView:self.view];
}

- (void)setAvatarImage:(UIImage *)image {
    if ([[UserManager sharedInstance] isLoginViaFacebook]) {
        [self.btnChangePicture setHidden:YES];
        [self.btnAvatar setUserInteractionEnabled:NO];
    }
    else {
        [self.btnChangePicture setHidden:NO];
        [self.btnAvatar setUserInteractionEnabled:YES];
    }
    if (image) {
        [self.btnAvatar setBackgroundImage:[image cropCenterToSize:CGSizeMake(85, 85)] forState:UIControlStateNormal];
    }
    else {
        [self.btnAvatar loadImageForUrl:self.creativeAccount.avatar];
    }
}

- (void)justChangeAvatar {
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            cameraUI.allowsEditing = NO;
            cameraUI.delegate = self;
            [self presentViewController:cameraUI animated:YES completion:nil];
        }
    }
    else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            mediaUI.allowsEditing = NO;
            mediaUI.delegate = self;
            [self presentViewController:mediaUI animated:YES completion:nil];
        }
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
//        UIImageWriteToSavedPhotosAlbum (imageToUse, nil, nil , nil);
    }
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{
        ImageCropperViewController *imgCropperVC = [[ImageCropperViewController alloc] initWithImage:imageToUse cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ImageCropperDelegate
- (void)imageCropper:(ImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    editedImage = [editedImage scaleByWidth:IMAGE_ITEM_WIDTH];
    
    NSString *filePath = [[CachedManager sharedInstance] cacheTempJPEGImage:editedImage withFileName:@"IMG.JPEG"];
    self.creativeAccount.avatar = filePath;
    [self setAvatarImage:[UIImage imageWithContentsOfFile:filePath]];
    [self justChangeAvatar];
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(ImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = NO;
    return controller;
}
@end
