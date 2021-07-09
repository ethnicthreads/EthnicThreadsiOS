//
//  PromotionCriteria.m
//  EthnicThread
//
//  Created by DuyLoc on 5/14/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "PromotionCriteria.h"

@implementation PromotionCriteria

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"promotion_type"]) {
        [super setValue:value forKey:@"promotionType"];
    } else if ([key isEqualToString:@"display_text"]) {
        [super setValue:value forKey:@"displayText"];
    } else if ([key isEqualToString:@"tag_keyword"]) {
        [super setValue:value forKey:@"tagKeyword"];
    } else {
        [super setValue:value forKey:key];
    }
}

- (BOOL)isEqual:(id)object {
    if ([self.promotionType isEqualToString:PROMOTION_TYPE_ALL] || [self.promotionType isEqualToString:PROMOTION_TYPE_MORE]) {
        PromotionCriteria *criteria = (PromotionCriteria *)object;
        if ([self.promotionType isEqualToString:criteria.promotionType]) {
            return YES;
        }
    }
    if ([self.getIdString isEqualToString:[object getIdString]]) {
        return YES;
    }
    return FALSE;
}

- (BOOL)isLocationPromotionType {
    return [self.promotionType.uppercaseString hasPrefix:@"L"];
}

- (BOOL)isCriteriaOfProductType {
    return [self.promotionType.uppercaseString hasPrefix:PROMOTION_TYPE_PRODUCT] || [self.promotionType hasPrefix:PROMOTION_TYPE_LPRODUCT];
}

- (BOOL)isCriteriaOfTalentType {
    return [self.promotionType.uppercaseString hasPrefix:PROMOTION_TYPE_TALENT] || [self.promotionType hasPrefix:PROMOTION_TYPE_LTALENT];
}
@end
