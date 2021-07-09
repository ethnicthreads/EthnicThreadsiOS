//
//  SelectionsView.m
//  EthnicThread
//
//  Created by Duy Nguyen on 2/6/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "SelectionsView.h"
#import "TagTableViewCell.h"
#import "GenderButton.h"
#import "Constants.h"
#import "STCollapseTableView.h"
#import "TagHeaderView.h"

#define TAG_ROW_HEIGHT      40

@interface SelectionsView() <UITableViewDataSource, UITableViewDelegate, TagTableViewCellDelegate, STCollapseTableViewDelegate>
@property (nonatomic, assign) IBOutlet GenderButton         *btnWomen;
@property (nonatomic, assign) IBOutlet GenderButton         *btnMen;
@property (nonatomic, assign) IBOutlet GenderButton         *btnGirls;
@property (nonatomic, assign) IBOutlet GenderButton         *btnBoys;
@property (nonatomic, assign) IBOutlet GenderButton         *btnHome;
@property (nonatomic, assign) IBOutlet GenderButton         *btnOther;
@property (nonatomic, assign) IBOutlet UIButton             *btnForSale;
@property (nonatomic, assign) IBOutlet UIButton             *btnForRent;
@property (nonatomic, assign) IBOutlet UIButton             *btnForExchange;
@property (nonatomic, assign) IBOutlet UIButton             *btnJustFun;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightTagsTableView;
@property (nonatomic, assign) IBOutlet STCollapseTableView  *tableView;
@property (nonatomic, assign) IBOutlet UIView               *vCategoryContainer;
@property (nonatomic, assign) IBOutlet UIView               *vPurchaseContainer;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightPurchaseView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightCategoryView;
@property (nonatomic, assign) IBOutlet UIButton             *btnProduct;
@property (nonatomic, assign) IBOutlet UIButton             *btnService;
@property (nonatomic, assign) IBOutlet UIView               *vTabView;
@property (nonatomic, assign) IBOutlet UILabel              *lblNote;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcHeightTabView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint   *lcTopTableView;
@property (nonatomic, strong) NSArray                       *firstLevelMenus;
@property (nonatomic, strong) NSDictionary                  *secondLevelMenus;
@property (nonatomic, strong) NSMutableArray                *headerViews;
@property (nonatomic, assign) BOOL                          isSearchVC;
@property (nonatomic, strong) NSMutableArray                *selectedIndexPaths;
@end

@implementation SelectionsView

- (void)initVariables {
    [super initVariables];
    self.selectedGenders = [[NSMutableArray alloc] init];
    self.selectedPurchases = [[NSMutableArray alloc] init];
    self.selectedTags = [[NSMutableArray alloc] init];
    self.headerViews = [[NSMutableArray alloc] init];
    self.autoSelectedGenders = [NSMutableArray array];
    self.selectedIndexPaths = [NSMutableArray array];
}

- (void)initGUI {
    [super initGUI];
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.stDelegate = self;
    
    [self.btnWomen setTitle:GENDER_WOMEN forState:UIControlStateNormal];
    [self.btnWomen setTitle:GENDER_WOMEN forState:UIControlStateSelected];
    [self.btnMen setTitle:GENDER_MEN forState:UIControlStateNormal];
    [self.btnMen setTitle:GENDER_MEN forState:UIControlStateSelected];
    [self.btnGirls setTitle:GENDER_GIRLS forState:UIControlStateNormal];
    [self.btnGirls setTitle:GENDER_GIRLS forState:UIControlStateSelected];
    [self.btnBoys setTitle:GENDER_BOYS forState:UIControlStateNormal];
    [self.btnBoys setTitle:GENDER_BOYS forState:UIControlStateSelected];
    [self.btnHome setTitle:GENDER_HOME forState:UIControlStateNormal];
    [self.btnHome setTitle:GENDER_HOME forState:UIControlStateSelected];
    [self.btnOther setTitle:GENDER_OTHER forState:UIControlStateNormal];
    [self.btnOther setTitle:GENDER_OTHER forState:UIControlStateSelected];
    
//    self.tableView.layer.borderColor = [UIColor redColor].CGColor;
    self.vPurchaseContainer.layer.borderColor = [UIColor redColor].CGColor;
    [self.lblNote setHidden:YES];
}

- (void)configureViewForSearch {
//    [self.vPurchaseContainer removeFromSuperview];
//    [self addTopConstraintForItem:self.vCategoryContainer bottomItem:self.vTabView top:0];
    self.lcHeightPurchaseView.constant = 0;
    [self.vPurchaseContainer setClipsToBounds:YES];
    self.isSearchVC = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.btnWomen.selected = NO;
    self.btnMen.selected = NO;
    self.btnBoys.selected = NO;
    self.btnGirls.selected = NO;
    self.btnHome.selected = NO;
    self.btnOther.selected = NO;
    for (NSString *gender in self.selectedGenders) {
        if ([gender isEqualToString:self.btnWomen.titleLabel.text]) {
            self.btnWomen.selected = YES;
        }
        else if ([gender isEqualToString:self.btnMen.titleLabel.text]) {
            self.btnMen.selected = YES;
        }
        else if ([gender isEqualToString:self.btnBoys.titleLabel.text]) {
            self.btnBoys.selected = YES;
        }
        else if ([gender isEqualToString:self.btnGirls.titleLabel.text]) {
            self.btnGirls.selected = YES;
        }
        else if ([gender isEqualToString:self.btnHome.titleLabel.text]) {
            self.btnHome.selected = YES;
        }
        else if ([gender isEqualToString:self.btnOther.titleLabel.text]) {
            self.btnOther.selected = YES;
        }
    }
    
    self.btnForSale.selected = NO;
    self.btnForRent.selected = NO;
    self.btnForExchange.selected = NO;
    self.btnJustFun.selected = NO;
    for (NSString *purchase in self.selectedPurchases) {
        if ([purchase isEqualToString:PURCHASES_SALE]) {
            self.btnForSale.selected = YES;
        }
        if ([purchase isEqualToString:PURCHASES_RENT]) {
            self.btnForRent.selected = YES;
        }
        if ([purchase isEqualToString:PURCHASES_EXCHANGE]) {
            self.btnForExchange.selected = YES;
        }
        if ([purchase isEqualToString:PURCHASES_FUN]) {
            self.btnJustFun.selected = YES;
        }
    }
    
    self.btnProduct.selected = !self.isService;
    self.btnService.selected = self.isService;
    
    if (self.allowMultiSelection) {// search page is multi selection
        self.tableView.exclusiveSections = NO;
        if (self.isService) {
            [self.tableView openSection:0 animated:NO];
        }
    }
    else {// add item single selection
        [self.tableView openSection:0 animated:NO];
        self.tableView.shouldHandleHeadersTap = NO;
    }
}

- (void)updateConstraints {
    [self updateHeightOfTableView];
    CGFloat height = self.isSearchVC ? 0 : 164;
    CGFloat categoryHeight = self.isSearchVC ? 0 : 133;
    if (self.isService) {
        [self.vPurchaseContainer setHidden:YES];
        [self.vCategoryContainer setHidden:YES];
        self.lcHeightPurchaseView.constant = 0;
        self.lcHeightCategoryView.constant = 0;
    }
    else {
        [self.vPurchaseContainer setHidden:NO];
        [self.vCategoryContainer setHidden:self.isSearchVC];
        self.lcHeightPurchaseView.constant = height;
        self.lcHeightCategoryView.constant = categoryHeight;
    }
    
    if (self.isEdit) {
        self.lcHeightTabView.constant = 0;
        [self.vTabView setHidden:YES];
        self.lcHeightPurchaseView.constant = height;
        [self.vPurchaseContainer setHidden:NO];
    }
    
    [super updateConstraints];
}

- (void)reloadData {
    [self updateHeightOfTableView];
    [self setNeedsLayout];
    [self.tableView reloadData];
    if (!self.allowMultiSelection) {
        [self.tableView openSection:0 animated:NO];
    }
}

- (void)setAllTags:(NSDictionary *)allTags {
    self.secondLevelMenus = allTags;
    self.firstLevelMenus = [allTags allKeys];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.firstLevelMenus.count; i++) {
        TagHeaderView* headerView = [[[UINib nibWithNibName:NSStringFromClass([TagHeaderView class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        headerView.lblText.text = [self.firstLevelMenus objectAtIndex:i];
        [headerView setStatus:(i == 0)];
        [array addObject:headerView];
    }
    self.headerViews = array;
}

//- (void)enableTagRequiredBorder:(BOOL)enabled {
//    self.tableView.layer.borderWidth = enabled ? 1 : 0;
//}

- (void)enablePurchasesRequiredBorder:(BOOL)enabled {
    self.vPurchaseContainer.layer.borderWidth = enabled ? 1 : 0;
}

- (void)selectProducType:(BOOL)isProduct {
    if (isProduct) {
        [self handleProductButton:nil];
    } else {
        [self handleServiceButton:nil];
    }
}

- (void)updateHeightOfTableView {
    CGFloat height = self.firstLevelMenus.count * TAG_ROW_HEIGHT;
    for (NSInteger i = 0; i < self.firstLevelMenus.count; i++) {
        TagHeaderView *headerView = [self.headerViews objectAtIndex:i];
        if ([self.tableView isOpenSection:i]) {
            NSString *key = [self.firstLevelMenus objectAtIndex:i];
            NSArray *submenus = [self.secondLevelMenus objectForKey:key];
            height = height + submenus.count * TAG_ROW_HEIGHT;

            [headerView setStatus:YES];
        }
        else {
            [headerView setStatus:NO];
        }
    }
    self.lcHeightTagsTableView.constant = (height > 2) ? height - 2 : 0;
}

- (NSString *)makeTag:(NSString *)menu subMenu:(NSString *)subMenu {
//    return [NSString stringWithFormat:@"%@ > %@", menu, subMenu];
    return [subMenu capitalizedString];
}

#pragma mark - Gender
- (void)updateSelectedGenderButton:(UIButton *)button {
    NSString *gender = @"";
    if (self.btnWomen == button) gender = GENDER_WOMEN;
    if (self.btnMen == button) gender = GENDER_MEN;
    if (self.btnBoys == button) gender = GENDER_BOYS;
    if (self.btnGirls == button) gender = GENDER_GIRLS;
    if (self.btnHome == button) gender = GENDER_HOME;
    if (self.btnOther == button) gender = GENDER_OTHER;
    
    [self.selectedGenders removeAllObjects];
    if (!self.allowMultiSelection) {
        self.btnWomen.selected = NO;
        self.btnMen.selected = NO;
        self.btnBoys.selected = NO;
        self.btnGirls.selected = NO;
        self.btnHome.selected = NO;
        self.btnOther.selected = NO;
        button.selected = YES;
        [self.selectedGenders addObject:gender];
    }
    else {
        button.selected = !button.selected;
        if (self.btnWomen.selected) [self.selectedGenders addObject:GENDER_WOMEN];
        if (self.btnMen.selected) [self.selectedGenders addObject:GENDER_MEN];
        if (self.btnBoys.selected) [self.selectedGenders addObject:GENDER_BOYS];
        if (self.btnGirls.selected) [self.selectedGenders addObject:GENDER_GIRLS];
        if (self.btnHome.selected) [self.selectedGenders addObject:GENDER_HOME];
        if (self.btnOther.selected) [self.selectedGenders addObject:GENDER_OTHER];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectGender:selected:)]) {
        [self.delegate didSelectGender:gender selected:button.selected];
    }
}

- (IBAction)handleWomenButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (IBAction)handleMenButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (IBAction)handleGirlsButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (IBAction)handleBoysButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (IBAction)handleHomeButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (IBAction)handleOtherButton:(id)sender {
    [self updateSelectedGenderButton:sender];
}

- (NSArray *)getSelectedGendersFromTags {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        NSString *section = [self.firstLevelMenus objectAtIndex:indexPath.section];
        if ([section isEqualToString:@"WOMENS"]) {
            section = GENDER_WOMEN;
        } else if ([section isEqualToString:@"MENS"]){
            section = GENDER_MEN;
        }
        [dict setObject:indexPath forKey:section];
    }
    
    return [dict allKeys];
}

#pragma mark - Purchases
- (void)updatePurchases:(UIButton *)button {
    [self.selectedPurchases removeAllObjects];
    if (self.btnForSale.selected) {
        [self.selectedPurchases addObject:PURCHASES_SALE];
    }
    if (self.btnForRent.selected) {
        [self.selectedPurchases addObject:PURCHASES_RENT];
    }
    if (self.btnForExchange.selected) {
        [self.selectedPurchases addObject:PURCHASES_EXCHANGE];
    }
    if (self.btnJustFun.selected) {
        [self.selectedPurchases addObject:PURCHASES_FUN];
    }
    
    NSString *purchase = @"";
    if (self.btnForSale == button) purchase = PURCHASES_SALE;
    if (self.btnForRent == button) purchase = PURCHASES_RENT;
    if (self.btnForExchange == button) purchase = PURCHASES_EXCHANGE;
    if (self.btnJustFun == button) purchase = PURCHASES_FUN;
    if ([self.delegate respondsToSelector:@selector(didSelectPurchase:selected:)]) {
        [self.delegate didSelectPurchase:purchase selected:button.selected];
    }
}

- (IBAction)handleForSaleButton:(id)sender {
    self.btnForSale.selected = !self.btnForSale.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleForRentButton:(id)sender {
    self.btnForRent.selected = !self.btnForRent.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleForExchangeButton:(id)sender {
    self.btnForExchange.selected = !self.btnForExchange.selected;
    if (!self.allowMultiSelection) {
        if (self.btnForSale.selected || self.btnForRent.selected || self.btnForExchange.selected) {
            [self.btnJustFun setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleJustFunButton:(id)sender {
    self.btnJustFun.selected = !self.btnJustFun.selected;
    if (!self.allowMultiSelection) {
        if (self.btnJustFun.selected) {
            [self.btnForSale setSelected:NO];
            [self.btnForRent setSelected:NO];
            [self.btnForExchange setSelected:NO];
        }
    }
    [self updatePurchases:sender];
}

- (IBAction)handleProductButton:(id)sender {
    self.lcTopTableView.constant = 0;
    [self.lblNote setHidden:YES];
    if (self.isService) {
        self.isService = NO;
        if (self.allowMultiSelection) {
            for (TagHeaderView *headerView in self.headerViews) {
                [headerView setStatus:NO];
            }
            [self.tableView resetStatus];
        }
        if ([self.delegate respondsToSelector:@selector(didChangeItemType:)]) {
            [self.delegate didChangeItemType:self.isService];
        }
        [self.selectedTags removeAllObjects];
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self setNeedsLayout];
    }
}

- (IBAction)handleServiceButton:(id)sender {
    if (self.isService == NO) {
        self.isService = YES;
        if (self.allowMultiSelection) {
            [self.lblNote setHidden:YES];
            for (TagHeaderView *headerView in self.headerViews) {
                [headerView setStatus:NO];
            }
            [self.tableView resetStatus];
        }
        else {
            [self.lblNote setHidden:NO];
            self.lcTopTableView.constant = 35;
        }
        
        if ([self.delegate respondsToSelector:@selector(didChangeItemType:)]) {
            [self.delegate didChangeItemType:self.isService];
        }
        [self.selectedTags removeAllObjects];
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self setNeedsLayout];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.firstLevelMenus count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.firstLevelMenus objectAtIndex:section];
    NSArray *array = [self.secondLevelMenus objectForKey:key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tagCellIdentifier = @"TagCellIdentifier";
    TagTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tagCellIdentifier];
    if (!cell) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([TagTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    NSString *key = [self.firstLevelMenus objectAtIndex:indexPath.section];
    NSArray *array = [self.secondLevelMenus objectForKey:key];
    NSString *text = [array objectAtIndex:indexPath.row];
    cell.lblValue.text = [text capitalizedString];
    cell.btnCheck.selected = NO;
    
    // update status when user edit
//    NSString *tag = [self makeTag:key subMenu:text];
//    for (NSString *selectedTag in self.selectedTags) {
//        if ([selectedTag isEqualToString:tag]) {
//            cell.btnCheck.selected = YES;
//        }
//    }
    cell.btnCheck.selected = [self.selectedIndexPaths containsObject:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TAG_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TAG_ROW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.headerViews objectAtIndex:section];
}

#pragma mark - TagTableViewCellDelegate
- (void)updateTagStatus:(id)sender {
    TagTableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths removeObject:indexPath];
    } else {
        [self.selectedIndexPaths addObject:indexPath];
    }
    DLog(@"IndexPath:%@", self.selectedIndexPaths);
    
    NSString *key = [self.firstLevelMenus objectAtIndex:indexPath.section];
    NSArray *submenus = [self.secondLevelMenus objectForKey:key];
    NSString *tag = [self makeTag:key subMenu:[submenus objectAtIndex:indexPath.row]];
    for (NSString *selectedTag in self.selectedTags) {
        if ([selectedTag isEqualToString:tag]) {
            [self.selectedTags removeObject:selectedTag];
            break;
        }
    }
    
    if (cell.btnCheck.selected) {
        [self.selectedTags addObject:tag];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectTag:selected:)]) {
        [self.delegate didSelectTag:tag selected:cell.btnCheck.selected];
    }
}

#pragma mark - STCollapseTableViewDelegate
- (void)willOpenSection:(NSUInteger)sectionIndex {
    [self updateHeightOfTableView];
}

- (void)willCloseSection:(NSUInteger)sectionIndex {
    [self updateHeightOfTableView];
}
@end
