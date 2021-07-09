//
//  Utils.h
//  HeyDenmark
//
//  Created by Phan Nam on 11/28/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/cdefs.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <sys/types.h>

#include <net/if.h>
#include <net/if_dl.h>
#include <net/ethernet.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <errno.h>
#include <ifaddrs.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#import "Categories.h"

@interface Utils : NSObject
+ (NSDateFormatter *)ISO8601_DATE_FORMAT;
+ (NSString *)getValueNotNil:(NSDictionary *)dict key:(NSString *)key;
+ (CGFloat)calculateHeightOfText:(NSString*)aText font:(UIFont*)aFont constrainedSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
+ (CGFloat)calculateWidthOfText:(NSString*)aText font:(UIFont*)aFont constrainedSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
+ (void)showAlertNoInteractiveWithTitle:(NSString *)title message:(NSString *)message;
+ (CGFloat)calculateHeightForNumberOfLine:(NSInteger)lineNum width:(CGFloat)width font:(UIFont *)font;
+ (CGFloat)calculateWidthForString:(NSString *)str withHeight:(CGFloat)height andFont:(UIFont *)font;
+ (CGFloat)calculateHeightForString:(NSString *)str withWidth:(CGFloat)width andFont:(UIFont *)font;
+ (NSString*)base64forData:(NSData*)theData;
+ (NSString *)predefineStringInXML:(NSString *)aRoughString;
+ (NSString *)makeCleanXMLString:(NSString *)aRoughString;
+ (NSString *)convertWeekDay:(NSInteger)weekday;
+ (void)addFitConstraintToView:(UIView *)parent subView:(UIView *)subview;
+ (NSString *)truncatedStringFrom:(NSString *)string toFit:(UIFont *)font atPixel:(CGFloat)pixel;
+ (NSString *)getCachedFonderPath;
+ (void)createFolderPathIfNotExist:(NSString *)aFolderPath;
+ (NSString *)checkNil:(id)obj;
+ (NSString *)checkNil:(id)obj defaultValue:(NSString *)defaultValue;
+ (id)checkNull:(id)obj;
+ (NSLayoutConstraint *)constraintWithItem:(UIView *)item1 item2:(UIView *)item2 attribute:(NSLayoutAttribute)aLayoutAttribute constant:(CGFloat)aConstant;
+ (NSLayoutConstraint *)constraintWithItem:(UIView *)item1 item2:(UIView *)item2 attribute:(NSLayoutAttribute)aLayoutAttribute multiplier:(CGFloat)aMultiplier constant:(CGFloat)aConstant;
+ (NSString *)generateLocationStringFrom:(NSString *)anAddress city:(NSString *)aCity state:(NSString *)aState country:(NSString *)aCountry;
+ (NSString *)convertEmojiToUnicode:(NSString *)emojiText;
+ (NSString *)convertUnicodeToEmoji:(NSString *)unicodeText;
+ (BOOL)isNilOrNull:(id)obj;
+ (NSDictionary *)getDictionaryFromObject:(id)obj;
+ (BOOL)checkEmojiLanguage:(NSString *)primaryLanguage;
@end
