//
//  ZiedImage.m
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "ZGImage.h"

@implementation MyStore

#pragma mark Singleton Methods

+ (id)sharedStore {
    static MyStore *sharedMyStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyStore = [[self alloc] init];
    });
    return sharedMyStore;
}

- (id)init {
    if (self = [super init]) {
        _URLsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

@implementation ZGImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)downloadWithUrlString:(NSString*)urlString completitionHendler:(void (^)(NSData *, NSError *))imageData {
    
    if (![((MyStore*)[MyStore sharedStore]).URLsArray containsObject:urlString]) {
        
        [((MyStore*)[MyStore sharedStore]).URLsArray addObject:urlString];
        
        [AsyncConnection sendAsyncRequestWithUrl:urlString completitionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            [((MyStore*)[MyStore sharedStore]).URLsArray removeObject:urlString];
            imageData(data, nil);
            
        }];
    }
    
}

+ (UIImage*)thumbnailFromData:(NSData*)data withSize:(CGSize)size {
    
    UIImage* image = [UIImage imageWithData:data];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSData*)imageDataFromImage:(UIImage*)image {
    
    return UIImagePNGRepresentation(image);
    
}

@end
