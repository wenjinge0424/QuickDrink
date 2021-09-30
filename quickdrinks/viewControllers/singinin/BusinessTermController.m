//
//  BusinessTermController.m
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessTermController.h"
#import "DBCong.h"
#import "Util.h"
#import "SCLAlertView.h"

@interface BusinessTermController ()
@property (strong, nonatomic) IBOutlet UIButton *btn_agree;
@property (strong, nonatomic) IBOutlet UIButton *btn_disagree;

@end

@implementation BusinessTermController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSelectAgree:(id)sender {
    [self.btn_agree setSelected:YES];
    [self.btn_disagree setSelected:NO];
}
- (IBAction)onSelectDisagree:(id)sender {
    [self.btn_agree setSelected:NO];
    [self.btn_disagree setSelected:YES];
}
- (IBAction)onDone:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if(![self.btn_agree isSelected]){
        NSString *msg = @"Are you sure you don't want to continue?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"YES" actionBlock:^(void) {
           [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alert addButton:@"NO" actionBlock:^(void) {
        }];
        [alert showQuestion:@"" subTitle:msg closeButtonTitle:nil duration:0.0f];
        
    }else{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        defaultUser.row_agree = 1;
        [DBUsers addAgreeInfoTo:defaultUser sucessBlock:^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            
            NSUserDefaults * defaultValue = [[NSUserDefaults alloc] init];
            [defaultValue setValue:defaultUser.row_userEmail forKey:@"SignIn_Email"];
            [defaultValue setValue:defaultUser.row_userPassword forKey:@"SignIn_Password"];
            [defaultValue setBool:NO forKey:@"LogOut"];
            [defaultValue synchronize];
            
            
            [self performSegueWithIdentifier:@"showBusinessMainFromTerm" sender:self];
        }failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }];
    }
}
@end
