//
//  DownloadProtocol.h
//  Saleshood
//
//  Created by Phan Nam on 9/27/13.
//  Copyright (c) 2013 Codebox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol DownloadProtocol <NSObject>
@optional
- (void)didFinishDownloadingPhotoForItem:(id)photoItem;
- (void)didFinishDownloadingImage:(UIImage *)downloadedImage url:(NSString *)downloadedUrl processImageType:(PROCESSIMAGE)processType;
- (void)didHaveErrorWhileDownloadPhotoAtUrl:(NSString *)downloadedUrl;
@end
