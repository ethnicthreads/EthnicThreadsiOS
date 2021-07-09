//
//  AnImagePopupView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 3/3/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface AnImagePopupView : BaseView
@property (nonatomic, assign) id     imageObj;
@property (nonatomic, assign) BOOL   loaded;
- (void)startLoadImage;
@end
