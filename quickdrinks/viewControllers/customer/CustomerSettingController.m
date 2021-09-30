//
//  CustomerSettingController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerSettingController.h"
#import "InformViewController.h"
#import "SCLAlertView.h"
#import "Util.h"
#import "StackMemory.h"

@interface CustomerSettingController ()
{
    int currentIndex;
}
@end

@implementation CustomerSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showInforViewFromCustom"]){
        InformViewController * controller = (InformViewController*)[segue destinationViewController];
        controller.flag = currentIndex;
    }
}

- (IBAction)onRateApp:(id)sender {
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
- (IBAction)onreport:(id)sender {
}
- (IBAction)onAboutApp:(id)sender {
    currentIndex = 2;
    [self performSegueWithIdentifier:@"showInforViewFromCustom" sender:self];
    
}
- (IBAction)onPrivacy:(id)sender {
    currentIndex = 1;
    [self performSegueWithIdentifier:@"showInforViewFromCustom" sender:self];
    
}
- (IBAction)onTerm:(id)sender {
    currentIndex = 0;
    [self performSegueWithIdentifier:@"showInforViewFromCustom" sender:self];
    
}
- (IBAction)onSignOut:(id)sender {
    NSString *msg = @"Are you sure you want to sign out?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        PFUser * currentUser = [PFUser currentUser];
        if(currentUser)
            [PFUser logOut];
        
        NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
        [defaultValue setBool:YES forKey:@"LogOutFromFlow"];
        [defaultValue synchronize];
        [[StackMemory createInstance] setStack_signInItem:nil];
        [self.navigationController.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert showError:@"Setting" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
@end
