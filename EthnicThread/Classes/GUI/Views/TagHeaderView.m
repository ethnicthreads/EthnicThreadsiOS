//
//  TagHeaderView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 3/10/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "TagHeaderView.h"

@interface TagHeaderView()
@property (nonatomic, assign) IBOutlet UIImageView  *imvArrow;
@property (nonatomic, assign) IBOutlet UIView       *vLine;
@end
@implementation TagHeaderView
- (void)setStatus:(BOOL)opened {
    [self.imvArrow setHidden:opened];
    [self.vLine setHidden:opened];
}
@end
