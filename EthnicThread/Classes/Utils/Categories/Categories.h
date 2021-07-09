//
//  Categories.h
//  Ethenic
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface NSString (Custom)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)urlDecodcodeUsingEncoding:(NSStringEncoding)decoding;;
- (NSString*)sha256WithKey:(NSString*)key;
- (NSString*)md5;
- (NSString *)AES256EncryptWithKey:(NSString *)key initVector:(NSData*)initVector;
- (NSString *)AES256DecryptWithKey:(NSString *)key initVector:(NSData*)initVector;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)trimText;
- (NSString *)resolveUnicodeString;
- (BOOL)containString:(NSString *)str;
- (NSString *)makeJsonEscapeCharacter;
- (NSDate *)convertToDateWithFormat:(NSString *)formatString;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)sizeWithFont:(UIFont *)font;
@end

#pragma mark - NSData category
@interface NSData (Custom)
- (NSData *)AES256EncryptWithKey:(NSString *)key initVector:(NSData*)initVector;
- (NSData *)AES256DecryptWithKey:(NSString *)key initVector:(NSData*)initVector;

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (id)initWithBase64EncodedString:(NSString *)string;

- (NSString *)base64Encoding;
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;

- (BOOL)hasPrefixBytes:(const void *)prefix length:(NSUInteger)length;
- (BOOL)hasSuffixBytes:(const void *)suffix length:(NSUInteger)length;
@end

#pragma mark - UIImage category
@interface UIImage (Custom)
- (UIImage *)scaleByWidth:(CGFloat)width;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)cropCenterToSize:(CGSize)size;
- (UIImage *)cropCenterToSize:(CGSize)size shouldScale:(BOOL)shouldScale;
- (UIImage *)imageByDrawingCircle;
+ (UIImage *)imageFromColor:(UIColor *)color;
@end

#pragma mark - NSDate category
@interface NSDate (Custom)
- (NSDate *)convertToUTCDate;
- (NSDate *)toLocalTime;
- (NSString *)convertToStringWithFormat:(NSString *)formatString;
@end

#pragma mark - UIView category
@interface UIView (Custom)
- (CGFloat)getYAxisAtBottomView;
- (UIImage *)convertToImage;
- (UIImage *)convertToImage:(BOOL)opaque;
@end

#pragma mark - UILabel category
@interface UILabel (Custom)
- (CGFloat)calculateSuitableHeight;
- (CGFloat)calculateSuitableWidth;
@end

#pragma mark - NSNull
@interface NSNull (Custom)
- (NSUInteger)length;
- (NSUInteger)count;
- (NSArray *)allKeys;
- (float)floatValue;
@end
