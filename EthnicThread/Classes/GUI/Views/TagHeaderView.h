//
//  TagHeaderView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 3/10/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface TagHeaderView : BaseView
@property (nonatomic, assign) IBOutlet UILabel      *lblText;

- (void)setStatus:(BOOL)opened;
@end
