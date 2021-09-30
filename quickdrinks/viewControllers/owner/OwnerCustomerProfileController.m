//
//  OwnerCustomerProfileController.m
//  quickdrinks
//
//  Created by mojado on 6/24/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerCustomerProfileController.h"
#import "Util.h"

@interface OwnerCustomerProfileController ()
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet UIImageView *img_user;
@property (strong, nonatomic) IBOutlet UITextField *lbl_name;
@property (strong, nonatomic) IBOutlet UILabel *lbl_age;
@property (strong, nonatomic) IBOutlet UILabel *lbl_gender;

@end

@implementation OwnerCustomerProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setImage:self.img_user imgUrl:self.m_currentUser.row_userPhoto];
    [self.lbl_title setText:self.m_currentUser.row_userName];
    [self.lbl_name setText:self.m_currentUser.row_userName];
    [self.lbl_age setText:[NSString stringWithFormat:@"%d", self.m_currentUser.row_age]];
    //@"Female",@"Male"
    if(self.m_currentUser.row_gender == 0){
        [self.lbl_gender setText:@"Female"];
    }else{
        [self.lbl_gender setText:@"Male"];
    }
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
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers setUserBan:self.m_currentUser :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        [self onBack:nil];
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
    }];
}
@end
