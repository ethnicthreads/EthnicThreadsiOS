//
//  DateTimeUtil.m
//  EventCollection
//
//  Created by Phan Nam on 7/14/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import "DateTimeUtil.h"

static double ONE_MIN					=	60;
static double ONE_HOUR				=	3600; //60 * ONE_MIN
static double ONE_DAY					=	86400;//24 * ONE_HOUR
static double ONE_MONTH				=	2592000;//30 * ONE_DAY

static double DATE_RANGE_MIN			=	3600;//ONE_HOUR;
static double DATE_RANGE_HOUR_MIN		=	21600;//6 * ONE_HOUR
static double DATE_RANGE_HOUR			=	86400;//ONE_DAY
static double DATE_RANGE_DAY_HOUR		=	259200;//3 * ONE_DAY
static double DATE_RANGE_DAY			=	2592000;//ONE_MONTH
static double DATE_RANGE_MONTH_DAY	=	7776000;//3 * ONE_MONTH
static double DATE_RANGE_MONTH		=	31104000;//12 * ONE_MONTH

static NSMutableDictionary *localizationMap = nil;


@interface DateTimeUtil()
+ (NSDateFormatter *)ISO8601_DATE_FORMAT;
+ (NSDateFormatter *)ISO8601_DATE_FORMAT_ALT;
+ (NSDateFormatter *)ISO8601_DATE_FORMAT_ALT2;
+ (NSDateFormatter *)getSimpleDateFormatter;
+ (NSDateFormatter *)getFullDateFormatter;
+ (NSString *)pl:(NSString *)base number:(double)number;
+ (NSString *)getStringFromKey:(NSString *)key;
@end

@implementation DateTimeUtil
+ (NSDateComponents *)decomposeDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth |
                    NSCalendarUnitDay | NSCalendarUnitHour |
                    NSCalendarUnitMinute | NSCalendarUnitSecond |
                    NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal |
                    NSCalendarUnitQuarter | NSCalendarUnitWeekOfMonth |
                    NSCalendarUnitWeekOfYear;
    return [calendar components:unit fromDate:date];
}

+ (NSDate *)generateBeginningDateFromComponent:(NSDateComponents *)component {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = component.year;
    date.month = component.month;
    date.day = component.day;
    return [calendar dateFromComponents:date];
}

#pragma mark -
#pragma mark INTERNAL METHODS
+ (NSDateFormatter *)ISO8601_DATE_FORMAT
{
    static NSDateFormatter *ISO8601_DATE_FORMAT = nil;
    if (ISO8601_DATE_FORMAT == nil) {
        ISO8601_DATE_FORMAT = [[NSDateFormatter alloc] init];
        [ISO8601_DATE_FORMAT setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSTimeZone *UTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [ISO8601_DATE_FORMAT setTimeZone:UTC];
    }
    return ISO8601_DATE_FORMAT;
}

+ (NSDateFormatter *)ISO8601_DATE_FORMAT_ALT
{
    static NSDateFormatter *ISO8601_DATE_FORMAT_ALT = nil;
    if (ISO8601_DATE_FORMAT_ALT == nil) {
        ISO8601_DATE_FORMAT_ALT = [[NSDateFormatter alloc] init];
        [ISO8601_DATE_FORMAT_ALT setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    }
    return ISO8601_DATE_FORMAT_ALT;
}

+ (NSDateFormatter *)ISO8601_DATE_FORMAT_ALT2
{
    static NSDateFormatter *ISO8601_DATE_FORMAT_ALT2 = nil;
    if (ISO8601_DATE_FORMAT_ALT2 == nil) {
        ISO8601_DATE_FORMAT_ALT2 = [[NSDateFormatter alloc] init];
        [ISO8601_DATE_FORMAT_ALT2 setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
        NSTimeZone *UTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [ISO8601_DATE_FORMAT_ALT2 setTimeZone:UTC];
    }
    return ISO8601_DATE_FORMAT_ALT2;
}

+ (NSDateFormatter *)getSimpleDateFormatter
{
    static NSDateFormatter *simpleDateFormatter = nil;
    if (simpleDateFormatter == nil) {
        simpleDateFormatter = [[NSDateFormatter alloc] init];
        [simpleDateFormatter setDateFormat:[DateTimeUtil getStringFromKey:@"format_date_friendly_simplepattern"]];
    }
    return simpleDateFormatter;
}

+ (NSDateFormatter *)getFullDateFormatter {
    static NSDateFormatter *fullDateFormatter = nil;
    if (fullDateFormatter == nil) {
        fullDateFormatter = [[NSDateFormatter alloc] init];
        [fullDateFormatter setDateFormat:[DateTimeUtil getStringFromKey:@"format_date_friendly_fullpattern"]];
    }
    return fullDateFormatter;
}

+ (NSString *)pl:(NSString *)base number:(double)number
{
    if (number < 2) return base;
    return [base stringByAppendingString:@"s"];
}

+ (NSString *)getStringFromKey:(NSString *)key
{
    return [localizationMap objectForKey:key];
}
#pragma mark -
#pragma mark PUBLIC METHODS METHODS
+ (NSString *)convertFromMiliseconds:(float)time
{
    int secs = time / 1000;
    int hour = secs / 3600;
    int mins = (secs - hour * 3600) / 60;
    secs = (secs - hour * 3600 - mins * 60);
    if (hour > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, (int)secs];
    }
    else if (mins > 0) {
        return [NSString stringWithFormat:@"%02d:%02d", mins, (int)secs];
    }
    return [NSString stringWithFormat:@"%02d", (int)secs];
}

+ (NSString *)convertFromSeconds:(float)time
{
    return [DateTimeUtil convertFromMiliseconds:time * 1000];
}

+ (NSString *)convertTimeForPlaybackFromSeconds:(float)secs hasHour:(BOOL)hasHour
{
    int hour = secs / 3600;
    int mins = (secs - hour * 3600) / 60;
    secs = (secs - hour * 3600 - mins * 60);
    if (hour > 0 || hasHour) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins, (int)secs];
    }
    return [NSString stringWithFormat:@"%02d:%02d", mins, (int)secs];
}

+ (NSString *)convertTimeForNativePlaybackFromSeconds:(float)secs hasHour:(BOOL)hasHour
{
    int hour = secs / 3600;
    int mins = (secs - hour * 3600) / 60;
    secs = (secs - hour * 3600 - mins * 60);
    if (hour > 0 || hasHour) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hour, mins, (int)secs];
    }
    return [NSString stringWithFormat:@"%d:%02d", mins, (int)secs];
}

+ (float)convertFromString:(NSString *)duration
{
    float total = 0.0f;
    if (duration != nil) {
        NSMutableArray *split = [NSMutableArray arrayWithArray:[duration componentsSeparatedByString:@":"]];
        int multiple = 1;
        while ([split count] > 0) {
            total += [[split lastObject] floatValue] * multiple;
            [split removeLastObject];
            multiple *= 60;
        }
    }
    return total;
}
/**
 * Parse an ISO8601-compliant string to create a NSDate object.
 * @param iso8601
 * @return
 */
+ (NSDate *)parseISO8601:(NSString *)iso8601
{
    NSDate *date = nil;
    
    @try {
        date = [[DateTimeUtil ISO8601_DATE_FORMAT] dateFromString:iso8601];
    } @catch (NSException *e) {
        @try {
            date = [[DateTimeUtil ISO8601_DATE_FORMAT_ALT] dateFromString:iso8601];
        }
        @catch (NSException *exception) {
            @try {
                date = [[DateTimeUtil ISO8601_DATE_FORMAT_ALT2] dateFromString:iso8601];
            }
            @catch (NSException *exception) {
                //do nothing
            }
        }
    }
    return date;
}

+ (NSString *)formatFriendlyDateTime:(NSDate *)date
{
    return [DateTimeUtil formatDate:date withTrailingDetails:FALSE withTime:FALSE forceDuration:FALSE];
}

+ (NSString *)formatFriendlyDuration:(NSDate *)date
{
    return [DateTimeUtil formatDate:date withTrailingDetails:FALSE withTime:FALSE forceDuration:TRUE];
}

+ (NSString *)formatDate:(NSDate *)date withTrailingDetails:(BOOL)withTrailingDetails withTime:(BOOL)withTime forceDuration:(BOOL)forceDuration
{
    if (date == nil) return @"Unknow date";
    NSDateFormatter *fullDateFormatter = [DateTimeUtil getFullDateFormatter];
    NSDateFormatter *simpleDateFormatter = [DateTimeUtil getSimpleDateFormatter];
    
    NSDate *now = [NSDate date];
    
    double diff = [now timeIntervalSinceDate:date];
    diff = (diff < 0) ? (-1 * diff) : diff;
    double diff2 = diff;
    
    int mo = diff2 / ONE_MONTH;
    diff2 -= mo * ONE_MONTH;
    
    int d = diff2 / ONE_DAY;
    diff2 -= d * ONE_DAY;
    
    int h = diff2 / ONE_HOUR;
    diff2 -= h * ONE_HOUR;
    
    int m = diff2 / ONE_MIN;
    
    NSDateFormatter *selectedFormatter = withTime ? fullDateFormatter : simpleDateFormatter;
    
    NSString *full = [selectedFormatter stringFromDate:date];
    NSString *trailing = (withTrailingDetails && !forceDuration) ? [NSString stringWithFormat:@" (%@)", full] : @"";
    
    NSString *keyPrefix = forceDuration ? @"format_date_friendly_duration" : @"format_date_friendly";
    
    if (diff < DATE_RANGE_MIN) {
        if (m <= 0) m = 1;
        keyPrefix = [NSString stringWithFormat:@"%@%@", keyPrefix, [DateTimeUtil pl:@"_minute" number:m]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], m];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_HOUR_MIN && m > 0) {
        keyPrefix = [NSString stringWithFormat:@"%@%@%@", keyPrefix,
                     [DateTimeUtil pl:@"_hour" number:h],
                     [DateTimeUtil pl:@"_minute" number:m]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], h, m];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_HOUR) {
        keyPrefix = [NSString stringWithFormat:@"%@%@", keyPrefix, [DateTimeUtil pl:@"_hour" number:h]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], h];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_DAY_HOUR && h > 0) {
        keyPrefix = [NSString stringWithFormat:@"%@%@%@", keyPrefix,
                     [DateTimeUtil pl:@"_day" number:d],
                     [DateTimeUtil pl:@"_hour" number:h]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], d, h];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_DAY) {
        keyPrefix = [NSString stringWithFormat:@"%@%@", keyPrefix, [DateTimeUtil pl:@"_day" number:d]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], d];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_MONTH_DAY && d > 0) {
        keyPrefix = [NSString stringWithFormat:@"%@%@%@", keyPrefix,
                     [DateTimeUtil pl:@"_month" number:mo],
                     [DateTimeUtil pl:@"_day" number:d]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], mo, d];
        return [keyPrefix stringByAppendingString:trailing];
    } else if (diff < DATE_RANGE_MONTH) {
        keyPrefix = [NSString stringWithFormat:@"%@%@", keyPrefix, [DateTimeUtil pl:@"_month" number:mo]];
        keyPrefix = [NSString stringWithFormat:[DateTimeUtil getStringFromKey:keyPrefix], mo];
        return [keyPrefix stringByAppendingString:trailing];
    } else {
        return forceDuration ? @"" : full;
    }
}

+ (void)setLocalizationStringKey:(NSString *)key value:(NSString *)value
{
    if (localizationMap == nil) {
        localizationMap = [[NSMutableDictionary alloc] init];
    }
    [localizationMap setObject:value forKey:key];
}
@end
