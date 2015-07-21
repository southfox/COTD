//
//  NSDate+COTD.m
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//
#import "NSDate+COTD.h"

@implementation NSDate (COTD)


- (NSString *)formattedDate
{
    static NSDateFormatter *formatter = nil;
    if (nil == formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM d yyyy";
    }
    return [formatter stringFromDate:self];
}



@end
