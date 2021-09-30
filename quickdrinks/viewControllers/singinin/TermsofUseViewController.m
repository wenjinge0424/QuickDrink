//
//  TermsofUseViewController.m
//  quickdrinks
//
//  Created by mojado on 8/8/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "TermsofUseViewController.h"
#import "Util.h"
#import "SCLAlertView.h"
#import "DBCong.h"

@interface TermsofUseViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btn_checkBox;
@property (strong, nonatomic) IBOutlet UIWebView *m_webView;

@end

@implementation TermsofUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_webView.delegate = self;
    NSString * docName = @"3";
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:docName ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
    [self.m_webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    
    //    webView.scrollView.scrollEnabled = YES;
    self.m_webView.scrollView.bounces = NO;
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

- (IBAction)oncancel:(id)sender {
    NSString *msg = @"Are you sure you want to continue?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        
        ////////
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DBUsers removeUser:defaultUser];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert showError:@"Sign Up" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onAgree:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if(self.btn_checkBox.isSelected){
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        defaultUser.row_agree = 1;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers addAgreeInfoTo:defaultUser sucessBlock:^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            NSUserDefaults * defaultValue = [[NSUserDefaults alloc] init];
            [defaultValue setValue:defaultUser.row_userEmail forKey:@"SignIn_Email"];
            [defaultValue setValue:defaultUser.row_userPassword forKey:@"SignIn_Password"];
            [defaultValue setBool:NO forKey:@"LogOut"];
            [defaultValue synchronize];
            
            [self performSegueWithIdentifier:@"gotoCustommain" sender:self];
            
        }failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }];
        
    }else{
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Ok" actionBlock:^(void) {
        }];
        [alert showError:@"Sign Up" subTitle:@"Please read and agree to the Terms of use." closeButtonTitle:nil duration:0.0f];
    }
}
- (IBAction)onCheckBox:(id)sender {
    [self.btn_checkBox setSelected:!self.btn_checkBox.isSelected];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    return YES;
}

- (void) webViewDidFinished:(UIWebView *)webview
{
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
}
@end
