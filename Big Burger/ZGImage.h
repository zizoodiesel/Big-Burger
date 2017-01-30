//
//  ZiedImage.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncConnection.h"

@interface MyStore : NSObject

@property (nonatomic, retain) NSMutableArray *URLsArray;

+ (id)sharedStore;

@end



@interface ZGImage : UIImageView

- (void)downloadWithUrlString:(NSString*)urlString completitionHendler:(void (^)(NSData*, NSError*))imageData;
+ (UIImage*)thumbnailFromData:(NSData*)data withSize:(CGSize)size;
+ (NSData*)imageDataFromImage:(UIImage*)image;

@end
