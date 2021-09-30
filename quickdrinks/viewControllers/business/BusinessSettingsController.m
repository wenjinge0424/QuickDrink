//
//  BusinessSettingsController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessSettingsController.h"
#import "InformViewController.h"
#import "SCLAlertView.h"
#import "Util.h"
#import "StackMemory.h"
#import "DBCong.h"
#import "DBAssignItem.h"
#import "AppDelegate.h"
#import "CustomerStripeAccountController.h"

@interface BusinessSettingsController ()
{
    int currentIndex;
    
    int current_orderOnline;
}
@property (strong, nonatomic) IBOutlet UITableView *m_containerTable;
@property (strong, nonatomic) IBOutlet UILabel *lbl_onlineClose;
@end

@implementation BusinessSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getOnLineOder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.m_containerTable setContentOffset:CGPointZero];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) getOnLineOder
{
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
    [query whereKey:@"user_id" equalTo:defaultUser.row_id];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
        if(!error){
            current_orderOnline = [object[@"online_order"] intValue];
            if(current_orderOnline == 0){
                [self.lbl_onlineClose setText:@"Close"];
            }else{
                [self.lbl_onlineClose setText:@"Open"];
            }
        }
    }];
}
- (void) setOnLineOrder:(int) value
{
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
    [query whereKey:@"user_id" equalTo:defaultUser.row_id];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
        if(object){
            object[@"online_order"] = [NSNumber numberWithInt:value];
            [object saveInBackground];
        }else{
            PFObject *obj = [PFObject objectWithClassName:@"Setting_online_order"];
            obj[@"user_id"] = defaultUser.row_id;
            obj[@"online_order"] = [NSNumber numberWithInt:value];
            [obj saveInBackground];
        }
    }];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showInforViewFromBusiness"]){
        InformViewController * controller = (InformViewController*)[segue destinationViewController];
        controller.flag = currentIndex;
    }
}
- (IBAction)onOnline:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFQuery queryWithClassName:@"Delivery"];
    [query whereKey:@"user_id" equalTo:defaultUser.row_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if(!error){
            if(objects.count > 0){
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction * selectGallery = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self setOnLineOrder:1];
                    [self.lbl_onlineClose setText:@"Open"];
                    [alert dismissViewControllerAnimated:YES completion:^(){
                        
                    }];
                }];
                UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [self setOnLineOrder:0];
                    [self.lbl_onlineClose setText:@"Close"];
                    [alert dismissViewControllerAnimated:YES completion:^(){
                        
                    }];
                }];
                UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    [alert dismissViewControllerAnimated:YES completion:^(){}];
                }];
                [alert addAction:selectGallery];
                [alert addAction:takePhoto];
                [alert addAction:cancel];
                
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Drink" message:@"You have not registered any delivery location yet."];
            }
        }else{
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Drink" message:@"You have not registered any delivery location yet."];
        }
    }];
}

- (IBAction)onStaffAssignment:(id)sender {
    [self performSegueWithIdentifier:@"onNewStaff" sender:self];
}
- (IBAction)onEditPaymentInfo:(id)sender {
    CustomerStripeAccountController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomerStripeAccountController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onRate:(id)sender {
    
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
        [appDelegate checkTDBRate];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onReport:(id)sender {
}
- (IBAction)onAboutApp:(id)sender {
    currentIndex = 2;
    [self performSegueWithIdentifier:@"showInforViewFromBusiness" sender:self];
    
}
- (IBAction)onPrivacy:(id)sender {
    currentIndex = 1;
    [self performSegueWithIdentifier:@"showInforViewFromBusiness" sender:self];
    
}
- (IBAction)onTerms:(id)sender {
    currentIndex = 0;
    [self performSegueWithIdentifier:@"showInforViewFromBusiness" sender:self];
    
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
    [alert showInfo:@"Setting" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
@end
