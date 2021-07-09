//
//  StreamingMultipartFormData.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/24/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultipartFormData.h"
#import "MultipartBodyStream.h"

@interface StreamingMultipartFormData : NSObject <MultipartFormData>

- (id)initWithURLRequest:(NSMutableURLRequest *)urlRequest
          stringEncoding:(NSStringEncoding)encoding;
- (NSMutableURLRequest *)requestByFinalizingMultipartFormData;
@end
