//
//  DetailViewController.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Image.h"

@interface DetailViewController : UIViewController

@property (nonatomic, retain) Item* item;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView* itemImageView;
@property (nonatomic, retain) IBOutlet UILabel* descLabel;

@end
