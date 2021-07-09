//
//  ETUtils.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/24/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kMultipartFormCRLF = @"\r\n";
static NSString * const kCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
extern NSString * CreateMultipartFormBoundary();
extern NSString * MultipartFormInitialBoundary(NSString *boundary);
extern NSString * MultipartFormEncapsulationBoundary(NSString *boundary);
extern NSString * MultipartFormFinalBoundary(NSString *boundary);
extern NSString * ContentTypeForPathExtension(NSString *extension);
NSArray * QueryStringPairsFromKeyAndValue(NSString *key, id value);
NSArray * QueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSString * Base64EncodedStringFromString(NSString *string);

extern NSString * PercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding);
extern NSString * PercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding);

#pragma mark -
typedef enum {
    EncapsulationBoundaryPhase = 1,
    HeaderPhase                = 2,
    BodyPhase                  = 3,
    FinalBoundaryPhase         = 4,
} HTTPBodyPartReadPhase;
