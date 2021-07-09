//
//  Utils.m
//  HeyDenmark
//
//  Created by Phan Nam on 11/28/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+ (NSDateFormatter *)ISO8601_DATE_FORMAT {
    static NSDateFormatter *ISO8601_DATE_FORMAT = nil;
    if (ISO8601_DATE_FORMAT == nil) {
        ISO8601_DATE_FORMAT = [[NSDateFormatter alloc] init];
        [ISO8601_DATE_FORMAT setDateFormat:@"yyyy-MM-dd"];
        NSTimeZone *UTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [ISO8601_DATE_FORMAT setTimeZone:UTC];
    }
    return ISO8601_DATE_FORMAT;
}

+ (NSString *)getValueNotNil:(NSDictionary *)dict key:(NSString *)key {
    return ([dict objectForKey:key] == nil) ? @"" : [dict objectForKey:key];
}

+ (CGFloat)calculateHeightOfText:(NSString*)aText font:(UIFont*)aFont constrainedSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize suggestedSize = [aText sizeWithFont:aFont constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
	return suggestedSize.height;
}


+ (CGFloat)calculateWidthOfText:(NSString*)aText font:(UIFont*)aFont constrainedSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize suggestedSize = [aText sizeWithFont:aFont constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
    return suggestedSize.width;
}

/*
+ (NSString *)getMacAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        if (msgBuffer != NULL) {
            free(msgBuffer);
        }
        return errorFlag;
    }
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    //NSLog(@"Mac Address: %@", macAddressString);
    // Release the buffer memory
    free(msgBuffer);
    return [macAddressString md5];
}
 */

+ (void)showAlertNoInteractiveWithTitle:(NSString *)title message:(NSString *)message {
    if ([NSThread isMainThread]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [Utils showAlertNoInteractiveWithTitle:title message:message];
    });
}

+ (CGFloat)calculateHeightForNumberOfLine:(NSInteger)lineNum width:(CGFloat)width font:(UIFont *)font {
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    NSString *str = @"";
    for (NSInteger i = 0; i < lineNum; i++) {
        str = [str stringByAppendingString:@"Aa"];
        if (i < lineNum - 1) {
            str = [str stringByAppendingString:@"\n"];
        }
    }
    CGSize theSize = [str sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return theSize.height;
}

+ (CGFloat)calculateWidthForString:(NSString *)str withHeight:(CGFloat)height andFont:(UIFont *)font {
    CGSize constraintSize = CGSizeMake(MAXFLOAT, height);
//    CGSize theSize = [str sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect theRect = [str boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return theRect.size.width;
}

+ (CGFloat)calculateHeightForString:(NSString *)str withWidth:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize theSize = [str sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return theSize.height;
}

// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	NSInteger i;
	for (i=0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
		output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSString *)predefineStringInXML:(NSString *)aRoughString {
    if (!aRoughString) return @"";
    
    NSString *retVal = aRoughString;
    retVal = [retVal stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    retVal = [retVal stringByReplacingOccurrencesOfString:@"\'" withString:@"&apos;"];
	return retVal;
}

+ (NSString *)makeCleanXMLString:(NSString *)aRoughString {
	NSString *retVal = aRoughString;
	if (retVal)
	{
		retVal = [retVal stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		retVal = [retVal stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		retVal = [retVal stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
		retVal = [retVal stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
		retVal = [retVal stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	}
	return retVal;
}

+ (NSString *)convertWeekDay:(NSInteger)weekday {
    NSString *result = nil;
    switch (weekday) {
        case 1:
            result = @"sunday";
            break;
        case 2:
            result = @"monday";
            break;
        case 3:
            result = @"tuesday";
            break;
        case 4:
            result = @"wednesday";
            break;
        case 5:
            result = @"thursday";
            break;
        case 6:
            result = @"friday";
            break;
        case 7:
            result = @"saturday";
            break;
        default:
            break;
    }
    return result;
}

+ (NSString *)truncatedStringFrom:(NSString *)string toFit:(UIFont *)font atPixel:(CGFloat)pixel {
    NSString *firstComponent = string;
    CGSize size = [firstComponent sizeWithFont:font];
    NSString *truncatedFirstComponent = firstComponent;
    NSString *str = @"";
    
    while (firstComponent.length > 0 && !(size.width <= pixel && [str isEqualToString:@" "])) {
        str = [firstComponent substringFromIndex:[firstComponent length] - 1];
        firstComponent = [firstComponent substringToIndex:[firstComponent length] - 1];
        truncatedFirstComponent = [firstComponent stringByAppendingString:@"..."];
        size = [truncatedFirstComponent sizeWithFont:font];
    }
    return truncatedFirstComponent;
}

+ (NSString *)getCachedFonderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"Cached"];
    [Utils createFolderPathIfNotExist:folderPath];
    return folderPath;
}

+ (void)createFolderPathIfNotExist:(NSString *)aFolderPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:aFolderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:aFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (NSString *)checkNil:(id)obj {
    return [Utils checkNil:obj defaultValue:@""];
}

+ (void)addFitConstraintToView:(UIView *)parent subView:(UIView *)subview {
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *lc = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [parent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [parent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [parent addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [parent addConstraint:lc];
}

+ (NSString *)checkNil:(id)obj defaultValue:(id)defaultValue {
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) return [defaultValue description];
    return [obj description];
}

+ (id)checkNull:(id)obj {
    return [obj isKindOfClass:[NSNull class]] ? nil : obj;
}

+ (NSLayoutConstraint *)constraintWithItem:(UIView *)item1 item2:(UIView *)item2 attribute:(NSLayoutAttribute)aLayoutAttribute constant:(CGFloat)aConstant {
    return [Utils constraintWithItem:item1 item2:item2 attribute:aLayoutAttribute multiplier:1 constant:aConstant];
}

//item1.attr = item2.attr * multiplier + constant
+ (NSLayoutConstraint *)constraintWithItem:(UIView *)item1 item2:(UIView *)item2 attribute:(NSLayoutAttribute)aLayoutAttribute multiplier:(CGFloat)aMultiplier constant:(CGFloat)aConstant {
    return [NSLayoutConstraint constraintWithItem:item1 attribute:aLayoutAttribute relatedBy:NSLayoutRelationEqual toItem:item2 attribute:aLayoutAttribute multiplier:aMultiplier constant:aConstant];
}

+ (NSString *)generateLocationStringFrom:(NSString *)anAddress city:(NSString *)aCity state:(NSString *)aState country:(NSString *)aCountry {
    NSMutableString *location = [[NSMutableString alloc] init];
    if (anAddress.length > 0)
        [location appendString:anAddress];
    if (aCity.length > 0)
        [location appendFormat:@", %@", aCity];
    if (aState.length > 0)
        [location appendFormat:@", %@", aState];
    if (aCountry.length > 0)
        [location appendFormat:@", %@", aCountry];
    return [location stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
}

+ (NSString *)convertEmojiToUnicode:(NSString *)emojiText {
    NSData *data = [emojiText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (BOOL)isNilOrNull:(id)obj {
    return (obj == nil || [obj isKindOfClass:[NSNull class]]);
}

+ (NSDictionary *)getDictionaryFromObject:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSString class]]) {
        NSError *error = nil;

        NSDictionary *jsonTarget = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (!error) {
            return jsonTarget;
        }
    }
    return nil;
}

+ (NSString *)convertUnicodeToEmoji:(NSString *)unicodeText {
    if ([unicodeText containsString:@"\\n"]) {
        unicodeText = [unicodeText stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    if ([unicodeText containsString:@"\\\""]) {
        unicodeText = [unicodeText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    }
    NSData *data = [unicodeText dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
}

+ (BOOL)checkEmojiLanguage:(NSString *)primaryLanguage {
    if (!primaryLanguage || [primaryLanguage isEqualToString:@"emoji"]) {
        return YES;
    }
    return NO;
}
@end
