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

#define URL @"https://www.googleapis.com/customsearch/v1?key=AIzaSyADOPSjmHQYFFf9ZnWTqVQ3kPRwr5ND6l8&cx=003054679763599795063:tka3twkxrbw&searchType=image&items(link,title)&start=1&num=1&q=capybara"


- (void)queryTerm:(NSString*)term excludeTerms:(NSString *)excludeTerms finishBlock:(void (^)(BOOL succeeded, NSString *link, NSString *title, NSError *error))finishBlock;
{
    __block void(^bfinishBlock)(BOOL succeeded, NSString *link, NSString *title, NSError *error) = finishBlock;
    
    NSString *urlString = URL;
    
    //https://www.googleapis.com/customsearch/v1?key=AIzaSyADOPSjmHQYFFf9ZnWTqVQ3kPRwr5ND6l8&cx=003054679763599795063:tka3twkxrbw&q=capybara%20cute&searchType=image&safe=high&num=1&start=100&fields=items(link,title)&excludeTerms=%22babies%20-%20Terribly%20Cute%22%20%22Capybara%20on%20Pinterest%20|%20Guinea%20Pigs,%20Book%20Projects%20and%20Dachshund%22%20%22Capybara%20in%20Japan%20Take%20Baths,%20Think%20They%27re%20People%20-%20Tofugu%22%20%22Pets%20on%20Pinterest%20|%20Giant%20Dogs,%20Stuffed%20Animals%20and%20Giant%20Stuffed%20...%22%20%22Image%20-%20Capybara-02.jpg%20-%20Cookie%20Clicker%20Wiki%22%20%22File:Capybara%20portrait.jpg%20-%20Wikimedia%20Commons%22%20%22Tuff%27n,%20The%20Cutest%20Baby%20Capybara%20in%20The%20World.%20Part%20One%20...%22%20%22Capybara%20photo%20-%20Hydrochoerus%20hydrochaeris%20-%20G42006%20|%20ARKive%22%20%22Capybara%20on%20Pinterest%20|%20Guinea%20Pigs,%20Book%20Projects%20and%20Dachshund%22
    
    if (term)
    {
        NSString *searchTerm = [term stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        [urlString stringByAppendingFormat:@"%@", searchTerm];
    }
    
    if (excludeTerms)
    {
        NSString *excludeSearchTerms = [[NSString stringWithFormat:@"&excludeTerms=%@", excludeTerms] stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        [urlString stringByAppendingFormat:@"%@", excludeSearchTerms];
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
            bfinishBlock(NO, nil, nil, jsonError);
        }
        else
        {
            NSArray *items = json[@"items"];
            NSDictionary *itemFound = items.firstObject;
            NSString *title = itemFound[@"title"];
            NSString *link = itemFound[@"link"];
            bfinishBlock(link ? YES : NO, link, title, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        bfinishBlock(NO, nil, nil, error);
    }];
    
    [operation start];

}



@end
