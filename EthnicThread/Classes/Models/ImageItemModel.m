//
//  ImageItemModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "ImageItemModel.h"
#import "AppManager.h"

@implementation ImageItemModel
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        [self setSpecialValue:dict];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict {
    [super updateWithDictionary:dict];
    [self setSpecialValue:dict];
}

- (void)setSpecialValue:(NSDictionary *)dict {
    dict = [Utils checkNull:dict];
    NSString *baseUrl = [[AppManager sharedInstance] getCloudHostBaseUrl];
    if (![self.image_url hasPrefix:@"http"]) {
        self.image_url = [baseUrl stringByAppendingFormat:@"%@", self.image_url];
    }
}

- (NSString *)getImageURL {
    if (self.cdn_url.length > 0) {
        return self.cdn_url;
    } else {
        return self.image_url;
    }
}
@end
