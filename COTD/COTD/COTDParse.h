//
//  COTDParse.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <Foundation/Foundation.h>
class COTDImage;

extern NSString *const COTDParseServiceQueryDidFinishNotification;

@interface COTDParse : NSObject

+ (COTDParse *)sharedInstance;

- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (NSString *)currentUserSearchTerm;
- (void)changeCurrentUserSearchTerm:(NSString *)searchTerm;

- (NSUInteger)currentStart;

- (NSString *)currentUserImageTitle;

- (NSString *)currentUserImageUrl;

- (BOOL)isLinkRepeated:(NSString *)fullUrl;

- (void)likeCurrentImage:(void (^)(BOOL succeeded, NSError *error))finishBlock;

- (void)updateImage:(NSString *)imageUrl thumbnailUrl:(NSString *)thumbnailUrl title:(NSString *)title searchTerm:(NSString *)searchTerm finishBlock:(void (^)(BOOL succeeded, COTDImage* image, NSError *error))finishBlock;

- (void)topTenImages:(void (^)(NSArray *objects, NSError *error))finishBlock;

@end
