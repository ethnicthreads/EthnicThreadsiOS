//
//  CommentModel.h
//  EthnicThread
//
//  Created by Katori on 12/3/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"
#import "SellerModel.h"

@interface CommentModel : AssetModel
@property (nonatomic, strong) NSString      *comment;
@property (nonatomic) double                date;
@property (strong, nonatomic) SellerModel   *owner;

- (NSString *)getCreatedDateString;
@end
