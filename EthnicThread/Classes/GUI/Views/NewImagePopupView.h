//
//  ImagePopupView.h
//  EthnicThread
//
//  Created by Nguyen Loc on 10/17/15.
//  Copyright © 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface NewImagePopupView : BaseView
@property (nonatomic, assign) id     imageObj;
@property (nonatomic, assign) BOOL   loaded;
- (void)startLoadImage;
@end
