//
//  AppDelegate.m
//  quickdrinks
//
//  Created by mojado on 6/5/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "SCLAlertView.h"


@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    NSTimer *locationtimer;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [GMSServices provideAPIKey:@""];
    [GMSPlacesClient provideAPIKey:@""];
    // Google SignIn
    [GIDSignIn sharedInstance].clientID = @"401999159011-qlni1123nr5b1ituavlulq101f0hov9n.apps.googleusercontent.com";
    
    // Parse init
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"1a292ceb-fae6-4b04-90ea-84773a0eeaec";
        configuration.clientKey = @"2ce5564e-b466-46e2-8361-aadd9649fd27";
        configuration.server = @"https://parse.brainyapps.com:20017/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    
    
    UIUserNotificationType userNotificationType = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:userNotificationType categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    
    
    //
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    
    [PFUser logOutInBackground];
    
    
    [self CurrentLocationIdentifier];
    return YES;
}
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
//    PFInstallation * installation = [PFInstallation currentInstallation];
//    if([PFUser currentUser]){
//        installation[@"user"] = [PFUser currentUser];
//    }
//    [installation saveEventually];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber++;
    [NSNotificationCenter.defaultCenter postNotificationName:PARSE_NOTIFICATION_APP_ACTIVE object:nil];
}

- (BOOL)handleActionURL:(NSURL *)url {
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)CurrentLocationIdentifier
{
    manager = [CLLocationManager new];
    manager.delegate = self;
    manager.distanceFilter = kCLDistanceFilterNone;
    manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    manager.pausesLocationUpdatesAutomatically = NO;
    manager.headingFilter = 5;
    manager.distanceFilter = 0;
    [manager requestAlwaysAuthorization];
    [manager startUpdatingLocation];
    [manager startUpdatingHeading];
    
//    locationtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updatelocation:) userInfo:nil repeats:YES];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    
    
//    self.currentLocation = [[CLLocation alloc] initWithLatitude:29.8830527 longitude:-97.941793];
    //#ifdef DEBUG
    //    self.currentLocation = [[CLLocation alloc] initWithLatitude:29.8830527 longitude:-97.941793];
    //#endif
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
//    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
//     {
//         if (!(error))
//         {
//             self.currentLocationPlacemark = [placemarks objectAtIndex:0];
//             NSString *strAdd = nil;
//             
//             if ([self.currentLocationPlacemark.subThoroughfare length] != 0)
//                 strAdd = self.currentLocationPlacemark.subThoroughfare;
//             
//             if ([self.currentLocationPlacemark.thoroughfare length] != 0)
//             {
//                 // strAdd -> store value of current location
//                 if ([strAdd length] != 0)
//                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark thoroughfare]];
//                 else
//                 {
//                     // strAdd -> store only this value,which is not null
//                     strAdd = self.currentLocationPlacemark.thoroughfare;
//                 }
//             }
//             
//             if ([self.currentLocationPlacemark.postalCode length] != 0)
//             {
//                 if ([strAdd length] != 0)
//                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark postalCode]];
//                 else
//                     strAdd = self.currentLocationPlacemark.postalCode;
//             }
//             
//             if ([self.currentLocationPlacemark.locality length] != 0)
//             {
//                 if ([strAdd length] != 0)
//                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark locality]];
//                 else
//                     strAdd = self.currentLocationPlacemark.locality;
//             }
//             
//             if ([self.currentLocationPlacemark.administrativeArea length] != 0)
//             {
//                 if ([strAdd length] != 0)
//                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark administrativeArea]];
//                 else
//                     strAdd = self.currentLocationPlacemark.administrativeArea;
//             }
//             
//             if ([self.currentLocationPlacemark.country length] != 0)
//             {
//                 if ([strAdd length] != 0)
//                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[self.currentLocationPlacemark country]];
//                 else
//                     strAdd = self.currentLocationPlacemark.country;
//             }
//             self.address = strAdd;
//         }
//     }];
}
- (void) checkTDBRate
{
    [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:10];
}
- (void) showRateDlg
{
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1237147"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:10];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
@end
