//
//  EditItemDelegate.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/18/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EditItemDelegate <NSObject>
- (void)editRequitedFields;
- (void)editOptionalFields;
@end
