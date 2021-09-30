//
//  OwnerRportDetailViewController.m
//  quickdrinks
//
//  Created by mojado on 6/24/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerRportDetailViewController.h"
#import "Util.h"

@interface OwnerRportDetailViewController ()
@property (strong, nonatomic) IBOutlet UITextView *txt_reportReason;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;

@end

@implementation OwnerRportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.lbl_title setText:self.m_data.row_send_userName];
    [self.txt_reportReason setText:[NSString stringWithFormat:@"%@ \n\n\n Reported by %@", self.m_data.row_reason, self.m_data.row_send_userEmail]];
    [self.txt_reportReason setEditable:NO];
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
- (IBAction)onBan:(id)sender {
    DBUsers * user = [DBUsers new];
    user.row_id = self.m_data.row_send_userId;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers setUserBan:user :^(id val, NSError * error){
        [DBReport deleteReport:self.m_data :^(id val, NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"User setted ban" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
            }];
        }];
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
        }];
    }];
}
- (IBAction)onDelete:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBReport deleteReport:self.m_data :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Report Deleted" finish:^(void){
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
        }];
    }];
}

@end
