//
//  AddRemoveButton.h
//  Big Burger
//
//  Created by Zizoo diesel on 30/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddRemoveButton : UIButton {
    
    NSIndexPath* cellIndexPath;
    
}

@property (nonatomic, retain)NSIndexPath* cellIndexPath;

@end
