//
//  CommonAPI.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonAPI : NSObject
+ (NSString *) convertDateToString:(NSDate*)date;
+ (NSString *) convertDateTimeToString:(NSDate*)date;
+ (NSDate *) convertStringToDate:(NSString*)date;
+ (NSString *) convertTimeToString:(NSDate*)date;

+ (BOOL) checkDrinkName:(NSString*) name;
+ (BOOL) checkDrinkPrice:(NSString*) string;
+ (BOOL) checkDrinkDescription:(NSString*) string;
+ (void) textEditValidate:(UIView*)view :(BOOL)res;


+ (NSDate*) getStartTimeOfDate:(NSDate*)date;
+ (NSDate*) getEndTimeOfDate:(NSDate*)date;
@end
