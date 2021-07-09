//
//  ETActivityItemProvider.m
//  EthnicThread
//
//  Created by PhuocDuy on 5/9/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "ETActivityItemProvider.h"

@implementation ETActivityItemProvider

- (id)item {
    ActivityItem *activityItem = self.normalItem;
    for (ActivityItem *item in self.supportedItems) {
        if ([item isSameId:self.activityType]) {
            activityItem = item;
            break;
        }
    }
    return [activityItem getMessage];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    ActivityItem *activityItem = self.normalItem;
    for (ActivityItem *item in self.supportedItems) {
        if ([item isSameId:self.activityType]) {
            activityItem = item;
            break;
        }
    }
    return [activityItem getSubject];
}
@end
