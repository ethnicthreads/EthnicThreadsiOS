//
//  SlideShowModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/8/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

@interface SlideShowModel : AssetModel
@property (nonatomic, assign) NSInteger         position;
@property (nonatomic, strong) NSString          *title;
@property (nonatomic, strong) NSString          *desc;
@property (nonatomic, strong) NSString          *image;
@end
