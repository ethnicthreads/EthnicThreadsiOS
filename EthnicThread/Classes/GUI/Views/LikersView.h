//
//  LikersView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/28/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "SupViewOfMoreInfoDelegate.h"

@interface LikersView : BaseView
@property (nonatomic, strong) ItemModel                      *itemModel;
@property (nonatomic, assign) id <SupViewOfMoreInfoDelegate> delegate;
@end
