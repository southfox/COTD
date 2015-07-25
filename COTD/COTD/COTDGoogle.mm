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

//#define URLFORMAT @"https://www.googleapis.com/customsearch/v1?key=AIzaSyADOPSjmHQYFFf9ZnWTqVQ3kPRwr5ND6l8&cx=003054679763599795063:tka3twkxrbw&searchType=image&&fields=items(link,title,image/thumbnailLink)&start=%d&num=1&q=capybara"
//#define URLFORMAT @"https://www.googleapis.com/customsearch/v1?key=AIzaSyDipywri5f6D__qqcCgvbBzP9uF5xbP9b0&cx=003054679763599795063:tka3twkxrbw&searchType=image&fields=items(link,title,image/thumbnailLink)&start=%d&num=1&q=capybara"
//#define URLFORMAT @"https://www.googleapis.com/customsearch/v1?key=AIzaSyCv-rIYBwljnGmgJAxMIh8wBaXpqT6U-T0&cx=003054679763599795063:tka3twkxrbw&searchType=image&&fields=items(link,title,image/thumbnailLink)&start=%d&num=1&q=capybara"
#define URLFORMAT @"https://www.googleapis.com/customsearch/v1?key=AIzaSyDhZSxw5rAjmGLHGBJH5ouHDWnMg42LW4g&cx=003054679763599795063:tka3twkxrbw&searchType=image&fields=items(link,title,image/thumbnailLink)&start=%d&num=1&q=capybara"
//#define URLFORMAT @"https://www.googleapis.com/customsearch/v1?key=AIzaSyDipywri5f6D__qqcCgvbBzP9uF5xbP9b0&cx=003054679763599795063:tka3twkxrbw&searchType=image&fields=items(link,title,image/thumbnailLink)&start=%d&num=1&q=capybara"


- (void)queryTerm:(NSString*)term start:(NSInteger)start finishBlock:(void (^)(BOOL succeeded, NSString *link, NSString *thumbnailLink, NSString *title, NSError *error))finishBlock;
{
    __block void(^bfinishBlock)(BOOL succeeded, NSString *link, NSString *thumbnailLink, NSString *title, NSError *error) = finishBlock;
    
    NSString *urlString = [NSString stringWithFormat:URLFORMAT, (int)start];
    
    if (term.length)
    {
        NSString *searchTerm = [[NSString stringWithFormat:@" %@", term]  stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        urlString = [urlString stringByAppendingFormat:@"%@", searchTerm];
    }
    
    NSURL *serviceUrl = [NSURL URLWithString:urlString];

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
            bfinishBlock(NO, nil, nil, nil, jsonError);
        }
        else
        {
            NSArray *items = json[@"items"];
            NSDictionary *itemFound = items.firstObject;
            NSString *title = itemFound[@"title"];
            NSString *link = itemFound[@"link"];
            NSString *thumbnailLink = itemFound[@"image"][@"thumbnailLink"];
            bfinishBlock(link ? YES : NO, link, thumbnailLink, title, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        bfinishBlock(NO, nil, nil, nil, error);
    }];
    
    [operation start];

}



@end
