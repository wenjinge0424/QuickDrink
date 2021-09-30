//
//  PaymentVerifiationController.m
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "PaymentVerifiationController.h"
#import "StackMemory.h"
#import "DBCong.h"
#import "Util.h"

@interface PaymentVerifiationController ()

@property (strong, nonatomic) IBOutlet UIWebView *m_webView;
@end

@implementation PaymentVerifiationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    NSString * urlStr = [NSString stringWithFormat:@"https://stripe.quickdrinksapp.com/?email=%@&password=%@", defaultUser.row_userEmail, defaultUser.row_userPassword];
    [self.m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30]];
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
- (IBAction)onDone:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:defaultUser.row_id sucessBlock:^(DBUsers * item, NSError * error){
        [SVProgressHUD dismiss];
        [[StackMemory createInstance] setStack_signInItem:item];
        
        [Util showAlertTitle:self title:@"Payment Info" message:@"Your payment information successfully verified." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
    }];
    
   
}

@end
