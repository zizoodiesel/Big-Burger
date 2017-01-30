//
//  Image+CoreDataClass.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Image : NSManagedObject

@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) Item *item;

@end

