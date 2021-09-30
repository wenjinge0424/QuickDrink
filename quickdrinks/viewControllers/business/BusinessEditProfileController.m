//
//  BusinessEditProfileController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessEditProfileController.h"
#import "StackMemory.h"
#import "DBCong.h"
#import "Util.h"
#import "CustomComboBox.h"
#import "SPGooglePlacesAutocompleteViewController.h"

@interface BusinessEditProfileController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, CustomComboBox_SelectedItem, SPGooglePlacesAutocompleteViewControllerDelegate>
{
    int animationHeight;
    UIImage * m_userImage;
}

@property (nonatomic, retain) UIImagePickerController * picker;

@property (strong, nonatomic) IBOutlet UIImageView *m_profileImg;
@property (strong, nonatomic) IBOutlet UITextField *edt_businessName;
@property (strong, nonatomic) IBOutlet UITextField *edt_email;
@property (strong, nonatomic) IBOutlet UITextField *edt_password;
@property (strong, nonatomic) IBOutlet UITextField *edt_number;
@property (strong, nonatomic) IBOutlet UITextField *edt_location;
@property (strong, nonatomic) IBOutlet UITextField *edt_hours;
@property (strong, nonatomic) IBOutlet UITextField *edt_confirmPassword;
@property (strong, nonatomic) IBOutlet UITextView *edt_description;

@property (strong, nonatomic) IBOutlet CustomComboBox *dateCombo_from;
@property (strong, nonatomic) IBOutlet CustomComboBox *dateCombo_to;

@end

@implementation BusinessEditProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done1Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForContactNumber)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done1Button, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_number setInputAccessoryView:toolbar1];
    [self.edt_number setKeyboardType:UIKeyboardTypePhonePad];
    
    [self addTextField:self.edt_businessName withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>40 || str.length<3){
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "] invertedSet];
        if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.edt_businessName.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_businessName.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_businessName.superview color:[UIColor clearColor] width:0.f];}];
    
    [self addTextField:self.edt_password withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        return YES;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_password.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_password.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_password.superview color:[UIColor clearColor] width:1.f];}];
    
    [self addTextField:self.edt_confirmPassword withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        NSString * password = self.edt_password.text;
        if([str isEqualToString:password])
            return YES;
        return NO;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_confirmPassword.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_confirmPassword.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_confirmPassword.superview color:[UIColor clearColor] width:1.f];}];
    
    [self addTextField:self.edt_number withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>13 || str.length<3){
            return NO;
        }
        if(![Util checkPhoneNumber:str])
            return NO;
        return YES;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_number.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_number.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_number.superview color:[UIColor clearColor] width:1.f];}];
    
    [self addActionField:self.edt_description withCheckFunction:^BOOL(UITextView* item){
        if(self.edt_description.text.length > 300){
            return NO;
        }
        return YES;
    }withSuccessAction:^(){
        [Util setBorderView:self.edt_description.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_description.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_description.superview color:[UIColor clearColor] width:1.f];}];
    
    
    DBUsers * defaultUser1 = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:defaultUser1.row_id sucessBlock:^(DBUsers * item, NSError * error){
        [SVProgressHUD dismiss];
        [[StackMemory createInstance] setStack_signInItem:item];
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        [self.edt_businessName setText:defaultUser.row_userName];
        [self.edt_email setText:defaultUser.row_userEmail];
        [self.edt_number setText:defaultUser.row_userContactNumber];
        [self.edt_location setText:defaultUser.row_userLocation];
        [self.edt_hours setText:[NSString stringWithFormat:@"%@-%@", defaultUser.row_business_stTime, defaultUser.row_business_edTime]];
        [Util setImage:self.m_profileImg imgUrl:defaultUser.row_userPhoto];
        
        [self.m_profileImg.superview.layer setCornerRadius:self.m_profileImg.frame.size.width/2];
        
        [_edt_email setEnabled:NO];
        
        [_edt_password setText:defaultUser.row_userPassword];
        [_edt_confirmPassword setText:defaultUser.row_userPassword];
        
        [_edt_description setText:defaultUser.row_userDescription];
        
        
        self.dateCombo_from.lbl_title.text = defaultUser.row_business_stTime;
        self.dateCombo_from.delegate = self;
        self.dateCombo_from.type = 2;
        self.dateCombo_to.lbl_title.text = defaultUser.row_business_edTime;
        self.dateCombo_to.delegate = self;
        self.dateCombo_to.type = 2;
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that@property (strong, nonatomic) IBOutlet UITextField *edt_confirmPassword;@property (strong, nonatomic) IBOutlet UITextField *edt_hours;
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)getAddressFromAdrress:(NSString *)address withCompletationHandle:(void (^)(CLLocationCoordinate2D))completationHandler {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //Get the address through geoCoder
    [geoCoder geocodeAddressString:address   completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && !error) {
            //get the address from placemark
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            completationHandler(coordinate);
            
        } else {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = 0;
            coordinate.longitude = 0;
            completationHandler(coordinate);
        }
    }];
}
- (IBAction)onChangeProfileImage:(id)sender {
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * selectGallery = [UIAlertAction actionWithTitle:@"Select From Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:^(){}];
        [Util checkGalleryPermission:^(BOOL res){
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.picker animated:YES completion:nil];
        }failBlock:^(BOOL res){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util showAlertTitle:self title:@"" message:@"Gallery setting is Turned off." finish:^(void){}];
            });
            
        }];
    }];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:^(){}];
        
        [Util checkCameraPermission:^(BOOL res){
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.picker animated:YES completion:nil];
        } failBlock:^(BOOL res){
            dispatch_async(dispatch_get_main_queue(), ^{
                [Util showAlertTitle:self title:@"" message:@"Camera setting is Turned off." finish:^(void){}];
            });
        }];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:^(){}];
    }];
    [alert addAction:selectGallery];
    [alert addAction:takePhoto];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    m_userImage = chosenImage;
    [self.m_profileImg setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *profileImage = [Util getUploadingImageFromImage:m_userImage];
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [DBUsers addPhotoInfoTo:[[StackMemory createInstance] stack_signInItem] :imageData sucessBlock:^(id returnItem, NSError * error){
        [DBUsers getUserInfoFromUserId:defaultUser.row_id sucessBlock:^(DBUsers * newItem, NSError * eror){
            [SVProgressHUD dismiss];
            [[StackMemory createInstance] setStack_signInItem:newItem];
        
        } failBlock:^(NSError * eror){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }];
        
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
    }];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.edt_location){
        return NO;
    }
    [super textFieldShouldBeginEditing:textField];
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *) string
{
    if(textField == self.edt_number){
        if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"].invertedSet].location != NSNotFound){
            return NO;
        }
    }
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    
    [self onDone:^(){
        [(UIButton*)sender setUserInteractionEnabled:NO];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [self getAddressFromAdrress:self.edt_location.text withCompletationHandle:^(CLLocationCoordinate2D position){
            if(position.latitude == 0 && position.longitude == 0){
                [SVProgressHUD dismiss];
                [(UIButton*)sender setUserInteractionEnabled:YES];
                [Util showAlertTitle:self title:@"" message:@"Unknown address" finish:^(void){
                }];
            }else{
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                defaultUser.row_userName = self.edt_businessName.text;
                defaultUser.row_userEmail = self.edt_email.text;
                defaultUser.row_userPassword = self.edt_password.text;
                defaultUser.row_business_stTime = self.dateCombo_from.lbl_title.text;
                defaultUser.row_business_edTime = self.dateCombo_to.lbl_title.text;
                defaultUser.row_userLocation = self.edt_location.text;
                defaultUser.row_userContactNumber = self.edt_number.text;
                defaultUser.row_position_lng = position.longitude;
                defaultUser.row_position_lat = position.latitude;
                defaultUser.row_userDescription = self.edt_description.text;
                
                [DBUsers editBussinessUser:defaultUser sucessBlock:^(id returnItem, NSError * error){
                    
                    PFQuery *query = [PFUser query];
                    [query whereKey:PARSE_USER_EMAIL equalTo:defaultUser.row_userEmail];
                    
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error){
                            PFUser * currentUser = (PFUser*)object;
                            currentUser.password = defaultUser.row_userPassword;
                            [currentUser saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                                [PFUser logInWithUsernameInBackground:defaultUser.row_userEmail password:defaultUser.row_userPassword block:^(PFObject *object, NSError *error){
                                    [SVProgressHUD dismiss];
                                    if(!error){
                                        [Util showAlertTitle:self title:@"Drink" message:@"Your profile successfully changed."];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }else{
                                        [SVProgressHUD dismiss];
                                        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                                    }
                                }];
                            }];
                        }else{
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                        }
                    }];
                    
                } failBlock:^( NSError * error){
                    [(UIButton*)sender setUserInteractionEnabled:YES];
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                }];
            }
            
        }];
    } withFailAction:^(NSString * message, id targetView){
        [Util showAlertTitle:self title:@"Sign Up" message:message finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetView == self.edt_businessName){
                        [self.edt_businessName becomeFirstResponder];
                    }else if(targetView == self.edt_password){
                        [self.edt_password becomeFirstResponder];
                    }else if(targetView == self.edt_confirmPassword){
                        [self.edt_confirmPassword becomeFirstResponder];
                    }else if(targetView == self.edt_number){
                        [self.edt_number becomeFirstResponder];
                    }else if(targetView == self.edt_description){
                        [self.edt_description becomeFirstResponder];
                    }
                });
            }
        }];
    }];
}


- (IBAction)onGetLocation:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"App Permission Denied" message:@"Please go to settings and turn on location service for this app." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){
            }];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        SPGooglePlacesAutocompleteViewController * controller = [[SPGooglePlacesAutocompleteViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteViewController" bundle:nil];
        controller.delegate = self;
        [self.navigationController presentViewController:controller animated:YES completion:^{
            [controller.searchDisplayController.searchBar becomeFirstResponder];
        }];
    }
}
- (void)SPGooglePlacesCompleateWith:(NSString*) resultString :(CLLocationCoordinate2D) position
{
    self.edt_location.text = resultString;
    
}

- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
}
- (void)onHideKeyboardForContactNumber
{
    [self.edt_number resignFirstResponder];
}
@end
