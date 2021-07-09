//
//  ImageBgView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/21/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@interface ImageBgView : BaseView
@property (nonatomic, strong) UIImageView       *bgImageView;

- (void)enableOverlayView;
@end
