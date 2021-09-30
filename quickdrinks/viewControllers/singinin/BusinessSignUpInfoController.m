//
//  BusinessSignUpInfoController.m
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessSignUpInfoController.h"
#import "UITextField+Complete.h"
#import "DBCong.h"
#import "Util.h"

@interface BusinessSignUpInfoController () <UITextFieldDelegate>
{
    int animationHeight;
}
@property (retain, nonatomic) IBOutlet UITextField *edt_email;
@property (retain, nonatomic) IBOutlet UITextField *edt_passwd;
@property (retain, nonatomic) IBOutlet UITextField *edt_confirm;

@end

@implementation BusinessSignUpInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_email setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_passwd setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_confirm setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    if(defaultUser && defaultUser.isSocialUser){
        [_edt_email setText:defaultUser.row_userEmail];
        [_edt_passwd setText:defaultUser.row_userPassword];
        [_edt_confirm setText:defaultUser.row_userPassword];
        
        [self onNext:nil];
    }

    
    [self addTextField:self.edt_email withCheckFunction:^BOOL(NSString* str){
        return [str isEmail];
    } withSuccessAction:^(){ [_edt_email checkComplete:^(){return YES;}];
    } withFailAction:^{ [_edt_email checkComplete:^(){return NO;}];
    } withDefaultAction:^{[_edt_email removeCheck];}];
    
    [self addTextField:self.edt_passwd withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        return YES;
    } withSuccessAction:^(){ [_edt_passwd checkComplete:^(){return YES;}];
    } withFailAction:^{ [_edt_passwd checkComplete:^(){return NO;}];
    } withDefaultAction:^{[_edt_passwd removeCheck];}];
    
    [self addTextField:self.edt_confirm withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        NSString * password = self.edt_passwd.text;
        if([str isEqualToString:password])
            return YES;
        return NO;
    } withSuccessAction:^(){ [self.edt_confirm checkComplete:^(){return YES;}];
    } withFailAction:^{ [self.edt_confirm checkComplete:^(){return NO;}];
    } withDefaultAction:^{[self.edt_confirm removeCheck];}];
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
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *) string
{
    if(textField == self.edt_passwd){
        NSString*  str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if(![str isEqualToString:[self.edt_confirm text]] || str.length == 0){
            [self.edt_confirm checkComplete:^(){return NO;}];
        }else{
            [self.edt_confirm checkComplete:^(){return YES;}];
        }
    }
    return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (IBAction)onNext:(id)sender {
    [self onDone:^{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers checkUserWithEmail:self.edt_email.text userType:0 sucessBlock:^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            DBUsers * banUser = returnItem;
            if(banUser.row_agree != 1){
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                if(defaultUser && defaultUser.profile_image){
                    ((DBUsers *)returnItem).profile_image = defaultUser.profile_image;
                    ((DBUsers *)returnItem).isSocialUser = YES;
                }
                
                [[StackMemory createInstance] setStack_signInItem:returnItem];
                //            [self performSegueWithIdentifier:@"gotoCustomerPhoto" sender:self];
                [self performSegueWithIdentifier:@"onGotoSignInPage" sender:self];
            }else{
                NSString * message = @"Email Already Exist";
                [Util showAlertTitle:self title:@"Sign Up" message:message finish:^{
                    [self.edt_email becomeFirstResponder];
                }];
            }
        } failBlock:^( NSError * error){
            [DBUsers creatBussinessItem:self.edt_email.text password:self.edt_passwd.text sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                if(defaultUser){
                    ((DBUsers*)returnItem).row_userName = defaultUser.row_userName;
                    ((DBUsers*)returnItem).profile_image = defaultUser.profile_image;
                    ((DBUsers *)returnItem).isSocialUser = YES;
                }
                
                [[StackMemory createInstance] setStack_signInItem:returnItem];
                [self performSegueWithIdentifier:@"onGotoSignInPage" sender:self];
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                NSString * message = @"Couldn't connect to the Server. Please check your network connection.";
                [Util showAlertTitle:self title:@"Sign Up" message:message];
            }];
        }];
    } withFailAction:^(NSString * errorMessage, UITextField * targetView){
        [Util showAlertTitle:self title:@"Sign Up" message:errorMessage finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [targetView becomeFirstResponder];
                });
                
            }
        }];
    }];
}

@end
