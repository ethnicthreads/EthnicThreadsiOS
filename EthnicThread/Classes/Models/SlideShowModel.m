//
//  SlideShowModel.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/8/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "SlideShowModel.h"
#import "AppManager.h"
#import "DownloadManager.h"

@interface SlideShowModel()

@end

@implementation SlideShowModel
- (id)initWithDictionary:(NSDictionary *)dict {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [mDict setObject:[mDict objectForKey:@"description"] forKey:@"desc"];
    [mDict removeObjectForKey:@"description"];
    self = [super initWithDictionary:mDict];
    if (self) {
        dict = [Utils checkNull:dict];
        self.position = [[Utils checkNil:[dict objectForKey:@"price"] defaultValue:@"0"] integerValue];
        NSString *baseUrl = [[AppManager sharedInstance] getCloudHostBaseUrl];
        if (![self.image hasPrefix:@"http"]) {
            self.image = [baseUrl stringByAppendingFormat:@"%@", self.image];
        }
    }
    return self;
}
@end
