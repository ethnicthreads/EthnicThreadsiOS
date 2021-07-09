//
//  PromotionCriteria.h
//  EthnicThread
//
//  Created by DuyLoc on 5/14/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "AssetModel.h"


//{
//    "id": 1,
//    "promotion_type": "Product",
//    "display_text": "Lehengas",
//    "tag_keyword": "Clothing: Lehenga"
//},
@interface PromotionCriteria : AssetModel
@property (nonatomic, strong) NSString *promotionType;
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSString *tagKeyword;
- (BOOL)isLocationPromotionType;
- (BOOL)isCriteriaOfProductType;
- (BOOL)isCriteriaOfTalentType;
@end
