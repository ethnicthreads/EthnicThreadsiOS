//
//  DatePickerViewController.h
//  EthnicThread
//
//  Created by Duy Nguyen on 12/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseViewController.h"

@protocol DatePickerViewControllerDelegate <NSObject>
- (void)saveDatePickerView:(NSDate *)date;
@end

@interface DatePickerViewController : BaseViewController
@property (assign, nonatomic) id <DatePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate                    *defaultDate;
@property (nonatomic, strong) NSString                  *unitText;
@end
