//
//  AddPhotoView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/17/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@protocol AddPhotoViewDelegate <NSObject>

- (void)choosePhotosInCameraRoll;
- (void)takePhoto;
@end

@interface AddPhotoRightNavigationView : BaseView
@property (nonatomic, assign) id <AddPhotoViewDelegate>     delegate;
@end
