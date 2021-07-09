//
//  HorizontalDiscoverBar.m
//  EthnicThread
//
//  Created by DuyLoc on 5/14/16.
//  Copyright © 2016 CodeBox Solutions Ltd. All rights reserved.
//

#import "HorizontalDiscoverBar.h"
#import "PromotionCriteriaCollectionViewCell.h"
#import "LocationManager.h"
#import "AppManager.h"
#import "PromotionTableViewCell.h"

@interface HorizontalDiscoverBar () <UICollectionViewDelegate, UICollectionViewDataSource, ChannelProtocol, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *vLocationContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTopCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnTurnOn;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *promotionCrits;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) horizontalBarBlock onItemSelect;
@property (nonatomic, copy) turnOnLocationBlock turnOnLocationBlockHandler;
@end
@implementation HorizontalDiscoverBar

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)init {
    self = [[[UINib nibWithNibName:NSStringFromClass([HorizontalDiscoverBar class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    BOOL shouldHide = [[LocationManager sharedInstance] authorizationStatusEnable];
    [self shouldHideLocationBar:shouldHide];
    [self.collectionView setHidden:YES];
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 85;
    self.tableView.backgroundColor = PURPLE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"PromotionTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    DLog(@"Bound:%@", NSStringFromCGRect(self.tableView.frame));
    CGRect rect = self.frame;
    self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y, [UIScreen mainScreen].bounds.size.width, rect.size.height);
    return self;
}

- (void)setSelectItem:(PromotionCriteria *) selectedCriteria {
    for (PromotionCriteria *criteria in self.promotionCrits) {
        if ([criteria isEqual:selectedCriteria]) {
            NSIndexPath *indexPath = [[NSIndexPath alloc] init];
            indexPath = [NSIndexPath indexPathForItem:[self.promotionCrits indexOfObject:criteria]  inSection:0];
            DLog(@"Indexpath: %@", indexPath);
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)shouldHideLocationBar:(BOOL)shouldHide {
    [self.vLocationContainer setHidden:shouldHide];
    CGRect rect = self.frame;
    if (shouldHide) {
        self.lcTopCollectionView.constant = 0;
        self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y, [UIScreen mainScreen].bounds.size.width, rect.size.height + 6);
    } else {
        self.lcTopCollectionView.constant = 23;
        self.tableView.frame = CGRectMake(rect.origin.x, rect.origin.y + 23, [UIScreen mainScreen].bounds.size.width, rect.size.height - 13);
    }
}

- (void)setPromotionList:(NSArray *)promotionList {
    self.promotionCrits = [NSArray arrayWithArray:promotionList];
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (IBAction)didTapTurnOn:(id)sender {
    DLog(@"Did tap turn on location")
    if (self.turnOnLocationBlockHandler) {
        self.turnOnLocationBlockHandler(self);
    }
}

- (void)selectCriteriaAtIndex:(NSUInteger)index {
    if (self.promotionCrits.count < index) {
        return;
    }
    [self setSelectItem:[self.promotionCrits objectAtIndex:index]];
}

- (id)initWithBlock:(horizontalBarBlock)onItemSelect {
    self = [self init];
    self.onItemSelect = onItemSelect;
    return self;
}

- (PromotionCriteria *)getCurrentSelectedCriteria {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath != NULL) {
        return [self.promotionCrits objectAtIndex:indexPath.row];
    }
    if (![Utils isNilOrNull:[AppManager sharedInstance].currentCriteria]) {
        PromotionCriteria *criteria = [AppManager sharedInstance].currentCriteria;
        [AppManager sharedInstance].currentCriteria = nil;
        return criteria;
    }
    return nil;
}

- (void)setTurnOnLocationBlock:(turnOnLocationBlock)turnOnBlockHandler {
    _turnOnLocationBlockHandler = turnOnBlockHandler;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PromotionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([PromotionTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    DLog(@"Cell:%@", NSStringFromCGRect(cell.frame));
    PromotionCriteria *crit = [self.promotionCrits objectAtIndex:indexPath.row];
    [cell.btnTitle setTitle:crit.displayText forState:UIControlStateNormal];
    cell.backgroundColor = PURPLE_COLOR;
    [cell.btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.transform = CGAffineTransformMakeRotation(M_PI_2);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.onItemSelect(self, [self.promotionCrits objectAtIndex:indexPath.row]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.promotionCrits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.promotionCrits.count == 0) {
        return 0;
    }
    PromotionCriteria *crit = [self.promotionCrits objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:MEDIUM_FONT_SIZE];
    CGFloat rearWidth = [Utils calculateWidthForString:crit.displayText withHeight:18 andFont:font];
    DLog(@"DisplayText:%@ - width:%f", crit.displayText, rearWidth);
    return rearWidth + 20;
}

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PromotionCriteriaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.promotionCriteria = [self.promotionCrits objectAtIndex:indexPath.row];
    cell.transform = CGAffineTransformMakeRotation(-M_PI_2);
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.promotionCrits.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.onItemSelect(self, [self.promotionCrits objectAtIndex:indexPath.row]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DLog(@"Touch This View");
}
@end
