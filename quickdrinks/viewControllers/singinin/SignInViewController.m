//
//  SignInViewController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "SignInViewController.h"
#import "DBCong.h"
#import "Util.h"
#import "SCLAlertView.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface SignInViewController () <UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate>
{
    BOOL isGoogleLogIn;
}
@property (strong, nonatomic) IBOutlet UITextField *edt_email;
@property (strong, nonatomic) IBOutlet UITextField *edt_password;

@property (weak, nonatomic) IBOutlet UIButton *btn_remember;
@end

@implementation SignInViewController
- (IBAction)onSelectRemenber:(id)sender {
    [self.btn_remember setSelected:!self.btn_remember.selected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isGoogleLogIn = NO;
    // Do any additional setup after loading the view.
    [self.edt_email setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_password setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    
    /*
     NSUserDefaults * defaultValue = [[NSUserDefaults alloc] init];
     [defaultValue setBool:YES forKey:@"LogOut"];
     [self.navigationController popToRootViewControllerAnimated:YES];
     */
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
    NSString * userEmail = [defaultValue valueForKey:@"SignIn_Email"];
    NSString * userPassword = [defaultValue valueForKey:@"SignIn_Password"];
    BOOL isSignOut = [defaultValue boolForKey:@"LogOut"];
    BOOL isRemember = [defaultValue boolForKey:@"isRemember"];
    self.btn_remember.selected = isRemember;
    
    if(!isSignOut){
        if(isRemember){
            if(userEmail && userPassword && userEmail.length > 0 && userPassword.length > 0){
                [_edt_email setText:userEmail];
                [_edt_password setText:userPassword];
                [self onClickLogin:nil];
                return;
            }
        }
    }else{
        self.btn_remember.selected = NO;
    }
    
    [_edt_email setText:@""];
    [_edt_password setText:@""];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
    BOOL isSignOut = [defaultValue boolForKey:@"LogOutFromFlow"];
    if(isSignOut){
        [_edt_email setText:@""];
        [_edt_password setText:@""];
         self.btn_remember.selected = NO;
        NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
        [defaultValue setBool:YES forKey:@"LogOut"];
        [defaultValue setBool:NO forKey:@"LogOutFromFlow"];
        [defaultValue synchronize];
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

- (IBAction)onClickLogin:(id)sender {
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    
    NSString *email = _edt_email.text;
    email = [Util trim:email];
    NSString *password = _edt_password.text;
    
    NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
    [defaultValue setValue:email forKey:@"SignIn_Email"];
    [defaultValue setValue:password forKey:@"SignIn_Password"];
    [defaultValue setBool:YES forKey:@"LogOut"];
    [defaultValue setBool:self.btn_remember.selected forKey:@"isRemember"];
    [defaultValue synchronize];
    
    
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Please enter your email address." finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Sign Up" message:@"Please input valid email address." finish:^(void) {
            [_edt_email becomeFirstResponder];
        }];
        return;
        
    }
    if (password.length == 0) {
        [Util showAlertTitle:self title:@"Login" message:@"Please input password" finish:^(void) {
            [_edt_password becomeFirstResponder];
        }];
        return;
    }
    
    [_edt_email resignFirstResponder];
    [_edt_password resignFirstResponder];
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers checkUserWithEmail:self.edt_email.text userType:5 sucessBlock:^(id returnItem, NSError * error){
        
        DBUsers * item = (DBUsers*)returnItem;
//        if([item.row_userPassword isEqualToString:self.edt_password.text]){
            [[StackMemory createInstance] setStack_signInItem:returnItem];
            if(item.row_ban == 1){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Sign In" message:@"Your account was banned." finish:^(void){}];
            }else if(item.row_agree != 1){
                [SVProgressHUD dismiss];
                if(isGoogleLogIn){
                    [self performSegueWithIdentifier:@"gotoSignUpPage" sender:self];
                } else {
                    [Util showAlertTitle:self title:@"Sign In" message:@"Your account not yet complete." finish:^(void){}];
                }
            }else{
                
                PFQuery *query = [PFUser query];
                [query whereKey:PARSE_USER_EMAIL equalTo:item.row_userEmail];
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if(!error){
                        PFUser *user = (PFUser *)object;
                        NSString *username = user.username;
                        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                            [SVProgressHUD dismiss];
                            if(!error){
                                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                                [[PFInstallation currentInstallation] saveEventually];
                                
                                NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
                                [defaultValue setValue:username forKey:@"SignIn_Email"];
                                [defaultValue setValue:password forKey:@"SignIn_Password"];
                                [defaultValue setBool:NO forKey:@"LogOut"];
                                [defaultValue synchronize];
                                
                                if(item.row_userType == 0){/// business
                                    [self performSegueWithIdentifier:@"gotoBusinessFromLogin" sender:self];
                                }else if(item.row_userType == 1){// custom
                                    [self performSegueWithIdentifier:@"gotoCustomFromLogin" sender:self];
                                }else if(item.row_userType == 2){//showAdminPage
                                    [self performSegueWithIdentifier:@"showAdminPage" sender:self];
                                }
                                
                            }else{
                                [Util showAlertTitle:self title:@"Sign In" message:error.localizedDescription finish:^(void){}];
                            }
                        }];
                    }else{
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                    }
                }];
           
            }
        
    } failBlock:^( NSError * error){
        [SVProgressHUD dismiss];
        [Util setLoginUserName:@"" password:@""];
        
        
        NSUserDefaults * defaultValue = [NSUserDefaults standardUserDefaults];
        [defaultValue setBool:YES forKey:@"LogOut"];
        [defaultValue synchronize];
        
        NSString *msg = @"Email entered is not registered. Create an account now?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Not Now" actionBlock:^(void) {
        }];
        [alert addButton:@"Sign Up" actionBlock:^(void) {
            [self onSignUp:self];
        }];
        [alert showError:@"SignUp" subTitle:msg closeButtonTitle:nil duration:0.0f];
    }];
}

- (IBAction)onSignUp:(id)sender {
    PFUser * currentUser = [PFUser currentUser];
    if(currentUser)
        [PFUser logOut];
    [self performSegueWithIdentifier:@"gotoSignUpPage" sender:self];
}

- (IBAction)onClickRegister:(id)sender {
}
- (IBAction)onSigninWithFacebook:(id)sender {
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
//         [SVProgressHUD dismiss];
         if (user != nil) {
             if (user[@"facebookid"] == nil) {
                 PFUser *puser = [PFUser user];
                 puser = user;
                 [self requestFacebook:puser];
             } else {
                 _edt_email.text = user.username;
                 _edt_password.text = user.password;
                 [self onClickLogin:nil];
             }
         } else {
             [Util showAlertTitle:self title:@"" message:@"Login Failed.Please try again."];
         }
     }];
}
////////////////////////////////////FACEBOOK SIGNIN/////////////////////////////
- (void)requestFacebook:(PFUser *)user
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,first_name,last_name,birthday,email" forKey:@"fields"];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                   parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        [SVProgressHUD dismiss];
        if (error == nil)
        {
            NSDictionary *userData = (NSDictionary *)result;
            [self processFacebook:user UserData:userData];
        }
        else
        {
            [Util setLoginUserName:@"" password:@""];
            [PFUser logOut];
            [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile."];
        }
    }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
{
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject) {
             user.username = userData[@"name"];
             user.password = [Util randomStringWithLength:20];
             user[PARSE_USER_FIRST_NAME] = userData[@"first_name"];
             user[PARSE_USER_LAST_NAME] = userData[@"last_name"];
             user[PARSE_USER_FACEBOOKID] = userData[@"id"];
             if (userData[@"email"]) {
                 user.email = userData[@"email"];
                 user.username = userData[@"name"];
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 user.email = [NSString stringWithFormat:@"%@@facebook.com",name];
                 user.username = userData[@"name"];
             }
             
             
             DBUsers * userItem = [DBUsers new];
             userItem.isSocialUser = YES;
             userItem.row_userPassword = user.password;
             
             if (userData[@"email"]) {
                 userItem.row_userEmail = userData[@"email"];
                 userItem.row_userName = userData[@"name"];
             } else {
                 NSString *name = [[userData[@"name"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 userItem.row_userEmail = [NSString stringWithFormat:@"%@@facebook.com",name];
                 userItem.row_userName = userData[@"name"];
             }
             UIImage *profileImage = [Util getUploadingImageFromImage:responseObject];
             NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
             UIImage * newImage = [UIImage imageWithData:imageData];
             userItem.profile_image = newImage;
             [[StackMemory createInstance] setStack_signInItem:userItem];
             
             [self getPasswordFromEmail:userItem.row_userEmail];
         } else {
             [Util setLoginUserName:@"" password:@""];
             [PFUser logOut];
             [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
         }
         [SVProgressHUD dismiss];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [Util setLoginUserName:@"" password:@""];
         [PFUser logOut];
         [SVProgressHUD dismiss];
         [Util showAlertTitle:self title:@"Oops!" message:@"Failed to fetch Facebook profile picture."];
     }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (IBAction)onSigninWithGoogle:(id)sender {
    isGoogleLogIn = YES;
    [[GIDSignIn sharedInstance] signIn];
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
}
- (IBAction)onForgotPassword:(id)sender {
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//////////////////////////GOOGLE SIGIN//////////////////////////
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    [SVProgressHUD dismiss];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [SVProgressHUD dismiss];
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [SVProgressHUD dismiss];
    if (error) {
        [Util showAlertTitle:self title:@"Oops!" message:@"Login Failed.Please try again."];
    } else {
        DBUsers * userItem = [DBUsers new];
        userItem.isSocialUser = YES;
        userItem.row_userEmail = user.profile.email;
        userItem.row_userName = [NSString stringWithFormat:@"%@ %@", user.profile.givenName, user.profile.familyName];
        if (user.profile.hasImage) {
            NSURL *imageURL = [user.profile imageURLWithDimension:50*50];
            UIImage *im = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            UIImage *profileImage = [Util getUploadingImageFromImage:im];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            UIImage * newImage = [UIImage imageWithData:imageData];
            userItem.profile_image = newImage;
        }
        
        
        [[StackMemory createInstance] setStack_signInItem:userItem];
        
        [self getPasswordFromEmail:user.profile.email];
        
    }
}

- (void) getPasswordFromEmail:(NSString*)email
{
    PFQuery * query = [PFUser query];
    [query whereKey:@"username" equalTo:email];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject* object, NSError * error){
        [SVProgressHUD dismiss];
        if(error){/// no signed
            /////////
            [self onSignUp:nil];
        }else{
            _edt_email.text = email;
            
            [DBUsers checkUserWithEmail:self.edt_email.text userType:0 sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                DBUsers * user = (DBUsers*)returnItem;
                _edt_password.text = user.row_userPassword;
                [self onClickLogin:nil];
            } failBlock:^(NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){}];
            }];
            
            
        }
    }];
}
@end
