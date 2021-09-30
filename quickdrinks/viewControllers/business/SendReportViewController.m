//
//  SendReportViewController.m
//  quickdrinks
//
//  Created by mojado on 6/27/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "SendReportViewController.h"
#import "Util.h"
#import "StackMemory.h"
#import "DBCong.h"

@interface SendReportViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *edt_email;
@property (strong, nonatomic) IBOutlet UITextView *txt_reason;

@end

@implementation SendReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        return;
    }
    
    // Do any additional setup after loading the view.
    [self.txt_reason setText:@"Please input description"];
    [self.txt_reason setTextColor:[UIColor lightGrayColor]];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFQuery *query = [PFQuery queryWithClassName:TBL_NAME_USERS];
    [query whereKey:TBL_USERS_USERTYPE equalTo:@"2"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [SVProgressHUD dismiss];
        if(!error){
            DBUsers * item = [DBUsers createItemFromDictionary:object atItem:nil];
            [self.edt_email setText:item.row_userEmail];
            [self.edt_email setEnabled:NO];
        }else{
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            return;
        }
    }];

    
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
- (IBAction)onSendReport:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if (self.edt_email.text.length == 0){
        [Util showAlertTitle:self title:@"Report" message:@"Please input email." finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
    }
    if (![self.edt_email.text isEmail]){
        [Util showAlertTitle:self title:@"Report" message:@"Please input valid email address." finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
        
    }
    if([self.txt_reason.text isEqualToString:@"Please input description"]){
        [Util showAlertTitle:self title:@"Report" message:@"Please input description." finish:^(void){
        }];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    DBReport * item = [DBReport new];
    item.row_send_userId = defaultUser.row_id;
    item.row_send_userName = defaultUser.row_userName;
    item.row_send_userEmail =defaultUser.row_userEmail;
    item.row_reason = self.txt_reason.text;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [DBReport addItem:item :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Report" message:@"Your report sent" finish:^(void){
            [DBNotification sendNotificationToAdmin:[NSString stringWithFormat:@"%@ sent report.", defaultUser.row_userName]];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failBlock:^(NSError* error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
    }];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Please input description"]){
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    [textView becomeFirstResponder];
}
- (void) textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0){
        [textView setText:@"Please input description"];
        [textView setTextColor:[UIColor lightGrayColor]];
    }
    [textView resignFirstResponder];
}

@end
