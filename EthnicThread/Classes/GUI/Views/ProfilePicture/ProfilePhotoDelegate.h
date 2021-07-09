//
//  ProfilePhotoDelegate.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/18/14.
//  Copyright (c) 2014 Codebox Solution Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProfilePhotoDelegate <NSObject>

- (void)openImagePickerController;
- (void)openCameraRollController;
@end
