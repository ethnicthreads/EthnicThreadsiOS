//
//  ImageItemModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"

@interface ImageItemModel : AssetModel
@property (strong, nonatomic) NSString      *image_url;
@property (strong, nonatomic) NSString      *cdn_url;
- (NSString *)getImageURL;
@end
