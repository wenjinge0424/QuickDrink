//
//  AppDelegate.h
//  quickdrinks
//
//  Created by mojado on 6/5/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PFFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (atomic) BOOL needTDBRate;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLPlacemark *currentLocationPlacemark;
@property (strong, nonatomic) NSString *address;

- (void) checkTDBRate;

@end

