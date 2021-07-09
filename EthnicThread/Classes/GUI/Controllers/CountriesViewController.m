//
//  CountriesViewController.m
//  EthnicThread
//
//  Created by Duy Nguyen on 1/24/15.
//  Copyright (c) 2015 CodeBox Solutions Ltd. All rights reserved.
//

#import "CountriesViewController.h"

@interface CountriesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar    *searchBar;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (nonatomic, strong) NSMutableArray        *filterCountries;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation CountriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariables {
    [super initVariables];
    self.filterCountries = [[NSMutableArray alloc] init];
}

- (void)initComponentUI {
    [super initComponentUI];
    [self setNavigationBarTitle:NSLocalizedString(@"countries", @"") andTextColor:BLACK_COLOR_TEXT];
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

#pragma mark - UISearchBarDelegate 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchCountryResult:)]) {
        [self.delegate searchCountryResult:self.searchBar.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchText];
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.filterCountries removeAllObjects];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.filterCountries removeAllObjects];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    return YES;
}

- (void)filterContentForSearchText:(NSString *)searchText {
    [self.filterCountries removeAllObjects];
    for (NSString *text in self.countries) {
        NSComparisonResult result = [text compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, MIN(text.length, searchText.length))];
        if (result == NSOrderedSame) {
            [self.filterCountries addObject:text];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.searchBar.text.length == 0) ? self.countries.count : self.filterCountries.count;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString *Identifier = @"SellerNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.textLabel.text = (self.searchBar.text.length == 0) ? [self.countries objectAtIndex:indexPath.row] : [self.filterCountries objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(searchCountryResult:)]) {
        NSString *country = (tableView == self.tableView) ? [self.countries objectAtIndex:indexPath.row] : [self.filterCountries objectAtIndex:indexPath.row];
        [self.delegate searchCountryResult:country];
    }
    [self.searchDisplayController setActive:NO animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    [self.searchBar resignFirstResponder];
}
@end
