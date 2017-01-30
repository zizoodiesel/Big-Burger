//
//  AsyncConnection.m
//  Big Burger
//
//  Created by Zizoo diesel on 29/01/2017.
//  Copyright © 2017 Zizoo diesel. All rights reserved.
//

#import "AsyncConnection.h"

@implementation AsyncConnection

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"connection didFailWithError : %d", error.code);
    
    _myCompblock(_myResponse, nil, error);

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"status code: %d", code);
    
    _myResponse = response;
    
    
    if (code != 200) {
        
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Internal Server Error" forKey:NSLocalizedDescriptionKey];
        NSError *customError = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:details];
        
        _myCompblock(nil, nil, customError);

    }
    

    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [_receivedData appendData:data];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    
    NSLog(@"connectionDidFinishLoading");
    _myCompblock(_myResponse, _receivedData, nil);

    
}

- (void)startWithRequest:(NSMutableURLRequest*)request completitionHandler:(myCompletion) compblock {


    _myCompblock = compblock;

    _receivedData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    
    [connection start];
    
}

+(void)sendAsyncRequestWithUrl:(NSString*)urlString completitionHandler:(myCompletion) compblock {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
    [[[self alloc] init] startWithRequest:request completitionHandler:compblock];

}


@end
 
