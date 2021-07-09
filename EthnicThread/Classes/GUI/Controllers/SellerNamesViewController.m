//
//  SellerNamesViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "SellerNamesViewController.h"
#import "SearchedUserTableViewCell.h"
#import "SellerProfileViewController.h"

#define NUMBER_OF_CHARS_TO_START_SEARCHING           3

@interface SellerNamesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar    *searchBar;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSMutableArray        *sellerNames;
@property (nonatomic, strong) NSMutableArray        *filterSellerNames;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSString              *justSearchedText;
@property (nonatomic, strong) BasicInfoUserModel              *anySeller;
@property (strong, nonatomic) SearchedUserTableViewCell *offScreenCell;
@end

@implementation SellerNamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.sellerNames = [[NSMutableArray alloc] init];
    BasicInfoUserModel *searchedUser = [[BasicInfoUserModel alloc] initAnySelerText];
    self.anySeller = searchedUser;
    [self.sellerNames addObject:searchedUser];
    self.filterSellerNames = [[NSMutableArray alloc] init];
    self.justSearchedText = @"";
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"seller_names", @"") andTextColor:BLACK_COLOR_TEXT];
    [self setLeftNavigationItem:@""
                   andTextColor:nil
                 andButtonImage:[UIImage imageNamed:@"purple_back_button"]
                       andFrame:CGRectMake(0, 0, 40, 35)];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchDisplayController.searchContentsController.view addSubview:self.spinner];
    NSLayoutConstraint *lc;
    lc = [NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
    [self.spinner addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20];
    [self.spinner addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.searchDisplayController.searchContentsController.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self.searchDisplayController.searchContentsController.view addConstraint:lc];
    lc = [NSLayoutConstraint constraintWithItem:self.spinner attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchDisplayController.searchContentsController.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:85];
    [self.searchDisplayController.searchContentsController.view addConstraint:lc];
    
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UIView *topView = self.searchDisplayController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]){
            ((UITextField *)subView).returnKeyType = UIReturnKeyDone;
        }
    }
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (void)handlerLeftNavigationItem:(id)sender {
    [super handlerLeftNavigationItem:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)executeSearchSelerNames:(NSString *)characters threadObj:(id<OperationProtocol>)threadObj {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.searchDisplayController.searchContentsController.view bringSubviewToFront:self.spinner];
        [self.spinner startAnimating];
    });
    Response *response = [CloudManager searchSellerNameByCharacters:characters];
    if (![threadObj isCancelled] && [response isHTTPSuccess]) {
        NSArray *results = response.getJsonObject;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in results) {
            BasicInfoUserModel *searchedUser = [[BasicInfoUserModel alloc] initWithDictionary:dict];
            [array addObject:searchedUser];
        }
        self.sellerNames = [NSMutableArray arrayWithArray:array];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self filterContentForSearchText:self.searchBar.text];
            [self.searchDisplayController.searchResultsTableView reloadData];
            [self.tableView reloadData];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.spinner stopAnimating];
    });
    [threadObj releaseOperation];
}

#pragma mark - UISearchBarDelegate 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.filterSellerNames.count == 0) return;
    if ([self.delegate respondsToSelector:@selector(searchSelerNameResult:)]) {
        BasicInfoUserModel *searchUser = [self.filterSellerNames objectAtIndex:0];
        [self.delegate searchSelerNameResult:searchUser];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        
    } else {
        if (searchText.length == NUMBER_OF_CHARS_TO_START_SEARCHING && ![self.justSearchedText isEqualToString:searchText]) {
            self.justSearchedText = searchText;
            [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeSearchSelerNames:threadObj:) argument:searchText];
        }
        else {
            [self filterContentForSearchText:searchText];
        }
    }

}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.filterSellerNames removeAllObjects];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.filterSellerNames removeAllObjects];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if ([searchString isEqualToString:@""]) {
        
    } else {
        if (searchString.length == NUMBER_OF_CHARS_TO_START_SEARCHING && ![self.justSearchedText isEqualToString:searchString]) {
            self.justSearchedText = searchString;
            [[OperationManager shareInstance] dispatchLowThreadWithTarget:self selector:@selector(executeSearchSelerNames:threadObj:) argument:searchString];
        }
        else {
            [self filterContentForSearchText:searchString];
        }
        return YES;
    }
    return NO;
}

- (void)filterContentForSearchText:(NSString *)searchText {
    [self.filterSellerNames removeAllObjects];
    DLog(@"SearchText: %@", searchText);
    for (BasicInfoUserModel *searchUser in self.sellerNames) {
        DLog(@"User: %@", [searchUser getDisplayName]);
        NSUInteger length = 0;
        if (searchText.length < [searchUser getDisplayName].length) {
            length = searchText.length;
        } else {
            length = [searchUser getDisplayName].length;
        }
        NSComparisonResult result = [[searchUser getDisplayName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, length)];
        if (result == NSOrderedSame) {
            [self.filterSellerNames addObject:searchUser];
        }
    }
    if (self.filterSellerNames.count == 0) {
        [self.filterSellerNames addObject:self.anySeller];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterSellerNames.count;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString *Identifier = @"SearchedUserCell";
    SearchedUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[[UINib nibWithNibName:NSStringFromClass([SearchedUserTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    }
    BasicInfoUserModel *searchUser = [self.filterSellerNames objectAtIndex:indexPath.row];
    cell.searchUser = searchUser;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicInfoUserModel *searchUser = (tableView == self.tableView) ? [self.sellerNames objectAtIndex:indexPath.row] : [self.filterSellerNames objectAtIndex:indexPath.row];
    if (searchUser.isAnySeller) {
        return 35;
    }
    if (!self.offScreenCell) {
        self.offScreenCell = [[[UINib nibWithNibName:NSStringFromClass([SearchedUserTableViewCell class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
    }
    self.offScreenCell.searchUser = searchUser;
    
    [self.offScreenCell setNeedsUpdateConstraints];
    [self.offScreenCell updateConstraintsIfNeeded];
    self.offScreenCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.offScreenCell.bounds));
    [self.offScreenCell setNeedsLayout];
    [self.offScreenCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [self.offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height += 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self callCancelButtonInSearchView:self.searchBar];
    BasicInfoUserModel *searchUser = (tableView == self.tableView) ? [self.sellerNames objectAtIndex:indexPath.row] : [self.filterSellerNames objectAtIndex:indexPath.row];
    if ([searchUser.display_name isEqualToString:@"Any Seller"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self accessProfile:searchUser];
    });
    //Customer wants to access seller profile right here
    //[self accessProfile:searchUser];
    //    if ([self.delegate respondsToSelector:@selector(searchSelerNameResult:)]) {
    //        BasicInfoUserModel *searchUser = (tableView == self.tableView) ? [self.sellerNames objectAtIndex:indexPath.row] : [self.filterSellerNames objectAtIndex:indexPath.row];
    //        [self.delegate searchSelerNameResult:searchUser];
    //    }
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (void)accessProfile:(BasicInfoUserModel *)aUser {
    SellerProfileViewController *vc = [[SellerProfileViewController alloc] init];
    SellerModel *sellerModel = [[SellerModel alloc] initWithDictionary:[aUser toDictionary]];
    vc.sellerModel = sellerModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)callCancelButtonInSearchView:(UIView *)aViewNode {
    if ([aViewNode isKindOfClass:[UIButton class]]) {
        [(UIButton *)aViewNode sendActionsForControlEvents:UIControlEventAllEvents];
        return;
    }
    NSArray *subviews = [aViewNode subviews];
    for (UIView *view in subviews) {
        [self callCancelButtonInSearchView:view];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self.searchBar resignFirstResponder];
}
@end
