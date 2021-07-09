//
//  Notification.h
//  EthnicThread
//
//  Created by DuyLoc on 5/21/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseObject.h"
//{
//    "aps": {
//        "data": {
//            "body": "Nice weekend from EthnicThread. Happy shopping."
//        },
//        "badge": "",
//        "content-available": "1"
//    },
//    "target": {
//        "context": "any_device",
//        "country": "",
//        "state": "",
//        "city": "",
//        "image_link": "",
//        "mentioned_user_id": "",
//        "mentioned_item_id": "",
//        "advertising_url": "",
//        "created_at": "1463799373"
//    }
//}


//aps =     {
//    badge = 108;
//    "content-available" = 1;
//    data =         {
//        body = "KeiEi left you a review: Nice";
//    };
//};
//target =     {
//    "alert_id" = 13397;
//    "created_at" = 1463826986;
//    id = 1492;
//    "receiver_id" = 177;
//    type = Review;
//    "user_id" = 412;
//};

@interface Notification : BaseObject
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSUInteger badge;

@property (nonatomic, strong) NSString *contextDevice;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *image_link;
@property (nonatomic, strong) NSString *mentioned_user_id;
@property (nonatomic, strong) NSString *mentioned_item_id;
@property (nonatomic, strong) NSString *advertising_url;
@property (nonatomic, strong) id        id;
@property (nonatomic, strong) id        receiver_id;
@property (nonatomic, strong) id        user_id;
@property (nonatomic, strong) id        item_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id        alert_id;
@property (nonatomic, strong) NSDictionary *userInfo;

- (BOOL)shouldHanldeThisNotification;
- (BOOL)isLocationMatched;
- (NSString *)getMessage;
@end
