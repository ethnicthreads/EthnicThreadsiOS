//
//  MultipartFileURL.h
//  EthnicThread
//
//  Created by Nam Phan on 9/25/14.
//  Copyright (c) 2014 Codebox Solutions Ltd. All rights reserved.
//

#import "Multipart.h"

@interface MultipartFileURL : Multipart
@property (nonatomic, strong) NSURL     *fileURL;
@property (nonatomic, strong) NSString  *fileName;
@end
