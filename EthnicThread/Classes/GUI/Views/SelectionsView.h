//
//  SelectionsView.h
//  EthnicThread
//
//  Created by Duy Nguyen on 2/6/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "BaseView.h"

@protocol SelectionsViewDelegate <NSObject>
- (void)didChangeItemType:(BOOL)isService;
@optional
- (void)didSelectGender:(NSString *)gender selected:(BOOL)selected;
- (void)didSelectPurchase:(NSString *)purchase selected:(BOOL)selected;
- (void)didSelectTag:(NSString *)tag selected:(BOOL)selected;
@end

@interface SelectionsView : BaseView
@property (nonatomic, strong) NSMutableArray        *selectedGenders;
@property (nonatomic, strong) NSMutableArray        *selectedPurchases;
@property (nonatomic, strong) NSMutableArray        *autoSelectedGenders;
@property (nonatomic, strong) NSMutableArray        *selectedTags;
@property (nonatomic, assign) BOOL                  allowMultiSelection;
@property (nonatomic, assign) id <SelectionsViewDelegate>   delegate;
@property (nonatomic, assign) BOOL                  isService;
@property (nonatomic, assign) BOOL                  isEdit;

- (void)reloadData;
- (void)setAllTags:(NSDictionary *)allTags;
//- (void)enableTagRequiredBorder:(BOOL)enabled;
- (void)enablePurchasesRequiredBorder:(BOOL)enabled;
- (void)selectProducType:(BOOL)isProduct;
- (void)configureViewForSearch;
- (NSArray *)getSelectedGendersFromTags;
@end
