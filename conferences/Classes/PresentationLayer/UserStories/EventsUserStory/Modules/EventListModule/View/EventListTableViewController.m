//
//  EventListView.m
//  Conferences
//
//  Created by Karpushin Artem on 12/10/15.
//  Copyright 2015 Rambler. All rights reserved.
//

#import "EventListTableViewController.h"
#import "EventListViewOutput.h"
#import "DataDisplayManager.h"
#import "EventListDataDisplayManager.h"

@interface EventListTableViewController() <EventLIstDataDisplayManagerDelegate>

@end

@implementation EventListTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.output setupView];
}

#pragma mark - EventListViewInput

- (void)setupViewWithEventList:(NSArray *)events {
    [self.dataDisplayManager updateTableViewModelWithEvents:events];
    self.dataDisplayManager.delegate = self;
    
    self.tableView.dataSource = [self.dataDisplayManager dataSourceForTableView:self.tableView];
    self.tableView.delegate = [self.dataDisplayManager delegateForTableView:self.tableView withBaseDelegate:nil];
}

- (void)updateViewWithEventList:(NSArray *)events {
    [self.dataDisplayManager updateTableViewModelWithEvents:events];
}

#pragma mark - EventLIstDataDisplayManagerDelegate

- (void)didUpdateTableViewModel {
    self.tableView.dataSource = [self.dataDisplayManager dataSourceForTableView:self.tableView];
    [self.tableView reloadData];
}

- (void)didTapCellWithEvent:(PlainEvent *)event {
    [self.output didTriggerTapCellWithEvent:event];
}

@end