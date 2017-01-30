//
//  AsyncConnection.h
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^myCompletion)(NSURLResponse *response, NSData *data, NSError *error);

@interface AsyncConnection : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain)NSMutableData* receivedData;
@property (nonatomic, retain)NSURLResponse* myResponse;
@property (nonatomic, copy)myCompletion myCompblock;


+(void)sendAsyncRequestWithUrl:(NSString*)url completitionHandler:(myCompletion) compblock;


@end
