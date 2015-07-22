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

- (void)queryTerm:(NSString*)term excludeTerms:(NSString *)excludeTerms finishBlock:(void (^)(BOOL succeeded, NSString *link, NSString *title, NSError *error))finishBlock;


@end
