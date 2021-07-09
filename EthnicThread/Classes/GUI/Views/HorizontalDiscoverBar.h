//
//  HorizontalDiscoverBar.h
//  EthnicThread
//
//  Created by DuyLoc on 5/14/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "PromotionCriteria.h"


@interface HorizontalDiscoverBar : BaseView
typedef void(^horizontalBarBlock)(HorizontalDiscoverBar *horizontalBar, PromotionCriteria *selectedCriteria);
typedef void(^turnOnLocationBlock)(HorizontalDiscoverBar *horizontalBar);
- initWithBlock:(horizontalBarBlock)onItemSelect;
- (void)setPromotionList:(NSArray *)promotionList;
- (PromotionCriteria *)getCurrentSelectedCriteria;
- (void)setTurnOnLocationBlock:(turnOnLocationBlock)turnOnBlockHandler;
- (void)shouldHideLocationBar:(BOOL)shouldHide;
- (void)setSelectItem:(PromotionCriteria *) selectedCriteria;
- (void)selectCriteriaAtIndex:(NSUInteger)index;
@end
