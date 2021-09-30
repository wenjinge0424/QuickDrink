//
//  CustomerProfileController.m
//  quickdrinks
//
//  Created by mojado on 6/16/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerProfileController.h"
#import "CustomComboBox.h"
#import "DBUsers.h"
#import "Util.h"
#import "StackMemory.h"

@interface CustomerProfileController ()<UITextFieldDelegate,CustomComboBox_SelectedItem, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray * m_ageArray;
    int animationHeight;
    
    int selected_age;
    NSString * selectedGender;
    
    UIImage * m_userImage;
}
@property (nonatomic, retain) UIImagePickerController * picker;

@property (strong, nonatomic) IBOutlet UIImageView *img_profile;
@property (strong, nonatomic) IBOutlet UITextField *edt_name;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_age;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_male;
@property (strong, nonatomic) IBOutlet UITextField *edt_password;
@property (strong, nonatomic) IBOutlet UITextField *edt_confirm;
@property (strong, nonatomic) IBOutlet UITextField *edt_email;

@end

@implementation CustomerProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        return;
    }

    
    
    m_ageArray = [NSMutableArray new];
    for(int i=18;i<100;i++){
        [m_ageArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    self.combo_age.lbl_title.text = @"Age";
    self.combo_age.m_containDatas = m_ageArray;
    self.combo_age.delegate = self;
    
    self.combo_male.lbl_title.text = @"Gender";
    self.combo_male.m_containDatas = [[NSMutableArray alloc] initWithObjects:@"Female",@"Male", nil];
    self.combo_male.delegate = self;
    
    
    [self addTextField:self.edt_name withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>40 || str.length<3){
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "] invertedSet];
        if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_name.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_name.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_name.superview color:[UIColor clearColor] width:0.f];}];
    
    [self addTextField:self.edt_password withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        return YES;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_password.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_password.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_password.superview color:[UIColor clearColor] width:1.f];}];
    
    [self addTextField:self.edt_confirm withCheckFunction:^BOOL(NSString* str){
        if (str.length < 6 || str.length>20) {
            return NO;
        }
        NSString * password = self.edt_password.text;
        if([str isEqualToString:password])
            return YES;
        return NO;
    } withSuccessAction:^(){
        [Util setBorderView:self.edt_confirm.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_confirm.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_confirm.superview color:[UIColor clearColor] width:1.f];}];
    
    
    DBUsers * defaultUser1 = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:defaultUser1.row_id sucessBlock:^(DBUsers * item, NSError * error){
        [SVProgressHUD dismiss];
        [[StackMemory createInstance] setStack_signInItem:item];
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        [Util setImage:self.img_profile imgUrl:defaultUser.row_userPhoto];
        [self.edt_name setText:defaultUser.row_userName];
        self.combo_age.lbl_title.text = [NSString stringWithFormat:@"%d", defaultUser.row_age];
        self.combo_male.lbl_title.text = defaultUser.row_gender;
        
        selected_age = defaultUser.row_age;
        selectedGender = defaultUser.row_gender;
        
        self.img_profile.layer.cornerRadius = self.img_profile.frame.size.width/2;
        
        [self.edt_email setEnabled:NO];
        [self.edt_email setText:defaultUser.row_userEmail];
        
        [_edt_password setText:defaultUser.row_userPassword];
        [_edt_confirm setText:defaultUser.row_userPassword];
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    m_userImage = chosenImage;
    [self.img_profile setImage:chosenImage];
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
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *) string
{
    if(textField == self.edt_name){
        if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "].invertedSet].location != NSNotFound){
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
    [self onDone:^{
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        
        defaultUser.row_userName = self.edt_name.text;
        defaultUser.row_age = selected_age;
        defaultUser.row_gender = selectedGender;
        if(self.edt_password.text.length >0){
            defaultUser.row_userPassword = self.edt_password.text;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers editCustomerUser:defaultUser sucessBlock:^(id returnItem, NSError * error){
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
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }];
    } withFailAction:^(NSString * message, id targetView){
        [Util showAlertTitle:self title:@"Profile" message:message finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetView == self.edt_name){
                        [self.edt_name becomeFirstResponder];
                    }else if(targetView == self.edt_password){
                        [self.edt_password becomeFirstResponder];
                    }else if(targetView == self.edt_confirm){
                        [self.edt_confirm becomeFirstResponder];
                    }
                });
            }
        }];
    }];
}
- (void) changePassword:(NSString*)email :(NSString*)password
{
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:email];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser * currentUser = (PFUser*)object;
            currentUser.password = password;
            [currentUser saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                [PFUser logInWithUsernameInBackground:email password:password block:^(PFObject *object, NSError *error){
            
                    
                }];
            }];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (int) getIndexFromStringArrayforString:(NSString*)str
{
    NSMutableArray *  array = self.combo_male.m_containDatas;
    for(NSString * subString in array){
        if([subString isEqualToString:str]){
            return (int)[array indexOfObject:subString];
        }
    }
    return  -1;
}
- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    if(combo == self.combo_age){
        selected_age = [item intValue];
    }else{
        selectedGender = item;
    }
}


@end
