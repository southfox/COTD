//
//  COTDParse.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const COTDParseServiceQueryDidFinishNotification;

@interface COTDParse : NSObject

+ (COTDParse *)sharedInstance;

- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (NSString *)currentUserSearchTerm;
- (void)changeCurrentUserSearchTerm:(NSString *)searchTerm;

- (NSString *)currentUserExcludeTerms;

- (NSString *)currentUserImageTitle;

- (NSString *)currentUserImageUrl;

- (void)likeCurrentImage:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (void)updateImage:(NSString *)imageUrl title:(NSString *)title searchTerm:(NSString *)searchTerm;

- (void)topTenImages:(void (^)(NSArray *objects, NSError *error))finishBlock;

@end
