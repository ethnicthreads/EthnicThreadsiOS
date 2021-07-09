//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;
@protocol TPKeyboardProtocol <NSObject>
@optional
- (void)tpKeyboardDidFinishEditing:(id)editingField;
- (void)tpKeyboardDidTouchOnView:(id)aView;
@end

@interface TPKeyboardAvoidingScrollView : UIScrollView
@property (nonatomic, assign) id<TPKeyboardProtocol> tpDelegate;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
- (CGRect)getKeyboardRect;
@end
