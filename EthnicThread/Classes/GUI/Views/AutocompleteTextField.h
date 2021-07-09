//
//  AutocompleteTextField.h
//  EthnicThread
//
//  Created by Duy Nguyen on 11/23/14.
//  Copyright (c) 2014 CodeBox Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  AutocompleteTextField;

@protocol AutocompleteDataSource <NSObject>

- (NSArray *)resourceForTextField:(AutocompleteTextField*)textField;

@end

@protocol AutocompleteTextFieldDelegate <NSObject>

@optional
- (void)autoCompleteTextFieldDidAutoComplete:(AutocompleteTextField *)autoCompleteField;
- (void)autocompleteTextField:(AutocompleteTextField *)autocompleteTextField didChangeAutocompleteText:(NSString *)autocompleteText;

@end

@interface AutocompleteTextField : UITextField
/*
 * Designated programmatic initializer (also compatible with Interface Builder)
 */
- (id)initWithFrame:(CGRect)frame;

/*
 * Autocomplete behavior
 */
@property (nonatomic, assign) NSUInteger autocompleteType; // Can be used by the dataSource to provide different types of autocomplete behavior
@property (nonatomic, assign) BOOL autocompleteDisabled;
@property (nonatomic, assign) BOOL showAutocompleteButton;
@property (nonatomic, assign) id<AutocompleteTextFieldDelegate> autoCompleteTextFieldDelegate;

/*
 * Configure text field appearance
 */
@property (nonatomic, strong) UILabel *autocompleteLabel;
- (void)setFont:(UIFont *)font;
@property (nonatomic, assign) CGPoint autocompleteTextOffset;

/*
 * Specify a data source responsible for determining autocomplete text.
 */
@property (nonatomic, assign) IBOutlet id<AutocompleteDataSource> autocompleteDataSource;

/*
 * Subclassing:
 */
- (CGRect)autocompleteRectForBounds:(CGRect)bounds; // Override to alter the position of the autocomplete text
- (void)setupAutocompleteTextField; // Override to perform setup tasks.  Don't forget to call super.

/*
 * Refresh the autocomplete text manually (useful if you want the text to change while the user isn't editing the text)
 */
- (void)forceRefreshAutocompleteText;
@end
