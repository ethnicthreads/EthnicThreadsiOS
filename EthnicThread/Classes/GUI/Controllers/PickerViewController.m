//
//  PickerViewController.m
//  EthnicThread
//
//  Created by Katori on 12/10/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController () {
    NSInteger selectedRow;
}
@property (weak, nonatomic) IBOutlet UIPickerView       *pickerView;
@property (nonatomic, assign) IBOutlet UIView           *containView;
@end

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)initComponentUI {
    [super initComponentUI];
    self.lblUnit.text = self.unit;
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelectedIndex:(NSInteger)index {
    if ([self.pickerArray count] > 0 && index < [self.pickerArray count]) {
        selectedRow = index;
    }
}

#pragma mark - Picker View Data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([self.pickerArray count] > 0) {
        return [self.pickerArray count];
    }
    return 0;
}

#pragma mark- Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedRow = row;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.pickerArray count] > 0) {
        return [self.pickerArray objectAtIndex:row];
    }
    return nil;
}

- (IBAction)handleCancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleSavePressed:(id)sender {
    if ([self.pickerDelegate respondsToSelector:@selector(selectedPickerAtIndex:hasValue:)]) {
        if ([self.pickerArray count] > 0) {
            [self.pickerDelegate selectedPickerAtIndex:selectedRow hasValue:[self.pickerArray objectAtIndex:selectedRow]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.containView.frame, point)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
