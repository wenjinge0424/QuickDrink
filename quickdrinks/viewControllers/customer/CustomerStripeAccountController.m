//
//  CustomerStripeAccountController.m
//  quickdrinks
//
//  Created by Techsviewer on 8/22/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "CustomerStripeAccountController.h"

#import "StackMemory.h"
#import "DBCong.h"
#import "Util.h"

@interface CustomerStripeAccountController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CustomerStripeAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
//    NSString * urlStr = [NSString stringWithFormat:@"https://stripe.quickdrinksapp.com/?email=%@&password=%@", defaultUser.row_userEmail, defaultUser.row_userPassword];
    NSString * urlStr = [NSString stringWithFormat:@"https://stripe.quickdrinksapp.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30]];
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
- (IBAction)onNext:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:defaultUser.row_id sucessBlock:^(DBUsers * item, NSError * error){
        [SVProgressHUD dismiss];
        if(item.row_accountId && item.row_accountId.length > 0){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [Util showAlertTitle:self title:@"" message:@"Please verify payment information" finish:^(void){
            }];
        }
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
        }];
    }];
}
@end
