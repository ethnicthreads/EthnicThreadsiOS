//
//  SellerModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/15/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "SellerModel.h"

@implementation SellerModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        //        dict = [Utils checkNull:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    [super updateWithDictionary:dict];
    //    dict = [Utils checkNull:dict];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    [super setSpecialValue:dict];
    self.total_reviews = [[Utils checkNil:[dict objectForKey:@"total_reviews"] defaultValue:@"0"] integerValue];
    self.followed = [[Utils checkNil:[dict objectForKey:@"followed"] defaultValue:@"0"] boolValue];
    [self setHasFullData:([dict objectForKey:@"total_items"] != nil)];
}

- (NSString *)getNumberOfReviewsText {
    NSString *str = [NSString stringWithFormat:@"%ld", (long)self.total_reviews];
    if (self.total_reviews >= 1000) {
        str = [NSString stringWithFormat:@"%0.2f", (float)self.total_reviews / 1000];
        if (self.total_reviews >= 1000000) {
            str = [NSString stringWithFormat:@"%f", (float)self.total_reviews / 1000];
        }
    }
    return (self.total_reviews <= 1) ? [NSString stringWithFormat:@"%ld Review", (long)self.total_reviews] : [NSString stringWithFormat:@"%@ Reviews", str];
}

- (NSString *)getItemsCountText {
    return [NSString stringWithFormat:@"%ld %@", (long)self.total_items, (self.total_reviews <= 1) ?  NSLocalizedString(@"item_listed", @"") : NSLocalizedString(@"items_listed", @"")];
}

- (NSString *)getFollowStatusString {
    if (self.followed) {
        return [NSLocalizedString(@"unfollow", @"") uppercaseString];
    }
    return [NSLocalizedString(@"follow", @"") uppercaseString];
}

#pragma mark - ItemSellerProtocol
- (void)updateLatestReview:(NSDictionary *)dict {
    //    [self.latestReview updateWithDictionary:dict];
    self.total_reviews++;
}
@end
