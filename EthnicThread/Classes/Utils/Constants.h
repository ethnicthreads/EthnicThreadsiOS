//
//  Constants.h
//  HeyDenmark
//
//  Created by Phan Nam on 11/28/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#ifndef EthnicThread_Constants_h
#define EthnicThread_Constants_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#if CONFIGURATION_DEBUG

#define DebugLog(format, ...) DLog((@"%s: %d: %s: " format),\
__FILE__,\
__LINE__,\
__FUNCTION__,\
##__VA_ARGS__)
#else
#define DebugLog(format, ...)
#endif
#endif

#if CONFIGURATION_DEBUG
#        define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#        define ENVIRONMENT @"development"
#else
#        define DLog(...)
#        define ENVIRONMENT @"production"
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPHONE_4 (((double)[[UIScreen mainScreen] bounds].size.height) == ((double)480))
#define IS_IPHONE_5 (((double)[[UIScreen mainScreen] bounds].size.height) == ((double)568))

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define GALLERY_SCROLLVIEW_SIZE     CGSizeMake([UIScreen mainScreen].bounds.size.width, 263)
#define AVATAR_SIZE                 CGSizeMake(50, 50)

#define BLACK_COLOR_TEXT                    UIColorFromRGB(0x4d4d4d) // 77 77 77
#define LIGHT_BLACK_COLOR_TEXT              UIColorFromRGB(0x939393)//147 147 147
#define RED_COLOR                           UIColorFromRGB(0xf25a71)
#define GREEN_COLOR                         UIColorFromRGB(0x01c19a)
#define PURPLE_COLOR                        UIColorFromRGB(0xa963a9)
#define ORANGE_COLOR                        UIColorFromRGB(0xffa200)
#define LIGHT_PURPLE_COLOR                  UIColorFromRGB(0xeadbea)
#define GRAY_COLOR                          UIColorFromRGB(0xe6e6e6)
#define LIGHT_GRAY_COLOR                    UIColorFromRGB(0xf0f0f0)
#define WHITE_TRANSPERENT_COLOR             UIColorFromRGB(0x80FFFFFF)

#define UPDATE_FOLLOWED_USER_NOTIFICATION               @"update_following_notification"
#define UPDATE_RATE_USER_NOTIFICATION                   @"update_rate_notification"
#define UPDATE_WISHLISTED_ITEM_NOTIFICATION             @"update_wishlisted_notification"
#define UPDATE_COMMENT_OF_ITEM_NOTIFICATION             @"update_comments_notification"
#define UPDATE_LIKED_ITEM_NOTIFICATION                  @"update_liked_notification"
#define UPDATE_ITEM_NOTIFICATION                        @"update_item_notification"
#define FLAG_ITEM_NOTIFICATION                          @"flag_item_notification"
#define DELETE_ITEM_NOTIFICATION                        @"delete_item_notification"
#define WILL_LOGIN_NOTIFICATION                         @"will_log_in_notification"
#define DID_LOGIN_NOTIFICATION                          @"did_log_in_notification"
#define DID_LOGOUT_NOTIFICATION                         @"did_log_out_notification"
#define NOTIFICATION_USERINFO_KEY                       @"notification_userinfo_key"
#define DOWNLOAD_COMPLETED_NOTIFICATION                 @"DownloadCompleted"

#define UPDATE_BADGE_NUMBER                             @"update_badge_number"
#define UPDATE_CURRENT_LOCATION                         @"update_current_location"

#define MAIN_FONT_REGULAR                               @"Trim-Regular"
#define MAIN_FONT_LIGHT                                 @"Trim-Light"
#define MAIN_FONT_BOLD                                  @"Trim-ExtraBold"
#define LARGE_FONT_SIZE                                 17.0f
#define MEDIUM_FONT_SIZE                                15.0f
#define SMALL_FONT_SIZE                                 13.0f
#define MINI_FONT_SIZE                                  11.0f

#define MIN_HEIGHT_MESSAGE_TABLEVIEWCELL                80.0f

#define FACEBOOK_AVATAR_FORMAT_URL                      @"https://graph.facebook.com/%@/picture?type=large"

#define DATETIME_FORMAT_STRING                          @"MMM dd, yyyy HH:mm"
#define DATE_FORMAT_STRING                              @"MMM dd, yyyy"

#define USER_THUMB                                      @"user_thumb.png"
#define ITEM_THUMB                                      @"thum_img.png"

#define PROMOTIONBAR_HEIGHT                             50

#define CURRENCIES                                      @[@"$", @"Rs. ", @"C$", @"£", @"€", @"CHF", @"BHD", @"KWD", @"AED", @"Tk", @"FJ$"]
#define DEFAULT_CURENTCY_INDEX                          0

#define CONTACT_US_EMAIL                                @"support@ethnicthread.com"
#define FAQ_URL                                         @"http://www.ethnicthread.com/site/faq.html"
#define APP_LINK                                        @"http://www.ethnicthread.com/app.html"
#define PROFILE_LINK                                    @"http://www.ethnicthread.com/seller/id="
#define APP_SCHEME                                      @"ethnicthread"
#define EULA_URL                                        @"http://www.ethnicthread.com/eula.html"

#define IMAGE_ITEM_WIDTH                                828

#define ID_KEY                                          @"ID Key"
// Alert types
#define ALERT_TYPE_SELLING  @"SellingItem"
#define ALERT_TYPE_MESSAGE @"Message"
#define  ALERT_TYPE_USER @"User"
#define  ALERT_TYPE_COMMENT @"Comment"
#define  ALERT_TYPE_REVIEW @"Review"

// GCM Notification type
#define  GCM_TYPE_REVIEW @"Review"
#define  GCM_TYPE_LIKE @"Like"
#define  GCM_TYPE_COMMENT @"Comment"
#define  GCM_TYPE_FOLLOW @"Follow"
#define  GCM_TYPE_MESSAGE @"Message"
#define  GCM_TYPE_NEW_ITEM @"Item"

#define  CONTEXT_ANY_DEVICE @"any_device"
#define  CONTEXT_REGISTERED_DEVICE @"registered_device"
#define  CONTEXT_UNREGISTERED_DEVICE @"unregistered_device"
#define  EXTRA_MESSAGE @"message"
#define  EXTRA_DATA @"data"
#define  EXTRA_TYPE @"type"

#define GCMSENDERID @"199107533674"
// Promotion Type
#define PROMOTION_TYPE_PRODUCT  @"PRODUCT"
#define PROMOTION_TYPE_LPRODUCT @"LPRODUCT"
#define PROMOTION_TYPE_TALENT   @"TALENT"
#define PROMOTION_TYPE_LTALENT  @"LTALENT"
#define PROMOTION_TYPE_CITY     @"CITY"
#define PROMOTION_TYPE_PEOPLE   @"PEOPLE"
#define PROMOTION_TYPE_ALL      @"ALL"
#define PROMOTION_TYPE_MORE     @"MORE"

typedef enum _PROCESSIMAGE {
    IMAGE_DONOTHING = 100,
    IMAGE_CROPCENTER,
    IMAGE_SCALE
} PROCESSIMAGE;

typedef enum _SEARCHTYPE {
    SIMPLE_SEARCH,
    FAVOURITE_SEARCH
} SEARCHTYPE;

typedef enum _ALERTTYPE {
    ALERTTYPE_UNKNOWN,
    ALERTTYPE_DELETEMESSAGE_CONFIRM,
    ALERTTYPE_ACCESS_STOREPROFILE,
    ALERTTYPE_WELCOME_MESSAGE
} ALERTTYPE;

typedef enum _REQUIRED_LOGIN_ACTION {
    ACTION_DO_NOTHING,
    ACTION_LIKE,
    ACTION_WISHLIST,
    ACTION_FLAG,
    ACTION_UPDATE_FOLLOWED_SELLER,
    ACTION_CONTACT_SELLER,
    ACTION_RATE_SELLER,
    ACTION_INVITE_FRIEND,
    ACTION_COMMENT_ITEM,
    ACTION_REVIEW_SELLER,
    ACTION_POST_SOMETHING
} REQUIRED_LOGIN_ACTION;

typedef NS_ENUM(NSInteger, CHANNELS) {
    CHANNEL_UNKNOWN,
    CHANNEL_UI,
    CHANNEL_DATA
};

typedef NS_ENUM(NSUInteger, EVENTTYPE) {
    ET_UNKNOWN,
    ET_SIGNIN,
    ET_OPEN_ITEM,
    ET_OPEN_SELLER,
    ET_DISABLE_LOCATION,
    ET_DID_TURN_ON_LOCATION,
    ET_DID_TURN_ON_NOTIFICATION,
    ET_SHOW_NO_LOCATION_VIEW,
    ET_SHOULD_OPEN_CRITERIA
};
#endif
