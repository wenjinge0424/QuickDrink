//
//  CommonAPI.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CommonAPI.h"
#import "Util.h"

@implementation CommonAPI
+ (NSString *) convertDateToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd yyyy"];
    return [formatter stringFromDate:date];
}
+ (NSString *) convertDateTimeToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm"];
    return [formatter stringFromDate:date];
}
+ (NSDate *) convertStringToDate:(NSString*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd yyyy"];
    
    
    NSDate *ret = [formatter dateFromString:date];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [ret dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateInLocalTimezone;
}
+ (NSString *) convertTimeToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:date];
}

+ (BOOL) checkDrinkName:(NSString*) name
{
    if (name.length == 0){
        return NO;
    }
    if (name.length>40){
        return NO;
    }
    if (name.length<3){
        return NO;
    }
    return YES;

}
+ (BOOL) checkDrinkPrice:(NSString*) string
{
    if (string.length == 0){
        return NO;
    }
    if (string.length > 8){
        return NO;
    }
    NSNumberFormatter * numberFormatter = [NSNumberFormatter new];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    NSNumber * number = [numberFormatter numberFromString:string];
    if(!number){
        return NO;
    }
    return YES;
}
+ (BOOL) checkDrinkDescription:(NSString*) string
{
    if (string.length == 0){
        return NO;
    }
    if (string.length > 160){
        return NO;
    }
    return YES;
}
+ (void) textEditValidate:(UIView*)view :(BOOL)res
{
    if(!res)
        [Util setBorderView:view color:[UIColor redColor] width:1.f];
    else
        [Util setBorderView:view color:[UIColor clearColor] width:1.f];
}


+ (NSDate*) getStartTimeOfDate:(NSDate*)date
{
    NSDate * beginOfToday = nil;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginOfToday interval:NULL forDate:date];
    return beginOfToday;
}
+ (NSDate*) getEndTimeOfDate:(NSDate*)date
{
    NSDate * beginOfToday = nil;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&beginOfToday interval:NULL forDate:date];
    return [beginOfToday addTimeInterval:(24*3600)-1];
}
@end
