//
//  PreviewTagsView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "PreviewTagsView.h"

@interface PreviewTagsView()
@property (nonatomic, assign) IBOutlet UILabel          *lblText;
@end

@implementation PreviewTagsView

- (void)layoutComponents {
    [super layoutComponents];
    self.lblText.text = self.content;
}
@end
