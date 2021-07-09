//
//  DateTimeUtil.h
//  EventCollection
//
//  Created by Phan Nam on 7/14/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeUtil : NSObject
+ (NSDateComponents *)decomposeDate:(NSDate *)date;
+ (NSDate *)generateBeginningDateFromComponent:(NSDateComponents *)component;
+ (NSString *)convertFromMiliseconds:(float)time;
+ (NSString *)convertFromSeconds:(float)time;
+ (NSString *)convertTimeForPlaybackFromSeconds:(float)secs hasHour:(BOOL)hasHour;
+ (NSString *)convertTimeForNativePlaybackFromSeconds:(float)secs hasHour:(BOOL)hasHour;
+ (float)convertFromString:(NSString *)duration;
+ (NSDate *)parseISO8601:(NSString *)iso8601;
+ (NSString *)formatFriendlyDateTime:(NSDate *)date;
+ (NSString *)formatFriendlyDuration:(NSDate *)date;
+ (NSString *)formatDate:(NSDate *)date withTrailingDetails:(BOOL)withTrailingDetails withTime:(BOOL)withTime forceDuration:(BOOL)forceDuration;
+ (void)setLocalizationStringKey:(NSString *)key value:(NSString *)value;
@end
