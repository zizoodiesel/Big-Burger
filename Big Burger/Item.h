//
//  Item+CoreDataClass.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Item : NSManagedObject

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *desc;
@property (nonatomic) double price;
@property (nullable, nonatomic, copy) NSString *ref;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nonatomic) int numberOfItems;
@property (nullable, nonatomic, retain) Image *image;

@end
