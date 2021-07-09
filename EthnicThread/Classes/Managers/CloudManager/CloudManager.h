//
//  CloudManager.h
//  REP
//
//  Created by Phan Nam on 8/3/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Request.h"
#import "Response.h"
#import "SearchCriteria.h"
#import "UpdateItemModel.h"
#import "PromotionCriteria.h"

@interface CloudManager : NSObject
+ (Response *)downloadPhotoWithUrl:(NSString *)url;
+ (Response *)logInViaFacebook:(NSString *)body;
+ (Response *)signUpViaEmail:(NSString *)body;
+ (Response *)logInViaEmail:(NSString *)email andPassword:(NSString *)password;
+ (Response *)updateUserProfile:(NSString *)userId andFormValue:(NSDictionary *)dict;
+ (Response *)getUserProfile:(NSString *)userId;
+ (Response *)getAddress:(REQUEST_TYPE)reguestType;
+ (Response *)getCountries:(REQUEST_TYPE)reguestType;
+ (Response *)getItems:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)searchItems:(SearchCriteria *)criteria andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)addCommentForItem:(NSString *)itemId andBody:(NSString *)body;
+ (Response *)editCommentOfItem:(NSString *)itemId withCommentId:(NSString *)commentId andBody:(NSString *)body;
+ (Response *)deleteCommentOfItem:(NSString *)itemId withCommentId:(NSString *)commentId;
+ (Response *)getCommentsByItem:(NSString *)itemId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)likeItem:(NSString *)itemId;
+ (Response *)wishlishItem:(NSString *)itemId;
+ (Response *)addReviewForSeller:(NSString *)sellerId andBody:(NSString *)body;
+ (Response *)editReviewOfSeller:(NSString *)sellerId withReviewId:(NSString *)reviewId andBody:(NSString *)body;
+ (Response *)deleteReviewOfSeller:(NSString *)sellerId withReviewId:(NSString *)reviewId;
+ (Response *)getReviewsBySeller:(NSString *)sellerId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)getTags:(REQUEST_TYPE)reguestType;
+ (Response *)getPromotionCriteria;
+ (Response *)getItemsWithCriteria:(PromotionCriteria *)criteriaID isService:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)getServiceTags:(REQUEST_TYPE)reguestType;
+ (Response *)addNewItem:(CreativeItemModel *)createdItem;
+ (Response *)updateItem:(UpdateItemModel *)updateItem;
+ (Response *)acceptFriendInvitation:(NSString *)invitationCode;
+ (Response *)markFlagOnItem:(ItemModel *)item;
+ (Response *)getItemsByIds:(NSString *)item_Ids; //item_ids = @"1,2,3,4"
+ (Response *)getItemsWithLimitedCriteria:(PromotionCriteria *)criteriaID isService:(BOOL)isService country:(NSString *)country fromPage:(NSInteger)page andPer:(NSInteger)per radius:(NSUInteger)radius location:(CLLocation *)location;
+ (Response *)getItemsBySellerId:(NSString *)sellerId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)removeItem:(NSString *)itemId;
+ (Response *)markItem:(NSString *)itemId andBody:(NSString *)body; //{"status":"sold,unavallable"}
+ (Response *)getMessagesWithUser:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)getMessagesWithUser:(NSString *)userId byMessageId:(NSString *)messId;
//+ (Response *)sendMessageToUser:(NSString *)userId andBody:(NSString *)body;
+ (Response *)sendMessageToUser:(NSString *)userId andBody:(NSDictionary *)dict;
+ (Response *)getThreadsFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)deleteThread:(NSString *)userId;
+ (Response *)getMyFollowers:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)getIAmLollowing:(NSString *)userId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)updateFollowASeller:(NSString *)sellerId;
+ (Response *)getItemsInWishlistFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)getSlideShows;
+ (Response *)rateSeller:(NSString *)sellerId andBody:(NSString *)body;
+ (Response *)getLikersByItem:(NSString *)itemId andFromPage:(NSInteger)page andPer:(NSInteger)per;
+ (Response *)searchSellerNameByCharacters:(NSString *)characters;
+ (Response *)updateDeviceToken:(NSString *)body;
+ (Response *)notifyToAllFollowers:(NSString *)itemId;
+ (Response *)getNotificatiosFromPage:(NSInteger)page andPer:(NSInteger)per requestType:(REQUEST_TYPE)reguestType;
+ (Response *)dismissNotification:(NSString *)alertId;
+ (Response *)dismissAllNotifications;
+ (Response *)resetPassword:(NSString *)body;
@end
