//
//  AnOptionalItemListingView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"
#import "CreativeItemModel.h"

@interface AnOptionalItemListingView : BaseView
@property (nonatomic, assign) IBOutlet UIButton     *btnCurrency;
@property (nonatomic, assign) IBOutlet UIButton     *btnCountry;
@property (nonatomic, assign) IBOutlet UIButton     *btnCountryArow;
@property (nonatomic, strong) CreativeItemModel     *createdItem;
@property (nonatomic, strong) Addresses             *addresses;
@property (nonatomic, assign) BOOL                  allowEnableRequired;
@property (nonatomic, assign) BOOL                  didPopupLoctionActionSheet;

- (void)hideKeyboard;
- (void)startScanningLocation;
- (void)shouldEnableRequired;
- (void)updateLayoutOfLocation;
- (void)openAddActionSheet;
@end
