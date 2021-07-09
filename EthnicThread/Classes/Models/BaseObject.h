//
//  BaseObject.h
//  HeyDenmark
//
//  Created by Phan Nam on 12/31/13.
//  Copyright (c) 2013 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utils.h"

@interface BaseObject : NSObject
- (id)initWithDictionary:(NSDictionary *)dict;
- (void)updateWithDictionary:(NSDictionary *)dict;
- (NSMutableDictionary*)toDictionary;
- (void)setValue:(id)value forKey:(NSString *)key;
@end
