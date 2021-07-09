//
//  CreatedItemModel.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseItemModel.h"
#import "ItemModel.h"

#define IMAGE_URLS_KEY       @"image_urls_key"

@interface CreativeItemModel : BaseItemModel
@property (strong, nonatomic) NSMutableArray    *tags;
@property (strong, nonatomic) NSMutableArray    *sizes;
@property (strong, nonatomic) NSMutableArray    *images;//UIImage or NSSTring (url)
@property (nonatomic, assign) BOOL              isEdit;
@property (nonatomic, assign) BOOL              isDefaultAddress;

- (BOOL)checkExistedTag:(NSString *)aTag;
- (BOOL)checkExistedSize:(NSString *)aSize;
- (BOOL)checkExistedPurchase:(NSString *)aPurchase;
- (ItemModel *)generateItemModel;
- (NSString *)getSizeString;
- (NSMutableDictionary *)makeDictionaryForBaseValue;
- (NSMutableDictionary *)makeDictionary;
- (BOOL)checkRequiredFields;
- (BOOL)checkOptionalFields;
- (NSArray *)scaleImagesAndMakeFileUrls:(NSArray *)imageUIs;// only contains UIImage
- (void)setIsService:(BOOL)isService;
- (void)updatePurchases:(NSMutableArray *)purchases;
- (NSMutableArray *)getPurchases;
- (BOOL)isForFun;
- (void)useDefaultAddress;
- (void)useCurrentLocation;
- (BOOL)shouldShowSoftWarningForUS;
@end
