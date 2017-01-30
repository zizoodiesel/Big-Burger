//
//  TableViewController.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ItemsSearchTableViewController.h"
#import "CheckedTableViewController.h"

@interface TableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    UIRefreshControl* refreshControl;
    
}

@property (nonatomic, retain) NSFetchedResultsController *controller;
@property (nonatomic, retain) IBOutlet UIButton *checkOutButton;
@property (nonatomic, retain) UILabel* numlabel;
@property (strong, nonatomic) UISearchController *mySearchController;
@property (nonatomic) int sumOfCheckedItems;


@end
