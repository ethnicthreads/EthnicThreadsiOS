//
//  DatePickerViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 12/13/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()
@property (strong, nonatomic) IBOutlet UILabel          *lblUnit;
@property (weak, nonatomic) IBOutlet UIDatePicker       *datePicker;
@property (nonatomic, assign) IBOutlet UIView           *containView;
@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    if (self.defaultDate) {
        self.datePicker.date = self.defaultDate;
    }
    else {
        self.datePicker.date = [NSDate date];
    }
    self.datePicker.maximumDate = [NSDate date];
    self.lblUnit.text = self.unitText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSavePressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(saveDatePickerView:)]) {
        [self.delegate saveDatePickerView:self.datePicker.date];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleDatePickerValueChange:(id)sender {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.containView.frame, point)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
