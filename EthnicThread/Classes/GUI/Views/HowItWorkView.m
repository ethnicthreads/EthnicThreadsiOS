//
//  HowItWorkView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 11/24/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "HowItWorkView.h"
#import "Utils.h"
#import "Constants.h"

@interface HowItWorkView()
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightTitleLabel;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightDesclabel;
@property (nonatomic, assign) IBOutlet UILabel      *lblTitle;
@property (nonatomic, assign) IBOutlet UILabel      *lblDesc;
@end

@implementation HowItWorkView

- (void)initGUI {
    [super initGUI];
    [self.lblTitle setTextColor:[UIColor whiteColor]];
    [self.lblDesc setTextColor:[UIColor whiteColor]];
}

- (void)setSlideShow:(SlideShowModel *)slide {
    self.lblTitle.text = slide.title;
    self.lblDesc.text = slide.desc;
}
@end
