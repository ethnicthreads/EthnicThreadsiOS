//
//  AssetModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"
#import "Constants.h"

@interface AssetModel : BaseObject
@property (nonatomic, retain) id            id;

- (NSString *)getIdString;
- (BOOL)isSameId:(NSString *)aId;
- (BOOL)isSame:(AssetModel *)assetModel;

@end
