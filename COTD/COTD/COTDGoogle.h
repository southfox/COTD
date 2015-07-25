//
//  COTDGoogle.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COTDGoogle : NSObject

+ (COTDGoogle *)sharedInstance;

- (void)queryTerm:(NSString*)term start:(NSInteger)start finishBlock:(void (^)(BOOL succeeded, NSString *link, NSString *thumbnailLink, NSString *title, NSError *error))finishBlock;


@end
