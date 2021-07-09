//
//  MessageModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/26/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"
#import "ItemModel.h"

@interface MessageModel : AssetModel
@property (nonatomic, retain) NSString                  *message;
@property (nonatomic, retain) ItemModel                 *itemModel;
@property (nonatomic, assign) double                    created_at;
@property (strong, nonatomic) SellerModel               *sender;
@property (strong, nonatomic) SellerModel               *receiver;
@property (nonatomic, strong) NSString                  *threadType;
@property (nonatomic, strong) NSString                  *imageUrl;
@property (nonatomic, strong) NSString                  *contentType;

- (BOOL)isMine;
- (SellerModel *)getTargetSeller;
- (NSString *)getCreatedDateString;
- (BOOL)isImageType;
- (BOOL)isTextType;
@end
