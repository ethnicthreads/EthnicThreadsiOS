//
//  AddPhotoView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/17/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AddPhotoRightNavigationView.h"

@interface AddPhotoRightNavigationView()
@property (nonatomic, assign) IBOutlet UIButton     *btnChoosePhoto;
@property (nonatomic, assign) IBOutlet UIButton     *btnTakePhoto;
@end

@implementation AddPhotoRightNavigationView

- (void)initGUI {
    [super initGUI];
    
}

- (IBAction)handleChoosePhotoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(choosePhotosInCameraRoll)]) {
        [self.delegate choosePhotosInCameraRoll];
    }
}

- (IBAction)handleTakePhotoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
        [self.delegate takePhoto];
    }
}

@end
