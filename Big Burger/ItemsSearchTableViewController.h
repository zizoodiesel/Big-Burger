//
//  ItemsSearchTableViewController.h
//  Big Burger
//
//  Created by Zizoo diesel on 30/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "ZGImage.h"
#import "AddRemoveButton.h"

@protocol ItemsSearchTableViewDelegate <NSObject>

@property (nonatomic, retain) UILabel* numlabel;
@property (nonatomic, retain) IBOutlet UIButton *checkOutButton;
@property (nonatomic) int sumOfCheckedItems;

@end

@interface ItemsSearchTableViewController : UITableViewController <UISearchResultsUpdating> {
    
    id <ItemsSearchTableViewDelegate> delegate;
    
}

@property (nonatomic, retain) id <ItemsSearchTableViewDelegate> delegate;
@property (nonatomic, retain) NSArray* filteredItems;

@end
