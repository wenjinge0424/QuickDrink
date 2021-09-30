//
//  BusinessSignUpController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessSignUpController.h"
#import "CustomComboBox.h"
#import "UITextField+Complete.h"
#import "DBCong.h"
#import <MapKit/MapKit.h>
#import "Util.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "SPGooglePlacesAutocompleteViewController.h"

@interface BusinessSignUpController () <UITextFieldDelegate, UITextViewDelegate, CustomComboBox_SelectedItem, GMSAutocompleteViewControllerDelegate, SPGooglePlacesAutocompleteViewControllerDelegate>
{
    int animationHeight;
}

@property (strong, nonatomic) IBOutlet UITextField *edt_businessName;
@property (strong, nonatomic) IBOutlet UITextField *edt_businessLocation;
@property (strong, nonatomic) IBOutlet UITextField *edt_conctNumber;
@property (strong, nonatomic) IBOutlet UITextView *txt_businessDescription;
@property (strong, nonatomic) IBOutlet CustomComboBox *dateCombo_from;
@property (strong, nonatomic) IBOutlet CustomComboBox *dateCombo_to;
@end

@implementation BusinessSignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser * currentUser = [PFUser currentUser];
    if(currentUser)
        [PFUser logOut];
    animationHeight = 0;
    [self.edt_businessName setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_businessLocation setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_conctNumber setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done1Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForContactNumber)];
    UIBarButtonItem * done2Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForDescription)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done1Button, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_conctNumber setInputAccessoryView:toolbar1];
    [self.edt_conctNumber setKeyboardType:UIKeyboardTypePhonePad];
    
    UIToolbar * toolbar2 = [[UIToolbar alloc] init];
    [toolbar2 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar2 sizeToFit];
    NSArray * items2Array = [NSArray arrayWithObjects:flexButton,done2Button, nil];
    [toolbar2 setItems:items2Array];
    [self.txt_businessDescription setInputAccessoryView:toolbar2];
    
    
    self.dateCombo_from.lbl_title.text = @"FROM";
    self.dateCombo_from.delegate = self;
    self.dateCombo_from.type = 2;
    self.dateCombo_to.lbl_title.text = @"TO";
    self.dateCombo_to.delegate = self;
    self.dateCombo_to.type = 2;
    
    
    [self addTextField:self.edt_businessName withCheckFunction:^BOOL(NSString* str){
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(str.length == 0 || str.length>40 || str.length<3){
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "] invertedSet];
        if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){
        [self.edt_businessName checkComplete:^(){return YES;}];
         [Util setBorderView:self.edt_businessName.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_businessName checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_businessName.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_businessName removeCheck];}]; [Util setBorderView:self.edt_businessName.superview color:[UIColor clearColor] width:2.f];
    
    [self addActionField:self.dateCombo_from withCheckFunction:^BOOL(CustomComboBox* item){
        if([self.dateCombo_from.lbl_title.text isEqualToString:@"FROM"]){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.dateCombo_from color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [Util setBorderView:self.dateCombo_from color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[Util setBorderView:self.dateCombo_from color:[UIColor clearColor] width:0.f];}];
    
    [self addActionField:self.dateCombo_to withCheckFunction:^BOOL(CustomComboBox* item){
        if([self.dateCombo_to.lbl_title.text isEqualToString:@"TO"]){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.dateCombo_to color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [Util setBorderView:self.dateCombo_to color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[Util setBorderView:self.dateCombo_to color:[UIColor clearColor] width:0.f];}];
    
    [self addTextField:self.edt_businessLocation withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){ [self.edt_businessLocation checkComplete:^(){return YES;}];[Util setBorderView:self.edt_businessLocation.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_businessLocation checkComplete:^(){return NO;}];[Util setBorderView:self.edt_businessLocation.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_businessLocation removeCheck];[Util setBorderView:self.edt_businessLocation.superview color:[UIColor clearColor] width:2.f];}];
    
    [self addTextField:self.edt_conctNumber withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>13 || str.length<3){
            return NO;
        }
        if(![Util checkPhoneNumber:str])
            return NO;
        return YES;
    } withSuccessAction:^(){ [self.edt_conctNumber checkComplete:^(){return YES;}]; [Util setBorderView:self.edt_conctNumber.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [self.edt_conctNumber checkComplete:^(){return NO;}]; [Util setBorderView:self.edt_conctNumber.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[self.edt_conctNumber removeCheck]; [Util setBorderView:self.edt_conctNumber.superview color:[UIColor clearColor] width:2.f];}];
    
    [self addActionField:self.txt_businessDescription withCheckFunction:^BOOL(UITextView* item){
        if(self.txt_businessDescription.text.length > 300){
            return NO;
        }
//        if([self.txt_businessDescription.text isEqualToString:@"BUSINESS DESCRIPTION"]){
//            return NO;
//        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.txt_businessDescription.superview color:[UIColor clearColor] width:2.f];
    } withFailAction:^{ [Util setBorderView:self.txt_businessDescription.superview color:[UIColor redColor] width:2.f];
    } withDefaultAction:^{[Util setBorderView:self.txt_businessDescription.superview color:[UIColor clearColor] width:0.f];}];
    
    self.txt_businessDescription.superview.layer.cornerRadius = 5.f;
    self.dateCombo_from.layer.cornerRadius = 3.f;
    self.dateCombo_to.layer.cornerRadius = 3.f;
    self.edt_businessName.superview.layer.cornerRadius = 5.f;
    self.edt_businessLocation.superview.layer.cornerRadius = 5.f;
    self.edt_conctNumber.superview.layer.cornerRadius = 5.f;
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


- (void)getAddressFromAdrress:(NSString *)address withCompletationHandle:(void (^)(CLLocationCoordinate2D))completationHandler {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //Get the address through geoCoder
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [geoCoder geocodeAddressString:address   completionHandler:^(NSArray *placemarks, NSError *error) {
        [SVProgressHUD dismiss];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(textView == self.txt_businessDescription){
        if([self.txt_businessDescription.text isEqualToString:@"BUSINESS DESCRIPTION"]){
            self.txt_businessDescription.text = @"";
        }
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString*  str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(str.length > 300){
        [Util setBorderView:self.txt_businessDescription.superview color:[UIColor redColor] width:2.f];
//    }
//    else if([str isEqualToString:@"BUSINESS DESCRIPTION"]){
//        [Util setBorderView:self.txt_businessDescription.superview color:[UIColor redColor] width:2.f];
//    }else if([str isEqualToString:@""]){
//        [Util setBorderView:self.txt_businessDescription.superview color:[UIColor redColor] width:2.f];
    }else{
        [Util setBorderView:self.txt_businessDescription.superview color:[UIColor clearColor] width:2.f];
    }
    return YES;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.edt_businessLocation){
        return NO;
    }
    if(textField == self.edt_businessName){
        return YES;
    }
    [super textFieldShouldBeginEditing:textField];
    return YES;
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *) string
{
    if(textField == self.edt_conctNumber){
        if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"].invertedSet].location != NSNotFound){
            return NO;
        }
    }
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.txt_businessDescription.text isEqualToString:@""]){
        self.txt_businessDescription.text = @"BUSINESS DESCRIPTION";
    }
}
- (void)onHideKeyboardForContactNumber
{
    [self.edt_conctNumber resignFirstResponder];
}
- (void)onHideKeyboardForDescription
{
    [self.txt_businessDescription resignFirstResponder];
    if([self.txt_businessDescription.text isEqualToString:@""]){
        self.txt_businessDescription.text = @"BUSINESS DESCRIPTION";
    }
}

- (IBAction)onNext:(id)sender {
    
    [self onDone:^{
        [self getAddressFromAdrress:self.edt_businessLocation.text withCompletationHandle:^(CLLocationCoordinate2D position){
            if(position.latitude == 0 && position.longitude == 0){
                [Util showAlertTitle:self title:@"" message:@"Please check again your business address" finish:^(void){
                }];
            }else{
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                defaultUser.row_userName = self.edt_businessName.text;
                defaultUser.row_business_stTime = self.dateCombo_from.lbl_title.text;
                defaultUser.row_business_edTime = self.dateCombo_to.lbl_title.text;
                defaultUser.row_userLocation = self.edt_businessLocation.text;
                defaultUser.row_userContactNumber = self.edt_conctNumber.text;
                defaultUser.row_userDescription = self.txt_businessDescription.text;
                defaultUser.row_position_lng = position.longitude;
                defaultUser.row_position_lat = position.latitude;
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                [DBUsers addInfoToBussinessItem:defaultUser sucessBlock:^(id returnItem, NSError * error){
                    [SVProgressHUD dismiss];
                    [self performSegueWithIdentifier:@"showBusinessPicture" sender:self];
                }failBlock:^(NSError * error){
                    [SVProgressHUD dismiss];
                    if (![Util isConnectableInternet]){
                        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                        return;
                    }
                }];
            }
        }];

    } withFailAction:^(NSString * message, id targetView){
        [Util showAlertTitle:self title:@"Sign Up" message:message finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetView == self.edt_businessName){
                        [self.edt_businessName becomeFirstResponder];
                    }else if(targetView == self.dateCombo_from){
//                        [self.dateCombo_from onClickAction:nil];
                    }else if(targetView == self.dateCombo_to){
//                        [self.dateCombo_to onClickAction:nil];
                    }else if(targetView == self.edt_businessLocation){
//                        [self onGetLocation:nil];
                    }else if(targetView == self.edt_conctNumber){
                        [self.edt_conctNumber becomeFirstResponder];
                    }else if(targetView == self.txt_businessDescription){
                        [self.txt_businessDescription becomeFirstResponder];
                    }
                });
            }
        }];
    }];
}

- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    if(combo == self.dateCombo_from){
        if([self.dateCombo_from.lbl_title.text isEqualToString:@"FROM"]){
            [Util setBorderView:self.dateCombo_from color:[UIColor redColor] width:2.f];
            return;
        }
        //        int age = [item intValue];
        [Util setBorderView:self.dateCombo_from color:[UIColor clearColor] width:2.f];
    }else{
        if([self.dateCombo_to.lbl_title.text isEqualToString:@"TO"]){
            [Util setBorderView:self.dateCombo_to color:[UIColor redColor] width:2.f];
            return;
        }
        //        int selectedIndex = [self getIndexFromStringArrayforString:item];
        [Util setBorderView:self.dateCombo_to color:[UIColor clearColor] width:2.f];
    }
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
    _edt_businessLocation.text = resultString;
    [_edt_businessLocation checkComplete:^(){ return YES;}];
    [Util setBorderView:self.edt_businessLocation.superview color:[UIColor clearColor] width:2.f];

}
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    NSString *placeString = place.formattedAddress;
    _edt_businessLocation.text = placeString;
    [_edt_businessLocation checkComplete:^(){ return YES;}];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
    //    self.txtAddress.text = @"";
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    //    self.txtAddress.text = @"";
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
