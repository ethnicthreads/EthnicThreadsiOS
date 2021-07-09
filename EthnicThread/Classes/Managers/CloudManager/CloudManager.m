//
//  CloudManager.m
//  REP
//
//  Created by Phan Nam on 8/3/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "CloudManager.h"
#import "CloudDispatch.h"
#import "Utils.h"
#import "Categories.h"
#import "Constants.h"
#import "AppManager.h"
#import "Utils.h"

@implementation CloudManager

+ (Response *)downloadPhotoWithUrl:(NSString *)url {
    Request *request = [[Request alloc] init];
    request.service = @"";
    request.entry = @"";
    request.method = @"GET";
    request.shouldPrintLog = NO;
    request.rqType = RQ_GETCACHEFIRST | RQ_SAVEDATA;
    request.cacheType = CT_THUMBNAIL;
    [request setCustomUrl:url];
    
	Response *response = [[Response alloc] init];
    response.shouldParseResponse = NO;
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)logInViaFacebook:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"LoginFacebook";
    request.method = @"POST";
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
    request.shouldSilentLogin = NO;
    request.shouldAddAccesToken = NO;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)signUpViaEmail:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"SignupEmail";
    request.method = @"POST";
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
    request.shouldSilentLogin = NO;
    request.shouldAddAccesToken = NO;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)logInViaEmail:(NSString *)email andPassword:(NSString *)password {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"LoginEmail";
    request.method = @"POST";
    [request setAdditionalHeaderName:@"login" value:email];
    [request setAdditionalHeaderName:@"password" value:password];
    request.shouldSilentLogin = NO;
    request.shouldAddAccesToken = NO;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)updateUserProfile:(NSString *)userId andFormValue:(NSDictionary *)dict {
    ETMultipartRequest *request = [[ETMultipartRequest alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"PUT";
    request.trailingParam = userId;
    
    NSMutableArray *multiparts = [[NSMutableArray alloc] init];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:@"avatar"]) {
            NSString *filePath = [dict objectForKey:key];
            MultipartFileURL *multipartURL;
            NSURL *filePathURL;
            if (![filePath hasPrefix:@"file://"]) {
                filePathURL = [NSURL fileURLWithPath:filePath];
            }
            else {
                filePathURL = [NSURL URLWithString:filePath];
            }
            if (filePathURL != nil) {
                multipartURL = [[MultipartFileURL alloc] init];
                multipartURL.name = key;
                multipartURL.fileURL = filePathURL;
                multipartURL.fileName = [filePath lastPathComponent];
                [multiparts addObject:multipartURL];
            }
        }
        else {
            MultipartData *multipart = [[MultipartData alloc] init];
            multipart.name = key;
            multipart.data = [dict objectForKey:key];
            [multiparts addObject:multipart];
        }
    }
    
    request.multiparts = [NSArray arrayWithArray:multiparts];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getUserProfile:(NSString *)userId {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"GET";
    request.trailingParam = userId;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getAddress:(REQUEST_TYPE)reguestType {
    Request *request = [[Request alloc] init];
    request.service = @"Common";
    request.entry = @"Address";
    request.method = @"GET";
    request.rqType = reguestType;
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getCountries:(REQUEST_TYPE)reguestType {
    Request *request = [[Request alloc] init];
    request.service = @"Common";
    request.entry = @"Country";
    request.method = @"GET";
    request.rqType = reguestType;
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItems:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"GET";
    [request addParameter:@"category" value:isService ? @"service" : @"listed"];
    [request addParameter:@"country" value:country];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItemsWithCriteria:(PromotionCriteria *)criteriaID isService:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Promotion";
    request.entry = @"Criteria";
    request.method = @"GET";
    [request setTrailingParam:[NSString stringWithFormat:@"/%@", [criteriaID.id description]]];
    if (![criteriaID.promotionType isEqualToString:PROMOTION_TYPE_PEOPLE]) {
        [request addParameter:@"category" value:isService ? @"service" : @"listed"];
    }
    [request addParameter:@"country" value:country];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItemsWithLimitedCriteria:(PromotionCriteria *)criteriaID isService:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per radius:(NSUInteger)radius location:(CLLocation *)location{
    Request *request = [[Request alloc] init];
    request.service = @"Promotion";
    request.entry = @"Criteria";
    request.method = @"GET";
    [request setTrailingParam:[NSString stringWithFormat:@"/%@", [criteriaID.id description]]];
    if (![criteriaID.promotionType isEqualToString:PROMOTION_TYPE_PEOPLE]) {
        [request addParameter:@"category" value:isService ? @"service" : @"listed"];
    }
    if (![Utils isNilOrNull:country]) {
        [request addParameter:@"country" value:country];
    }
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    // Append Limited Criteria
    [request addParameter:@"radius" value:[NSString stringWithFormat:@"%d", radius]];
    if (![Utils isNilOrNull:location]) {
        [request addParameter:@"latitude" value:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
        [request addParameter:@"longtitude" value:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
    }
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)searchItems:(SearchCriteria *)criteria andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Search";
    request.method = @"GET";
//    request.shouldAddAccesToken = YES;
    
    NSDictionary *dict = [criteria makeDictionary];
    for (NSString *key in [dict allKeys]) {
        [request addParameter:key value:[dict objectForKey:key]];
    }
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)addCommentForItem:(NSString *)itemId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/comments", itemId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)editCommentOfItem:(NSString *)itemId withCommentId:(NSString *)commentId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"PUT";
    request.trailingParam = [NSString stringWithFormat:@"%@/comments/%@", itemId, commentId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)deleteCommentOfItem:(NSString *)itemId withCommentId:(NSString *)commentId {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"DELETE";
    request.trailingParam = [NSString stringWithFormat:@"%@/comments/%@", itemId, commentId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getCommentsByItem:(NSString *)itemId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/comments", itemId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)likeItem:(NSString *)itemId {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/like", itemId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)wishlishItem:(NSString *)itemId {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/add_to_wish_list", itemId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)addReviewForSeller:(NSString *)sellerId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/reviews", sellerId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)editReviewOfSeller:(NSString *)sellerId withReviewId:(NSString *)reviewId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"PUT";
    request.trailingParam = [NSString stringWithFormat:@"%@/reviews/%@", sellerId, reviewId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)acceptFriendInvitation:(NSString *)invitationCode {
    Request *request = [[Request alloc] init];
    request.service = @"Friend";
    request.entry = @"Invitation";
    request.method = @"PUT";
    request.trailingParam = invitationCode;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)deleteReviewOfSeller:(NSString *)sellerId withReviewId:(NSString *)reviewId {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"DELETE";
    request.trailingParam = [NSString stringWithFormat:@"%@/reviews/%@", sellerId, reviewId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getReviewsBySeller:(NSString *)sellerId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/reviews", sellerId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    request.shouldSilentLogin = NO;
    request.shouldAddAccesToken = NO;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getTags:(REQUEST_TYPE)reguestType {
    Request *request = [[Request alloc] init];
    request.service = @"Common";
    request.entry = @"Tags";
    request.method = @"GET";
    request.rqType = reguestType;
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getPromotionCriteria {
    Request *request = [[Request alloc] init];
    request.service = @"Promotion";
    request.entry = @"Criteria";
    request.method = @"GET";
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getServiceTags:(REQUEST_TYPE)reguestType {
    Request *request = [[Request alloc] init];
    request.service = @"Common";
    request.entry = @"ServiceTags";
    request.method = @"GET";
    request.rqType = reguestType;
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)addNewItem:(CreativeItemModel *)createdItem {
    ETMultipartRequest *request = [[ETMultipartRequest alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.shouldPrintLog = YES;
    
    NSMutableArray *multiparts = [[NSMutableArray alloc] init];
    NSDictionary *dict = [createdItem makeDictionary];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:IMAGE_URLS_KEY]) {
            NSArray *filePaths = [dict objectForKey:key];
            for (int i = 0; i < filePaths.count; i++) {
                NSString *filePath = [filePaths objectAtIndex:i];
                MultipartFileURL *multipartURL;
                NSURL *filePathURL;
                if (![filePath hasPrefix:@"file://"]) {
                    filePathURL = [NSURL fileURLWithPath:filePath];
                }
                else {
                    filePathURL = [NSURL URLWithString:filePath];
                }
                if (filePathURL != nil) {
                    multipartURL = [[MultipartFileURL alloc] init];
                    multipartURL.name = [NSString stringWithFormat:@"image%d", i + 1];
                    multipartURL.fileURL = filePathURL;
                    multipartURL.fileName = [filePath lastPathComponent];
                    [multiparts addObject:multipartURL];
                }
            }
        }
        else {
            MultipartData *multipart = [[MultipartData alloc] init];
            multipart.name = key;
            multipart.data = [dict objectForKey:key];
            [multiparts addObject:multipart];
        }
    }
    request.multiparts = [NSArray arrayWithArray:multiparts];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)updateItem:(UpdateItemModel *)updateItem {
    ETMultipartRequest *request = [[ETMultipartRequest alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"PUT";
    request.shouldPrintLog = YES;
    
    NSMutableArray *multiparts = [[NSMutableArray alloc] init];
    NSDictionary *dict = [updateItem makeDictionary];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:IMAGE_URLS_KEY]) {
            NSArray *filePaths = [dict objectForKey:key];
            for (int i = 0; i < filePaths.count; i++) {
                NSString *filePath = [filePaths objectAtIndex:i];
                MultipartFileURL *multipartURL;
                NSURL *filePathURL;
                if (![filePath hasPrefix:@"file://"]) {
                    filePathURL = [NSURL fileURLWithPath:filePath];
                }
                else {
                    filePathURL = [NSURL URLWithString:filePath];
                }
                if (filePathURL != nil) {
                    multipartURL = [[MultipartFileURL alloc] init];
                    multipartURL.name = [NSString stringWithFormat:@"image%d", i + 1];
                    multipartURL.fileURL = filePathURL;
                    multipartURL.fileName = [filePath lastPathComponent];
                    [multiparts addObject:multipartURL];
                }
            }
        }
        else {
            MultipartData *multipart = [[MultipartData alloc] init];
            multipart.name = key;
            multipart.data = [dict objectForKey:key];
            [multiparts addObject:multipart];
        }
    }
    request.multiparts = [NSArray arrayWithArray:multiparts];
    request.trailingParam = [updateItem getIdString];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)markFlagOnItem:(ItemModel *)item {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"PUT";
    request.shouldPrintLog = YES;
    
//    NSMutableArray *multiparts = [[NSMutableArray alloc] init];
//    MultipartData *multipart = [[MultipartData alloc] init];
//    multipart.name = @"flags";
//    multipart.data = @(1);
//    [multiparts addObject:multipart];
    
//    request.multiparts = [NSArray arrayWithArray:multiparts];
    request.trailingParam = [NSString stringWithFormat:@"%@/flags", [item getIdString]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItemsByIds:(NSString *)itemIds {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Collection";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@", itemIds];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItemsBySellerId:(NSString *)sellerId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/items", sellerId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)removeItem:(NSString *)itemId {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"DELETE";
    request.trailingParam = itemId;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)markItem:(NSString *)itemId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/mark_status", itemId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getMessagesWithUser:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Chat";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/messages", userId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getMessagesWithUser:(NSString *)userId byMessageId:(NSString *)messId {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Chat";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/messages/%@", userId, messId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)sendMessageToUser:(NSString *)userId andBody:(NSDictionary *)dict {
//+ (Response *)updateUserProfile:(NSString *)userId andFormValue:(NSDictionary *)dict {
    ETMultipartRequest *request = [[ETMultipartRequest alloc] init];
    request.service = @"Account";
    request.entry = @"Chat";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/messages", userId];
    
    NSMutableArray *multiparts = [[NSMutableArray alloc] init];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:@"file"]) {
            NSString *filePath = [dict objectForKey:key];
            MultipartFileURL *multipartURL;
            NSURL *filePathURL;
            if (![filePath hasPrefix:@"file://"]) {
                filePathURL = [NSURL fileURLWithPath:filePath];
            }
            else {
                filePathURL = [NSURL URLWithString:filePath];
            }
            if (filePathURL != nil) {
                multipartURL = [[MultipartFileURL alloc] init];
                multipartURL.name = key;
                multipartURL.fileURL = filePathURL;
                multipartURL.fileName = [filePath lastPathComponent];
                [multiparts addObject:multipartURL];
            }
        }
        else {
            MultipartData *multipart = [[MultipartData alloc] init];
            multipart.name = key;
            multipart.data = [dict objectForKey:key];
            [multiparts addObject:multipart];
        }
    }
    
    request.multiparts = [NSArray arrayWithArray:multiparts];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

//+ (Response *)sendMessageToUser:(NSString *)userId andBody:(NSString *)body {
//    Request *request = [[Request alloc] init];
//    request.service = @"Account";
//    request.entry = @"Chat";
//    request.method = @"POST";
//    request.trailingParam = [NSString stringWithFormat:@"%@/messages", userId];
//    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
//    [request setAdditionalHeaderName:@"Content-Type" value:@"application/json"];
//    
//    Response *response = [[Response alloc] init];
//    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
//    return response;
//}

+ (Response *)getThreadsFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Threads";
    request.method = @"GET";
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)deleteThread:(NSString *)userId {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"DELETE";
    request.trailingParam = [NSString stringWithFormat:@"%@/thread", userId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getMyFollowers:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/followers", userId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getIAmLollowing:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"GET";
    request.trailingParam = @"follows";
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)updateFollowASeller:(NSString *)sellerId {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/follow", sellerId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getItemsInWishlistFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Wishlist";
    request.method = @"GET";
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getSlideShows {
    Request *request = [[Request alloc] init];
    request.service = @"Common";
    request.entry = @"SlideShows";
    request.method = @"GET";
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)rateSeller:(NSString *)sellerId andBody:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Profile";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/rate", sellerId];
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getLikersByItem:(NSString *)itemId andFromPage:(NSInteger)page andPer:(NSInteger)per {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"GET";
    request.trailingParam = [NSString stringWithFormat:@"%@/likers", itemId];
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)searchSellerNameByCharacters:(NSString *)characters {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"Search";
    request.method = @"GET";
    [request addParameter:@"name" value:characters];
    request.rqType = RQ_GETCACHEIFFAILED | RQ_SAVEDATA;
    request.cacheType = CT_RESPONSE;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)updateDeviceToken:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Register";
    request.entry = @"DeviceToken";
    request.method = @"POST";
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)notifyToAllFollowers:(NSString *)itemId {
    Request *request = [[Request alloc] init];
    request.service = @"Item";
    request.entry = @"Items";
    request.method = @"POST";
    request.trailingParam = [NSString stringWithFormat:@"%@/send_notifications_to_followers", itemId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)getNotificatiosFromPage:(NSInteger)page andPer:(NSInteger)per requestType:(REQUEST_TYPE)reguestType {
    Request *request = [[Request alloc] init];
    request.service = @"Notification";
    request.entry = @"Alert";
    request.method = @"GET";
    request.rqType = reguestType;
    request.cacheType = CT_RESPONSE;
    [request addParameter:@"page" value:[NSString stringWithFormat:@"%ld", (long)page]];
    [request addParameter:@"per" value:[NSString stringWithFormat:@"%ld", (long)per]];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)dismissNotification:(NSString *)alertId {
    Request *request = [[Request alloc] init];
    request.service = @"Notification";
    request.entry = @"Alert";
    request.method = @"DELETE";
    request.trailingParam = [NSString stringWithFormat:@"%@/dismiss", alertId];
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)dismissAllNotifications {
    Request *request = [[Request alloc] init];
    request.service = @"Notification";
    request.entry = @"DismissAll";
    request.method = @"DELETE";
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}

+ (Response *)resetPassword:(NSString *)body {
    Request *request = [[Request alloc] init];
    request.service = @"Account";
    request.entry = @"ForgotPassword";
    request.method = @"POST";
    request.customBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    request.shouldAddAccesToken = NO;
    
    Response *response = [[Response alloc] init];
    [[CloudDispatch shareInstance] dispatchRequest:request response:response];
    return response;
}
@end
