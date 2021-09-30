//
//  OwnerBusinessProfileController.m
//  quickdrinks
//
//  Created by mojado on 6/24/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerBusinessProfileController.h"
#import "Util.h"

@interface OwnerBusinessProfileController ()

@property (strong, nonatomic) IBOutlet UIImageView *img_user;
@property (strong, nonatomic) IBOutlet UITextField *lbl_name;
@property (strong, nonatomic) IBOutlet UITextField *lbl_email;
@property (strong, nonatomic) IBOutlet UITextField *lbl_location;
@property (strong, nonatomic) IBOutlet UITextField *lbl_contactNum;
@property (strong, nonatomic) IBOutlet UITextField *lbl_hours;
@end

@implementation OwnerBusinessProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setImage:self.img_user imgUrl:self.m_currentUser.row_userPhoto];
    [self.lbl_name setText:self.m_currentUser.row_userName];
    [self.lbl_email setText:self.m_currentUser.row_userEmail];
    [self.lbl_location setText:self.m_currentUser.row_userLocation];
    [self.lbl_contactNum setText:self.m_currentUser.row_userContactNumber];
    [self.lbl_hours setText:[NSString stringWithFormat:@"%@-%@", self.m_currentUser.row_business_stTime, self.m_currentUser.row_business_edTime]];
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
- (IBAction)onBand:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers setUserBan:self.m_currentUser :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        [self onBack:nil];
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
    }];
}
@end
