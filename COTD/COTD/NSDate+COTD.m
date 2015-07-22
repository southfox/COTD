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


- (NSDate *)addDays:(NSInteger)days
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    [comps setDay:comps.day + days];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];

}



@end
