//
//  ARequitedItemListingView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "ImagesScrollView.h"
#import "SelectionsView.h"
#import "ETPlaceHolderTextView.h"

@protocol ARequitedItemListingViewDelegate <NSObject>
- (void)didSelectPurchase:(NSString *)purchase;
- (void)choosePhotosInCameraRoll;
- (void)takePhoto;
@end

@interface ARequitedItemListingView : BaseView
@property (nonatomic, assign) IBOutlet ImagesScrollView     *scvImages;
@property (nonatomic, assign) IBOutlet ETPlaceHolderTextView  *tfTitle;
@property (nonatomic, strong) NSDictionary          *valueTags;
@property (nonatomic, strong) CreativeItemModel     *createdItem;
@property (nonatomic, assign) BOOL                  allowEnableRequired;
@property (nonatomic, assign) id <ARequitedItemListingViewDelegate>     delegate;
@property (nonatomic, strong) SelectionsView                *selectionView;

- (void)addImage:(UIImage *)image animate:(BOOL)animated;
- (void)removeImageAtIndex:(NSInteger)index;
- (void)shouldEnableRequired;
@end
