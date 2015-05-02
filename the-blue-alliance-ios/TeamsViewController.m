//
//  TeamsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/24/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "TeamsViewController.h"
#import "OrderedDictionary.h"
#import "TBAApp.h"
#import "TBAKit.h"
#import "TBAImporter.h"
#import "HMSegmentedControl.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>
#import "TeamTableViewCell.h"


static NSString *const TeamCellReuseIdentifier = @"Team Cell";


@interface TeamsViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *filteredTeams;

@end


@implementation TeamsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf updateRefreshBarButtonItem:YES];
            [strongSelf refreshData];
        }
    };
    
    self.filteredTeams = [[NSMutableArray alloc] init];
    
    [self fetchTeams];
    [self styleInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self cancelRefresh];
    [self updateRefreshBarButtonItem:NO];
}


#pragma mark - Data Methods

- (void)fetchTeams {
    NSArray *teams = [Team fetchAllTeamsFromContext:[TBAApp managedObjectContext]];
    if (!teams || [teams count] == 0) {
        if (self.refresh) {
            self.refresh();
        }
    } else {
        self.filteredTeams = teams;
    }
}

- (void)getTeamsForPage:(int)page {
    self.currentRequestIdentifier = [[TBAKit sharedKit] executeTBAV2Request:[NSString stringWithFormat:@"teams/%@", @(page)] callback:^(id objects, NSError *error) {
        self.currentRequestIdentifier = 0;
        
        if (error) {
            NSLog(@"Error loading teams: %@", error.localizedDescription);
        }
        if (!error && [objects isKindOfClass:[NSArray class]] && [objects count] > 0) {
            [TBAImporter importTeams:objects];
        }

        if ([objects isKindOfClass:[NSArray class]]) {
            if ([objects count] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateRefreshBarButtonItem:NO];

                    [self fetchTeams];
                    [self updateInterface];
                });
            } else {
                [self getTeamsForPage:page + 1];
            }
        }
    }];
}

- (void)refreshData {
    [self getTeamsForPage:0];
}


#pragma mark - Interface Methods

- (void)styleInterface {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self updateInterface];
}

- (void)updateInterface {
    [self.tableView reloadData];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.filteredTeams) {
        // TODO: Show no data screen
        return 0;
    }
    return [self.filteredTeams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamCellReuseIdentifier forIndexPath:indexPath];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];

    cell.numberLabel.text = [team.team_number stringValue];
    cell.nameLabel.text = team.nickname;
    cell.locationLabel.text = team.location;
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Team *team = [self.filteredTeams objectAtIndex:indexPath.row];
    NSLog(@"Selected team: %@", team.team_number);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filteredTeams = [Team fetchTeamsWithPredicate:[self predicateForSearchText:searchText] fromContext:[TBAApp managedObjectContext]];

    [self.tableView reloadData];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}


#pragma mark - Searching

- (NSPredicate *)predicateForSearchText:(NSString *)searchText {
    NSPredicate *searchPredicate;
    if (searchText && searchText.length) {
        searchPredicate = [NSPredicate predicateWithFormat:@"(nickname contains[cd] %@ OR team_number beginswith[cd] %@)", searchText, searchText];
    }
    return searchPredicate;
}


@end
