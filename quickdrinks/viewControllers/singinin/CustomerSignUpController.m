//
//  CustomerSignUpController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerSignUpController.h"
#import "CustomComboBox.h"
#import "DBCong.h"
#import "Util.h"
#import "UITextField+Complete.h"

@interface CustomerSignUpController ()<UITextFieldDelegate,CustomComboBox_SelectedItem>
{
    NSMutableArray * m_ageArray;
}
@property (strong, nonatomic) IBOutlet UITextField *edt_name;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_age;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_male;
@property (strong, nonatomic) IBOutlet UITextField *edt_email;
@property (strong, nonatomic) IBOutlet UITextField *edt_password;
@property (strong, nonatomic) IBOutlet UITextField *edt_confirm;

@end

@implementation CustomerSignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser * currentUser = [PFUser currentUser];
    if(currentUser)
        [PFUser logOut];
    
    // Do any additional setup after loading the view.
    [self.edt_name setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_email setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_password setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_confirm setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    m_ageArray = [NSMutableArray new];
    for(int i=18;i<100;i++){
        [m_ageArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    self.combo_age.lbl_title.text = @"Age";
    self.combo_age.m_containDatas = m_ageArray;
    self.combo_age.delegate = self;
    
    self.combo_male.lbl_title.text = @"Gender";
    self.combo_male.m_containDatas = [[NSMutableArray alloc] initWithObjects:@"Female",@"Male", nil];
    self.combo_male.delegate = self;
    
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    if(defaultUser && defaultUser.isSocialUser){
        [_edt_email setText:defaultUser.row_userEmail];
        [_edt_name setText:defaultUser.row_userName];
    }
    
    [self addTextField:self.edt_name withCheckFunction:^BOOL(NSString* str){
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(str.length == 0 || str.length>40 || str.length<3){
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "] invertedSet];
        if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){ [self.edt_name checkComplete:^(){return YES;}];  [Util setBorderView:self.edt_name.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_name checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_name.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_name removeCheck]; [Util setBorderView:self.edt_name.superview color:[UIColor clearColor] width:2.f];}];
    
    [self addActionField:self.combo_age withCheckFunction:^BOOL(CustomComboBox* item){
        if([self.combo_age.lbl_title.text isEqualToString:@"Age"]){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.combo_age color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [Util setBorderView:self.combo_age color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[Util setBorderView:self.combo_age color:[UIColor clearColor] width:0.f];}];
    
//    [self addActionField:self.combo_male withCheckFunction:^BOOL(CustomComboBox* item){
//        if([self.combo_male.lbl_title.text isEqualToString:@"Gender"]){
//            return NO;
//        }
//        return YES;
//    } withSuccessAction:^(){[Util setBorderView:self.combo_male color:[UIColor clearColor] width:2.f];
//    } withFailAction:^{ [Util setBorderView:self.combo_male color:[UIColor redColor] width:2.f];
//    } withDefaultAction:^{[Util setBorderView:self.combo_male color:[UIColor clearColor] width:0.f];}];
    
    [self addTextField:self.edt_email withCheckFunction:^BOOL(NSString* str){
        return [str isEmail];
    } withSuccessAction:^(){ [_edt_email checkComplete:^(){return YES;}];  [Util setBorderView:self.edt_email.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [_edt_email checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_email.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[_edt_email removeCheck]; [Util setBorderView:self.edt_email.superview color:[UIColor clearColor] width:2.f];}];
    
    [self addTextField:self.edt_password withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        return YES;
    } withSuccessAction:^(){ [self.edt_password checkComplete:^(){return YES;}]; [Util setBorderView:self.edt_password.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_password checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_password.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_password removeCheck]; [Util setBorderView:self.edt_password.superview color:[UIColor redColor] width:2.f];}];
    
    [self addTextField:self.edt_confirm withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        NSString * password = self.edt_password.text;
        if([str isEqualToString:password])
            return YES;
        return NO;
    } withSuccessAction:^(){ [self.edt_confirm checkComplete:^(){return YES;}]; [Util setBorderView:self.edt_confirm.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_confirm checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_confirm.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_confirm removeCheck]; [Util setBorderView:self.edt_confirm.superview color:[UIColor clearColor] width:2.f];}];
    
    self.combo_age.layer.cornerRadius = 3.f;
    self.combo_male.layer.cornerRadius = 3.f;
    self.edt_name.superview.layer.cornerRadius = 5.f;
    self.edt_email.superview.layer.cornerRadius = 5.f;
    self.edt_password.superview.layer.cornerRadius = 5.f;
    self.edt_confirm.superview.layer.cornerRadius = 5.f;
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
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *) string
{
    if(textField == self.edt_name){
        if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "].invertedSet].location != NSNotFound){
            return NO;
        }
    }
    if(textField == self.edt_password){
        NSString*  str = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if(![str isEqualToString:[self.edt_confirm text]]){
            [self.edt_confirm checkComplete:^(){return NO;}];
        }else{
            [self.edt_confirm checkComplete:^(){return YES;}];
        }
    }
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    
    [self onDone:^{
        DBUsers * item = [DBUsers new];
        item.row_userType = 1;
        item.row_userName = self.edt_name.text;
        item.row_userEmail = self.edt_email.text;
        item.row_userPassword = self.edt_password.text;
        item.row_age = [self.combo_age.lbl_title.text intValue];
        if(![self.combo_male.lbl_title.text isEqualToString:@"Gender"]){
            item.row_gender = self.combo_male.lbl_title.text;
        }
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
                [self performSegueWithIdentifier:@"gotoCustomerPhoto" sender:self];
            }else{
                
                NSString * message = @"Email Already Exist";
                [Util showAlertTitle:self title:@"Sign Up" message:message];
                [self.edt_email becomeFirstResponder];
            }
        } failBlock:^( NSError * error){
            [DBUsers creatCustomerItem:item sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                if(defaultUser && defaultUser.profile_image){
                    ((DBUsers *)returnItem).profile_image = defaultUser.profile_image;
                    ((DBUsers *)returnItem).isSocialUser = YES;
                }
                
                [[StackMemory createInstance] setStack_signInItem:returnItem];
                [self performSegueWithIdentifier:@"gotoCustomerPhoto" sender:self];
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }];
        }];
    } withFailAction:^(NSString * message, id targetView){
        [Util showAlertTitle:self title:@"Sign Up" message:message finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetView == self.edt_name){
                        [self.edt_name becomeFirstResponder];
                    }else if(targetView == self.combo_age){
//                        [self.combo_age onClickAction:nil];
                    }else if(targetView == self.combo_male){
//                        [self.combo_male onClickAction:nil];
                    }else if(targetView == self.edt_email){
                        [self.edt_email becomeFirstResponder];
                    }else if(targetView == self.edt_password){
                        [self.edt_password becomeFirstResponder];
                    }else if(targetView == self.edt_confirm){
                        [self.edt_confirm becomeFirstResponder];
                    }
                });
            }
        }];
    }];
}

//- (int) getIndexFromStringArrayforString:(NSString*)str
//{
//    NSMutableArray *  array = self.combo_male.m_containDatas;
//    for(NSString * subString in array){
//        if([subString isEqualToString:str]){
//            return (int)[array indexOfObject:subString];
//        }
//    }
//    return  -1;
//}
- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    if(combo == self.combo_age){
        if([self.combo_age.lbl_title.text isEqualToString:@"Age"]){
            [Util setBorderView:self.combo_male color:[UIColor redColor] width:2.f];
            return;
        }
//        int age = [item intValue];
        [Util setBorderView:self.combo_age color:[UIColor clearColor] width:2.f];
    }else{
//        if([self.combo_male.lbl_title.text isEqualToString:@"Gender"]){
//            [Util setBorderView:self.combo_male color:[UIColor redColor] width:2.f];
//            return;
//        }
//        int selectedIndex = [self getIndexFromStringArrayforString:item];
        [Util setBorderView:self.combo_male color:[UIColor clearColor] width:2.f];
    }
}

@end
