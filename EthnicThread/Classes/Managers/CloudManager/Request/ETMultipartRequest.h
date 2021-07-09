//
//  ETMultipartRequest.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/24/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "Request.h"

@interface ETMultipartRequest : Request

@property (nonatomic, strong) NSArray       *multiparts;
@end
