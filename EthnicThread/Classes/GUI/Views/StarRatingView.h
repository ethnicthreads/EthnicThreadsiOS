//
//  StarRatingView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/12/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@interface StarRatingView : BaseView

@property (nonatomic) NSInteger rating; // [1, 100]
@property (nonatomic) BOOL allowRating;
@end
