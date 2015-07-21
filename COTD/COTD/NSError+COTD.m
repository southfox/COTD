//
//  NSError+COTD.m
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "NSError+COTD.h"

@implementation NSError (COTD)

+ (id)errorWithMessage:(NSString *)message;
{
    return [NSError errorWithDomain:@"com.relbane.COTD" code:-1 userInfo:@{@"inner_error_object" : message}];
}

@end
