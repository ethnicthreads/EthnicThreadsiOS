//
//  UpdateItemModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/25/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "UpdateItemModel.h"
#import "ImageItemModel.h"
#import "UserManager.h"

@interface UpdateItemModel()
@property (nonatomic, strong) ItemModel     *itemModel;
@end

@implementation UpdateItemModel

- (id)initWithItemModel:(ItemModel *)anItem {
    self = [super init];
    if (self) {
        self.itemModel = anItem;
        
        self.id = anItem.id;
        self.name = [anItem.name copy];
        self.desc = [anItem.desc copy];
        self.price = anItem.price;
        self.shipping = anItem.shipping;
        self.currency = [anItem.currency copy];
        self.gender = [anItem.gender copy];
        self.latitude = anItem.latitude;
        self.longitude = anItem.longitude;
        self.address = [anItem.address copy];
        self.city = [anItem.city copy];
        self.state = [anItem.state copy];
        self.country = [anItem.country copy];
        AccountModel *account = [[UserManager sharedInstance] getAccount];
        self.isDefaultAddress = (self.latitude == account.latitude && self.longitude == account.longitude);
        self.sizes = [NSMutableArray arrayWithArray:[anItem.sizes componentsSeparatedByString:@","]];
        self.tags = [NSMutableArray arrayWithArray:[anItem.tags componentsSeparatedByString:@","]];
        [self updatePurchases:[NSMutableArray arrayWithArray:[anItem.purchases componentsSeparatedByString:@","]]];
        self.describe_size = anItem.describe_size;
        self.youtube_link = anItem.youtube_link;
        self.images = [NSMutableArray arrayWithArray:[anItem getAllImageUrls]];
        self.category = [anItem.category copy];
        if ([self isService]) {
            self.gender = GENDER_SERVICES;
            self.condition = CONDITION_NONE;
        }
    }
    return self;
}

- (NSMutableDictionary *)makeDictionary {
    NSMutableDictionary *dict = [self makeDictionaryForBaseValue];
    
    // find new images
    NSMutableArray *addedNewImages = [[NSMutableArray alloc] init];
    for (id obj in self.images) {
        if ([obj isKindOfClass:[UIImage class]]) {
            [addedNewImages addObject:obj];
        }
    }
    [dict setObject:[self scaleImagesAndMakeFileUrls:addedNewImages] forKey:IMAGE_URLS_KEY];
    
    // find removed images
    NSMutableArray *deletedImageIds = [[NSMutableArray alloc] init];
    for (ImageItemModel *imageItem in self.itemModel.imageItems) {
        BOOL existed = NO;
        for (id obj in self.images) {
            if ([obj isKindOfClass:[NSString class]] && [imageItem.getImageURL isEqualToString:obj]) {
                existed = YES;
                break;
            }
        }
        if (!existed) {
            [deletedImageIds addObject:[imageItem getIdString]];
        }
    }
    [dict setObject:[deletedImageIds componentsJoinedByString:@","] forKey:@"images_deleted_ids"];
    return dict;
}
@end
