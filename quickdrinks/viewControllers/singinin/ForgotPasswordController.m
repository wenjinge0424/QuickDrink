//
//  ForgotPasswordController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "ForgotPasswordController.h"
#import "Util.h"
#import "DBCong.h"
#import "SCLAlertView.h"

@interface ForgotPasswordController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *edt_email;

@end

@implementation ForgotPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_email setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSubmit:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    
    NSString *email = _edt_email.text;
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (email.length <= 0){
        [Util showAlertTitle:self title:@"Reset password" message:@"Please enter email." finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Reset password" message:@"Email address is invalid" finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
        
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers checkUserWithEmail:self.edt_email.text userType:0 sucessBlock:^(id returnItem, NSError * error){
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [Util showAlertTitle:self
                               title:@"Success"
                             message: [NSString stringWithFormat: @"We've sent a password reset link to your email"]
                              finish:^(void) {
                                  [self onBack:nil];
                              }];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                [Util showAlertTitle:self
                               title:@"Reset password"
                             message:errorString
                              finish:^(void) {
                              }];
            }
        }];
        
    } failBlock:^( NSError * error){
        [SVProgressHUD dismiss];
        [Util setLoginUserName:@"" password:@""];
        
        NSString *msg = @"Email entered is not registered. Create an account now?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Not Now" actionBlock:^(void) {
        }];
        [alert addButton:@"Sign Up" actionBlock:^(void) {
            [self onSignUp:self];
        }];
        [alert showError:@"SignUp" subTitle:msg closeButtonTitle:nil duration:0.0f];
    }];
    
    
}
- (IBAction)onSignUp:(id)sender {
    [self performSegueWithIdentifier:@"goSignUpFromForget" sender:self];
}

@end
