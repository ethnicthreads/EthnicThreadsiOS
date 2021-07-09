//
//  Categories.m
//  REP
//
//  Created by Phan Nam on 8/5/13.
//  Copyright (c) 2013 CodeBox Solutions Ltd. All rights reserved.
//

#import "Categories.h"
#import "Constants.h"
#import "Utils.h"

@implementation NSString (Custom)

static NSString *regexHtmlUnicodeInXmlInString = @"^.*&#....;";//^.*Str.*$"

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    //NSString *charstoescaped = @"!*'\"();:@&=+$,/?%#[]%<> ";
    CFStringRef strRef = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, /*( CFStringRef)charstoescaped*/NULL, CFStringConvertNSStringEncodingToEncoding(encoding));
    return (NSString *)CFBridgingRelease(strRef);
}

- (NSString *)urlDecodcodeUsingEncoding:(NSStringEncoding)decoding {
    CFStringRef strRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(decoding));
    return (NSString *)CFBridgingRelease(strRef);
}

- (NSString*)sha256WithKey:(NSString*)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];
    
    // description converts to hex but puts <> around it and spaces every 4 bytes
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    // hash is now a string with just the 40char hash value in it
    
    return hash;
}

- (NSString*)md5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (NSString *)AES256EncryptWithKey:(NSString *)key initVector:(NSData*)initVector {
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key initVector:initVector];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES256DecryptWithKey:(NSString *)key initVector:(NSData*)initVector {
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES256DecryptWithKey:key initVector:initVector];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    return plainString;
}

- (NSString *)stringByDecodingXMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
	
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
			
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber) {
                [result appendFormat:@"%u", charCode];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToString:@";" intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                DLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
            [scanner scanString:@";" intoString:NULL];
        }
        else {
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            DLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
        }
    }
    while (![scanner isAtEnd]);
	
finish:
    return result;
}

- (NSString *)trimText {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)resolveUnicodeString {
    static NSRegularExpression *regexHtmlUnicodeInXml = nil;
	if (regexHtmlUnicodeInXml == nil) {
        regexHtmlUnicodeInXml = [[NSRegularExpression alloc] initWithPattern:regexHtmlUnicodeInXmlInString options:0 error:nil];
	}
    NSString *text = self;
	@try {
		while (text != nil) {
            NSTextCheckingResult *matcher = [regexHtmlUnicodeInXml firstMatchInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, [text length])];
            if (!matcher) {
                break;
            }
			//Get range of &#
			NSString *orinalHtmlcode;
			NSString *unicodeStr;
			NSRange firstrange = [text rangeOfString:@"&#"];//Ch&#7901;
			firstrange.length = [text length] - firstrange.location;
			NSRange secondrange = [text rangeOfString:@";" options:NSCaseInsensitiveSearch range:firstrange];
			firstrange.length = secondrange.location + 1 - firstrange.location;
			
			//get original unicode str
			orinalHtmlcode = [text substringWithRange:firstrange];
			//remove &# and ;
			firstrange.location = 2;
			firstrange.length = firstrange.length - 3;
			
			//get unicode token
			unicodeStr = [orinalHtmlcode substringWithRange:firstrange];
			unicodeStr = [NSString stringWithFormat:@"%X", [unicodeStr intValue]];
			unichar codeValue = (unichar) strtol([unicodeStr UTF8String], NULL, 16);
			unicodeStr = [NSString stringWithFormat:@"%C", codeValue];
			text = [text stringByReplacingOccurrencesOfString:orinalHtmlcode withString:unicodeStr];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"Utility - resolveUnicodeString throw exception: %@  %@", [exception name], [exception reason]);
	}
	@finally {
		return text;
	}
}

- (BOOL)containString:(NSString *)str {
	if (str == nil) return FALSE;
	NSRange pos = [self rangeOfString:str];
	if (pos.location != NSNotFound && pos.length > 0)
		return TRUE;
	return FALSE;
}

- (NSString *)makeJsonEscapeCharacter {
    if (self == nil || self.length == 0) {
        return @"";
    }
    
    char         c = 0;
    NSInteger          i;
    NSInteger          len = self.length;
    NSMutableString *result = [NSMutableString string];
    
    for (i = 0; i < len; i++) {
        c = [self characterAtIndex:i];
        switch (c) {
            case '\\':
            case '"':
            case '/':
                [result appendFormat:@"\\%c", c];
                break;
            case '\b':
                [result appendString:@"\\b"];
                break;
            case '\t':
                [result appendString:@"\\t"];
                break;
            case '\n':
                [result appendString:@"\\n"];
                break;
            case '\f':
                [result appendString:@"\\f"];
                break;
            case '\r':
                [result appendString:@"\\r"];
                break;
            default:
                if (c < ' ') {
                    [result appendFormat:@"\\u00%2x", c];
                } else {
                    [result appendFormat:@"%c", c];
                }
                break;
        }
    }
    return result;
}

- (NSDate *)convertToDateWithFormat:(NSString *)formatString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    return [dateFormat dateFromString:self];
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (self.length == 0)
    return CGSizeZero;
    
    CGRect rect = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font} context:nil];
    
    return rect.size;
}

- (CGSize)sizeWithFont:(UIFont *)font {
    return [self sizeWithAttributes:@{NSFontAttributeName : font}];
}
@end

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
};

@implementation NSData (Custom)

- (NSData *)AES256EncryptWithKey:(NSString *)key initVector:(NSData*)initVector {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof( keyPtr ) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          [initVector bytes] /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted );
    if( cryptStatus == kCCSuccess )
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free( buffer ); //free the buffer
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key initVector:(NSData*)initVector {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof( keyPtr ) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          [initVector bytes] /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted );
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer
    return nil;
}

#pragma mark -

+ (NSData *)dataWithBase64EncodedString:(NSString *)string {
    return [[NSData allocWithZone:nil] initWithBase64EncodedString:string];
}

- (id)initWithBase64EncodedString:(NSString *)string {
    NSMutableData *mutableData = nil;
    
    if (string) {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4], outbuf[3];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64Bytes = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = [base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:base64Data.length];
        lentext = base64Data.length;
        
        memset(inbuf, 0, 4);
        memset(outbuf, 0, 3);
        while( YES )
        {
            if( ixtext >= lentext ) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
            else if( ch == '+' ) ch = 62;
            else if( ch == '=' ) flendtext = YES;
            else if( ch == '/' ) ch = 63;
            else flignore = YES;
            
            if( ! flignore )
            {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if( flendtext )
                {
                    if( ! ixinbuf ) break;
                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if( ixinbuf == 4 )
                {
                    ixinbuf = 0;
                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
                    for( i = 0; i < ctcharsinbuf; i++ )
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if( flbreak )  break;
            }
        }
    }
    
    self = [self initWithData:mutableData];
    return self;
}

#pragma mark -

- (NSString *)base64Encoding {
    return [self base64EncodingWithLineLength:0];
}

- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength {
    const unsigned char   *bytes = [self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:self.length];
    unsigned long ixtext = 0;
    unsigned long lentext = self.length;
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    unsigned short i = 0;
    unsigned short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
    while( YES )
    {
        ctremaining = lentext - ixtext;
        if( ctremaining <= 0 ) break;
        
        for( i = 0; i < 3; i++ )
        {
            ix = ixtext + i;
            if( ix < lentext ) inbuf[i] = bytes[ix];
            else inbuf [i] = 0;
        }
        
        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;
        
        switch( ctremaining )
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for( i = ctcopy; i < 4; i++ )
            [result appendString:@"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if( lineLength > 0 )
        {
            if( charsonline >= lineLength )
            {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return [NSString stringWithString:result];
}

#pragma mark -

- (BOOL)hasPrefixBytes:(const void *)prefix length:(NSUInteger)length
{
    if( ! prefix || ! length || self.length < length ) return NO;
    return ( memcmp( [self bytes], prefix, length ) == 0 );
}

- (BOOL)hasSuffixBytes:(const void *)suffix length:(NSUInteger)length
{
    if( ! suffix || ! length || self.length < length ) return NO;
    return ( memcmp( ((const char *)[self bytes] + (self.length - length)), suffix, length ) == 0 );
}


@end

#pragma mark - UIImage category
@implementation UIImage (Custom)
- (UIImage *)scaleByWidth:(CGFloat)width {
    CGFloat height = (self.size.height * width) / self.size.width;
    CGSize size = CGSizeMake(width, height);
    return [self scaleToSize:size];
}

- (UIImage *)scaleToSize:(CGSize)size {
    if (self.size.width <= size.width && self.size.height <= size.height) {
        return self;
    }
//    CGFloat scale = [[UIScreen mainScreen] scale];    
//    if (scale > 1.0 && (size.width * scale <= self.size.width) && (size.height * scale <= self.size.height)) {
//        size = CGSizeMake(size.width * scale, size.height * scale);
//    }
    
    float dw = size.width / self.size.width;
    float dh = size.height / self.size.height;
    
    float ratio = MIN(dw, dh);
    CGRect rect = CGRectMake(0, 0, ratio * self.size.width, ratio * self.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)crop:(CGRect)rect {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect drawnRect = CGRectMake(-rect.origin.x * scale, -rect.origin.y * scale, self.size.width * scale, self.size.height * scale);
    CGSize cropSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
    UIGraphicsBeginImageContextWithOptions(cropSize, NO, self.scale);
    
    [self drawInRect:drawnRect];
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)cropCenterToSize:(CGSize)size {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect newRect;
    
    if (scale > 1.0 && (size.width * scale <= self.size.width) && (size.height * scale <= self.size.height)) {
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    
    //scale first
    float dw = size.width / self.size.width;
    float dh = size.height / self.size.height;
    float ratio = MAX(dw, dh);
    float newWidth = ratio * self.size.width;
    float newHeight = ratio * self.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imgRef = [newImage CGImage];
    
    newRect = CGRectMake((newWidth - size.width) / 2, (newHeight - size.height) / 2, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(imgRef, newRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)cropCenterToSize:(CGSize)size shouldScale:(BOOL)shouldScale {
    if (shouldScale) {
        return [self cropCenterToSize:size];
    }
    
    CGRect newRect;
    //scale first
    float dw = size.width / self.size.width;
    float dh = size.height / self.size.height;
    float ratio = MAX(dw, dh);
    float newWidth = ratio * self.size.width;
    float newHeight = ratio * self.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imgRef = [newImage CGImage];
    
    newRect = CGRectMake((newWidth - size.width) / 2, (newHeight - size.height) / 2, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(imgRef, newRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

CGContextRef newBitmapContextSuitableForSize(CGSize size) {
	int pixelsWide = size.width;
	int pixelsHigh = size.height;
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    // void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4); //4
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    /* bitmapData = malloc( bitmapByteCount );
     
     memset(bitmapData, 0, bitmapByteCount);  // set memory to black, alpha 0
     
     if (bitmapData == NULL)
     {
     return NULL;
     }
     */
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate ( NULL, // instead of bitmapData
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGBitmapAlphaInfoMask);
	CGColorSpaceRelease( colorSpace );
    
    if (context== NULL)
    {
        // free (bitmapData);
        return NULL;
    }
    
    return context;
}

- (UIImage *)imageByDrawingCircle {
    UIImage *image = self;
	// begin a graphics context of sufficient size
	CGContextRef ctx = newBitmapContextSuitableForSize(image.size);
    
	// need to flip the transform matrix
	// CoreGraphics has (0,0) in lower left
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -image.size.height);
    
	// draw original image into the context
	CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
	CGContextDrawImage(ctx, imageRect, image.CGImage);
    
	// set stroking color and draw circle
	CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
    
	// make circle rect 5 px from border
	CGRect circleRect = CGRectMake(0, 0,
                                   image.size.width,
                                   image.size.height);
	circleRect = CGRectInset(circleRect, 5, 5);
    
	// draw circle
	CGContextStrokeEllipseInRect(ctx, circleRect);
    
	// make image out of bitmap context
	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
	UIImage *retImage = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
    
	// free the context
	CGContextRelease(ctx);
    
	return retImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

- (UIImage *)convertToGrayscale {
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}
@end

#pragma mark - NSDate category
@implementation NSDate (Custom)
- (NSDate *)convertToUTCDate {
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger seconds = [tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

- (NSDate *)toLocalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSString *)convertToStringWithFormat:(NSString *)formatString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    NSString *dateString = [dateFormat stringFromDate:self];
    return dateString;
}
@end

#pragma mark - UIView category
@implementation UIView (Custom)
- (CGFloat)getYAxisAtBottomView {
    return self.frame.origin.y + self.frame.size.height;
}

- (UIImage *)convertToImage {
	return [self convertToImage:self.opaque];
}

- (UIImage *)convertToImage:(BOOL)opaque {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, opaque, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return img;
}
@end

#pragma mark - UILabel category
@implementation UILabel (Custom)
- (CGFloat)calculateSuitableHeight {
    CGSize suggestedSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 10000) lineBreakMode:self.lineBreakMode];
	return suggestedSize.height;
}

- (CGFloat)calculateSuitableWidth {
    CGSize suggestedSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(10000, self.frame.size.height) lineBreakMode:self.lineBreakMode];
	return suggestedSize.width;
}
@end

#pragma mark - NSNull
@implementation NSNull (Custom)

- (NSString *)description {
    return @"";
}

- (NSUInteger)length {
    return 0;
}

- (NSUInteger)count {
    return 0;
}

- (NSArray *)allKeys {
    return nil;
}

- (float)floatValue {
    return 0;
}
@end
