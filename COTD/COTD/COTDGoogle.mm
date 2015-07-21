//
//  COTDGoogle.m
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "COTDGoogle.h"
#import "NSError+COTD.h"
#import <AFNetworking.h>


@interface COTDGoogle()
@end

@implementation COTDGoogle

+ (COTDGoogle *)sharedInstance
{
    static COTDGoogle *_sharedInstance = nil;
    
    @synchronized (self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#define kURL @"https://www.googleapis.com/customsearch/v1?key=AIzaSyADOPSjmHQYFFf9ZnWTqVQ3kPRwr5ND6l8&cx=003054679763599795063:tka3twkxrbw&q=capybara"


- (void)queryTerm:(NSString*)term finishBlock:(void (^)(BOOL succeeded, NSString *imageUrl, NSError *error))finishBlock;
{
    __block void(^bfinishBlock)(BOOL succeeded, NSString *imageUrl, NSError *error) = finishBlock;
    
    __weak typeof(self) wself = self;
    
    NSURL *serviceUrl = [NSURL URLWithString:kURL];

    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceUrl];
    [serviceRequest setValue:@"text/json" forHTTPHeaderField:@"Content-type"];
    [serviceRequest setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:serviceRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", [[NSString alloc] initWithData:responseObject encoding:NSStringEncodingConversionAllowLossy]);
        
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        if (jsonError)
        {
            bfinishBlock(NO, nil, jsonError);
        }
        else
        {
            NSArray *items = json[@"items"];
            NSString *imageUrl = nil;
            do {
                int randomItemKey = arc4random() % items.count;
                NSDictionary *randomItem = items[randomItemKey];
                NSDictionary *pagemap = randomItem[@"pagemap"];
                if (!pagemap)
                {
                    continue;
                }
                NSArray *cseimage = pagemap[@"cse_image"];
                if (!cseimage)
                {
                    continue;
                }
                int randomImageKey = arc4random() % cseimage.count;
                NSDictionary *image = cseimage[randomImageKey];
                if (!image)
                {
                    continue;
                }
                imageUrl = image[@"src"];
                if (!imageUrl)
                {
                    continue;
                }
            } while (0);
            bfinishBlock(imageUrl ? YES : NO, imageUrl, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        bfinishBlock(NO, nil, error);
    }];
    
    [operation start];

}



@end
