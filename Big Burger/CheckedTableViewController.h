//
//  CheckedTableViewController.h
//  Big Burger
//
//  Created by Zizoo diesel on 30/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Item.h"
#import "Image.h"
#import "AddRemoveButton.h"
#import "ZGImage.h"

@protocol CheckedTableViewControllerDelegate

- (void)reloadTableView;

@end

@interface CheckedTableViewController : UITableViewController {
    
    id <CheckedTableViewControllerDelegate> delegate;
}

@property (nonatomic, retain) id <CheckedTableViewControllerDelegate> delegate;
@property (nonatomic, retain) NSFetchedResultsController *controller;
@property (nonatomic, retain) IBOutlet UIButton *checkOutButton;
@property (nonatomic, retain) UILabel* numlabel;
@property (nonatomic) double totalPrice;

@property (nonatomic) int sumOfCheckedItems;

- (IBAction)dismiss:(id)sender;
- (IBAction)clearBasket:(id)sender;

@end
