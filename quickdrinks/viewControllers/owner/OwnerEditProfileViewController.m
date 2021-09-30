//
//  OwnerEditProfileViewController.m
//  quickdrinks
//
//  Created by mojado on 6/24/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerEditProfileViewController.h"
#import "DBCong.h"
#import "StackMemory.h"
#import "OwnerViewController.h"
#import "Util.h"

@interface OwnerEditProfileViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *edt_password;
@property (strong, nonatomic) IBOutlet UITextField *edt_confirm;
@property (strong, nonatomic) IBOutlet UITextField *edt_ownerEmail;
@end

@implementation OwnerEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [self.edt_ownerEmail setText:defaultUser.row_userEmail];
    [self.edt_ownerEmail setEnabled:NO];
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
    UIViewController * gotoCtr = nil;
    for(UIViewController * contrl in self.navigationController.viewControllers){
        if([contrl isKindOfClass:[OwnerViewController class]]){
            gotoCtr = contrl;
        }
    }
    
    [self.navigationController popToViewController:gotoCtr animated:YES];
}
- (IBAction)onSaveChange:(id)sender {
    if(self.edt_password.text.length == 0 || ![self.edt_password.text isEqualToString:self.edt_confirm.text]){
        [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){}];
    }else{
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers changePassword:defaultUser :self.edt_password.text :^(id item, NSError * error){
            [SVProgressHUD dismiss];
            [self onBack:nil];
        } failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error." finish:^(void){}];
        }];
    }
}
@end
