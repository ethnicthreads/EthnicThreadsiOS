//
//  ARequitedItemListingView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/16/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "ARequitedItemListingView.h"
#import "Constants.h"
#import "GenderButton.h"
#import "SelectionsView.h"

@interface ARequitedItemListingView() <UITextViewDelegate, UIActionSheetDelegate, SelectionsViewDelegate>
@property (nonatomic, assign) IBOutlet UIView               *vSelection;
@property (nonatomic, assign) IBOutlet UIView               *vGallery;
@property (nonatomic, assign) IBOutlet UIButton             *btnNoImage;
@property (nonatomic, assign) IBOutlet UIView               *vTakePucture;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lcHeightTfTitle;
@end

@implementation ARequitedItemListingView

- (void)initGUI {
    [super initGUI];
    [self setBackgroundColor:LIGHT_GRAY_COLOR];
    self.tfTitle.delegate = self;
    self.tfTitle.placeholder = NSLocalizedString(@"text_what_are_you_post", @"");
    [self visibleNoImageButton:YES];
    
    self.vTakePucture.layer.cornerRadius = 3;
    
    self.selectionView = [[[UINib nibWithNibName:NSStringFromClass([SelectionsView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.selectionView.delegate = self;
    self.selectionView.allowMultiSelection = NO;
    [self.selectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vSelection addSubview:self.selectionView];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.selectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.vSelection attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.vSelection addConstraint:lc];
    
    self.tfTitle.layer.borderColor = [UIColor redColor].CGColor;
    self.btnNoImage.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tfTitle.text = self.createdItem.name;
    [self visibleNoImageButton:self.createdItem.images.count == 0];
    [self shouldEnableRequired];
}

- (void)setCreatedItem:(CreativeItemModel *)createdItem {
    _createdItem = createdItem;
    self.selectionView.selectedGenders = [NSMutableArray arrayWithArray:@[self.createdItem.gender]];
    self.selectionView.selectedPurchases = [self.createdItem getPurchases];
    self.selectionView.selectedTags = self.createdItem.tags;
    self.selectionView.isService = self.createdItem.isService;
    self.selectionView.isEdit = self.createdItem.isEdit;
    [self.selectionView reloadData];
    
    self.scvImages.allowRemove = YES;
    [self.scvImages setImages:self.createdItem.images andSize:GALLERY_SCROLLVIEW_SIZE];
}

- (void)setValueTags:(NSDictionary *)valueTags {
    _valueTags = valueTags;
    [self reloadTags];
}

- (void)visibleNoImageButton:(BOOL)enable {
    [self.btnNoImage setHidden:!enable];
    if (enable) {
        [self.vGallery bringSubviewToFront:self.btnNoImage];
    }
    [self.vGallery bringSubviewToFront:self.vTakePucture];
}

- (void)shouldEnableRequired {
    if (self.allowEnableRequired == NO) return;
    
    self.tfTitle.layer.borderWidth = 0;
    self.btnNoImage.layer.borderWidth = 0;
    
    if (self.createdItem.name.length == 0 && ![self.createdItem isForFun]) {
        self.tfTitle.layer.borderWidth = 1;
    }
    if (self.createdItem.images.count == 0) {
        self.btnNoImage.layer.borderWidth = 1;
    }
    //    [self.selectionView enableTagRequiredBorder:(self.createdItem.tags.count == 0)];
    [self.selectionView enablePurchasesRequiredBorder:([self.createdItem getPurchases].count == 0)];
}

- (IBAction)handleChoosePhotoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(choosePhotosInCameraRoll)]) {
        [self.delegate choosePhotosInCameraRoll];
    }
}

- (IBAction)handleTakePhotoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
        [self.delegate takePhoto];
    }
}

- (IBAction)handlNoImageButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_button_cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"take_photo", @""), NSLocalizedString(@"choose_from_photo_library", @""), nil];
    [sheet showInView:self];
}

#pragma mark - SelectionsViewDelegate
- (void)didSelectGender:(NSString *)gender selected:(BOOL)selected {
    self.createdItem.gender = gender;
    [self.createdItem.tags removeAllObjects];
    [self reloadTags];
    [self shouldEnableRequired];
}

- (void)didSelectPurchase:(NSString *)purchase selected:(BOOL)selected {
    [self.createdItem updatePurchases:self.selectionView.selectedPurchases];
    self.selectionView.selectedGenders = [NSMutableArray arrayWithArray:@[self.createdItem.gender]];
    [self reloadTags];
    [self shouldEnableRequired];
    if ([self.delegate respondsToSelector:@selector(didSelectPurchase:)]) {
        [self.delegate didSelectPurchase:purchase];
    }
}

- (void)didSelectTag:(NSString *)tag selected:(BOOL)selected {
    self.createdItem.tags = self.selectionView.selectedTags;
    [self shouldEnableRequired];
}

- (void)didChangeItemType:(BOOL)isService {
    [self.createdItem setIsService:isService];
    self.selectionView.selectedGenders = [NSMutableArray arrayWithArray:@[self.createdItem.gender]];
    [self.createdItem.tags removeAllObjects];
    self.valueTags = [[AppManager sharedInstance] getTags:self.createdItem.isService];
    [self reloadTags];
    [self shouldEnableRequired];
    if ([self.delegate respondsToSelector:@selector(didSelectPurchase:)]) {
        [self.delegate didSelectPurchase:[[self.createdItem getPurchases] firstObject]];
    }
}

#pragma mark - Public Methods
- (void)addImage:(UIImage *)image animate:(BOOL)animated {
    [self.createdItem.images addObject:image];
    [self.scvImages addImage:image animate:animated];
    [self visibleNoImageButton:self.createdItem.images.count == 0];
    [self shouldEnableRequired];
}

- (void)reloadTags {
    [self.selectionView setAllTags:[NSDictionary dictionary]];
    for (NSString *key in [self.valueTags allKeys]) {
        if ([[key lowercaseString] hasPrefix:[self.createdItem.gender lowercaseString]]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[self.valueTags objectForKey:key] forKey:key];
            [self.selectionView setAllTags:dict];
            break;
        }
    }
    [self.selectionView reloadData];
}

- (void)removeImageAtIndex:(NSInteger)index {
    if (index < self.createdItem.images.count) {
        [self.createdItem.images removeObjectAtIndex:index];
    }
    [self visibleNoImageButton:self.createdItem.images.count == 0];
    [self shouldEnableRequired];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.createdItem.name = textView.text;
    self.lcHeightTfTitle.constant = MAX(textView.contentSize.height, 30);
    [self shouldEnableRequired];
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.tfTitle) {
//        [self.tfTitle resignFirstResponder];
//    }
//    return YES;
//}
//  //- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
////    if ([Utils checkEmojiLanguage:[[textField textInputMode] primaryLanguage]]) {
////        return NO;
////    }
//    
//    if (textField == self.tfTitle) {
//        NSMutableString *name = [NSMutableString stringWithString:self.tfTitle.text];
//        [name replaceCharactersInRange:range withString:string];
//        self.createdItem.name = name;
//    }
//    [self shouldEnableRequired];
//    return YES;
//}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([self.delegate respondsToSelector:@selector(takePhoto)]) {
            [self.delegate takePhoto];
        }
    }
    else if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(choosePhotosInCameraRoll)]) {
            [self.delegate choosePhotosInCameraRoll];
        }
    }
}
@end
