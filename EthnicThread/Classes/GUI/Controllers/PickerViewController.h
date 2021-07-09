//
//  PickerViewController.h
//  EthnicThread
//
//  Created by Katori on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol PickerViewControllerDelegate <NSObject>
- (void)selectedPickerAtIndex:(NSInteger)index hasValue:(id)value;
@end

@interface PickerViewController : BaseViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel      *lblUnit;
@property (strong, nonatomic) NSArray               *pickerArray;
@property (strong, nonatomic) NSString              *unit;
@property (weak, nonatomic) id<PickerViewControllerDelegate>      pickerDelegate;

- (void)setSelectedIndex:(NSInteger)index;
@end
