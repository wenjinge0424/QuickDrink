//
//  BusinessAddDrinkType4Controller.m
//  quickdrinks
//
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessAddDrinkType4Controller.h"
#import "CustomCheckerGroup.h"
#import "DBCong.h"
#import "Util.h"
#import "SCLAlertView.h"
#import "CommonAPI.h"

@interface BusinessAddDrinkType4Controller ()<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    int animationHeight;
    UIImage * m_selectedImage;
    
    DrinkItem * currentItem;
}
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;

@property (strong, nonatomic) IBOutlet CustomCheckerGroup *checkerGroup;
@property (strong, nonatomic) IBOutlet UITextField *edt_nameOfBeer;
@property (strong, nonatomic) IBOutlet UITextField *edt_price;
@property (strong, nonatomic) IBOutlet UITextView *edt_description;
@property (strong, nonatomic) IBOutlet UIImageView *img_itemImage;
@property (strong, nonatomic) IBOutlet UIImageView *img_addImage;

@property (nonatomic, retain) UIImagePickerController * picker;

@property (strong, nonatomic) IBOutlet UIButton *btn_check;
@property (strong, nonatomic) IBOutlet UIButton *btn_delete;
@property (strong, nonatomic) IBOutlet UIButton *btn_saveChange;
@property (strong, nonatomic) IBOutlet UIButton *btn_stockout;
@end

@implementation BusinessAddDrinkType4Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done1Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForContactNumber)];
    UIBarButtonItem * done2Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForDescription)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done1Button, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_price setInputAccessoryView:toolbar1];
    
    UIToolbar * toolbar2 = [[UIToolbar alloc] init];
    [toolbar2 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar2 sizeToFit];
    NSArray * items2Array = [NSArray arrayWithObjects:flexButton,done2Button, nil];
    [toolbar2 setItems:items2Array];
    [self.edt_description setInputAccessoryView:toolbar2];
    
    
    self.edt_nameOfBeer.delegate = self;
    self.edt_price.delegate = self;
    self.edt_description.delegate = self;
    

    [self.btn_check setHidden:NO];
    [self.btn_delete setHidden:YES];
    [self.btn_saveChange setHidden:YES];
    [self.btn_stockout setHidden:YES];
    
    if(self.isEditMode){
        [self.btn_check setHidden:YES];
        [self.btn_delete setHidden:NO];
        [self.btn_saveChange setHidden:NO];
        [self.btn_stockout setHidden:NO];
        [self.img_addImage setHidden:YES];
        [self setEditMode];
        
    }
    
    self.edt_price.delegate =  self;
    
    [self addTextField:self.edt_nameOfBeer withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>50 || str.length<1){
            return NO;
        }
//        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "] invertedSet];
//        if ([str rangeOfCharacterFromSet:set].location != NSNotFound){
//            return NO;
//        }
        NSCharacterSet * charSet = [NSCharacterSet whitespaceCharacterSet];
        NSString * trimmedString = [str stringByTrimmingCharactersInSet:charSet];
        if([trimmedString isEqualToString:@""]){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.edt_nameOfBeer.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_nameOfBeer.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_nameOfBeer.superview color:[UIColor clearColor] width:0.f];}];
    
    [self addTextField:self.edt_price withCheckFunction:^BOOL(NSString* str){
        if(str.length == 0 || str.length>8){
            return NO;
        }
        NSNumberFormatter * numberFormatter = [NSNumberFormatter new];
        numberFormatter.locale = [NSLocale currentLocale];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.usesGroupingSeparator = YES;
        NSNumber * number = [numberFormatter numberFromString:str];
        if(!number){
            return NO;
        }
        if([number floatValue] == 0){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.edt_price.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_price.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_price.superview color:[UIColor clearColor] width:0.f];}];
    
    [self addActionField:self.edt_description withCheckFunction:^BOOL(UITextView* item){
        NSLog(@"%@", item.text);
        if(item.text.length > 160){
            return NO;
        }
        return YES;
    } withSuccessAction:^(){[Util setBorderView:self.edt_description.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.edt_description.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.edt_description.superview color:[UIColor clearColor] width:0.f];}];
    
    [self addActionField:self.img_itemImage withCheckFunction:^BOOL(UITextView* item){
//        if(!self.img_itemImage.image)
//            return NO;
        return YES;
    }withSuccessAction:^(){[Util setBorderView:self.img_itemImage.superview color:[UIColor clearColor] width:1.f];
    } withFailAction:^{ [Util setBorderView:self.img_itemImage.superview color:[UIColor redColor] width:1.f];
    } withDefaultAction:^{[Util setBorderView:self.img_itemImage.superview color:[UIColor clearColor] width:0.f];}];
}
- (void) setEditMode
{
    currentItem = (DrinkItem*) self.editItm;
    [self.lbl_title setText:@"Edit a Drink"];
    [self.edt_nameOfBeer setText:currentItem.row_name];
    [self.edt_price setText:[NSString stringWithFormat:@"%.2f",currentItem.row_price]];
    [self.edt_description setText:currentItem.row_description];
    if(currentItem.row_img){
        [Util setImage:self.img_itemImage imgUrl:currentItem.row_img];
    }else{
        [self.img_addImage setHidden:NO];
    }
    
    if(currentItem.row_isTemporarily == 0){
        
    }else{
        [_btn_stockout setBackgroundImage:[UIImage imageNamed:@"btn_blue"] forState:UIControlStateNormal];
        [_btn_stockout setTitle:@"Make the drink available" forState:UIControlStateNormal];
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

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    animationHeight = 0;
    CGRect selfviewRect = [textField convertRect:textField.frame toView:self.view];
    if(self.view.frame.size.height -  selfviewRect.origin.y - selfviewRect.size.height < 230){
        animationHeight = 230 + selfviewRect.origin.y + selfviewRect.size.height - self.view.frame.size.height;
        [self gotoUpAnimation:animationHeight];
    }
    [super textFieldShouldBeginEditing:textField];
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.edt_price){
        if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"].invertedSet].location != NSNotFound){
            return NO;
        }
    }
    
    [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    return YES;
}
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * str = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(textView == self.edt_description){
        [CommonAPI textEditValidate:textView.superview :[CommonAPI checkDrinkDescription:str]];
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
    return YES;
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self gotoDownAnimation:animationHeight];
}
- (void)onHideKeyboardForContactNumber
{
    [self.edt_price resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
}
- (void)onHideKeyboardForDescription
{
    [self.edt_description resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
}
- (void) gotoUpAnimation:(int)height
{
    [UIView animateWithDuration:0.1 animations:^(){
        
        for(UIView * subview in self.view.subviews){
            if([subview isKindOfClass:[UITableView class]]){
                CGPoint offsetPoint = [(UITableView*)subview contentOffset];
                [(UITableView*)subview setContentOffset:CGPointMake(0, offsetPoint.y + height)];
            }
        }
    }];
}
- (void) gotoDownAnimation:(int)height
{
    [UIView animateWithDuration:0.1 animations:^(){
        
        for(UIView * subview in self.view.subviews){
            if([subview isKindOfClass:[UITableView class]]){
                CGPoint offsetPoint = [(UITableView*)subview contentOffset];
                [(UITableView*)subview setContentOffset:CGPointMake(0, offsetPoint.y - height)];
            }
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onOutStock:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int vlaue = 0;
    if(currentItem.row_isTemporarily == 0){
        vlaue = 1;
    }else{
        vlaue = 0;
    }
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DrinkItem setTemprarilyState:vlaue :currentItem sucessBlock:^(id value, NSError * error){
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        [SVProgressHUD dismiss];
    }];
}
- (IBAction)onDelete:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    NSString *msg = @"Are you sure you want to delete this drink?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DrinkItem deleteDrinkItem:currentItem sucessBlock:^(id val, NSError * error){
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        } failBlock:^(NSError * error){
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            [SVProgressHUD dismiss];
        }];
    }];
    [alert showError:@"Delete Drink" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onCheck:(id)sender {
    NSString * drinkName = _edt_nameOfBeer.text;
    NSCharacterSet * charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString * trimmedString = [drinkName stringByTrimmingCharactersInSet:charSet];
    int selectedIndex = [self.checkerGroup getSelectedIndex];
    NSNumberFormatter * numberFormatter = [NSNumberFormatter new];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    NSNumber * number = [numberFormatter numberFromString:self.edt_price.text];
    [self onDone:^{
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        if(!self.isEditMode){
            DrinkItem * item = [DrinkItem new];
            item.user_id = defaultUser.row_id;
            item.row_category_id = 5;
            item.row_subcategory_id = 0;
            item.row_selected_type = selectedIndex;
            item.row_selected_typeName = @"";
            item.row_name = trimmedString;
            item.row_price = [number floatValue];
            item.row_description = self.edt_description.text;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            /*[DrinkItem checkDrinkInfo:item sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                NSString * message = [NSString stringWithFormat:@"Drink name \"%@\" already exist in this category.", item.row_name];
                [Util setBorderView:self.edt_nameOfBeer.superview color:[UIColor redColor] width:1.f];
                [Util showAlertTitle:self title:@"Drink" message:message finish:^{
                    [self.edt_nameOfBeer becomeFirstResponder];
                }];
            } failBlock:^( NSError * error){*/
                [DrinkItem addDrinkInfo:item :item.user_id sucessBlock:^(id returnItem, NSError * error){
                    UIImage *profileImage = [Util getUploadingImageFromImage:m_selectedImage];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    if(imageData){
                        [DrinkItem addPhotoInfoTo:item :imageData sucessBlock:^(id returnItem, NSError * error){
                            [SVProgressHUD dismiss];
                            NSString * message = @"Add new drink success.";
                            [Util showAlertTitle:self title:@"Drink" message:message];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        } failBlock:^( NSError * error){
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                        }];
                    }else{
                        NSString * message = @"Add new drink success.";
                        [Util showAlertTitle:self title:@"Drink" message:message];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                } failBlock:^( NSError * error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                }];
           /* }];*/
        }else{
            currentItem.user_id = defaultUser.row_id;
            currentItem.row_category_id = 5;
            currentItem.row_subcategory_id = 0;
            currentItem.row_selected_type = selectedIndex;
            currentItem.row_name = trimmedString;
            currentItem.row_price = [number floatValue];
            currentItem.row_description = self.edt_description.text;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [DrinkItem editDrinkInfo:currentItem sucessBlock:^(id returnItem, NSError * error){
                if(m_selectedImage){
                    UIImage *profileImage = [Util getUploadingImageFromImage:m_selectedImage];
                    NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                    [DrinkItem addPhotoInfoTo:currentItem :imageData sucessBlock:^(id returnItem, NSError * error){
                        [SVProgressHUD dismiss];
                        NSString * message = @"Edit drink success.";
                        [Util showAlertTitle:self title:@"Drink" message:message finish:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } failBlock:^( NSError * error){
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                    }];
                }else{
                    [SVProgressHUD dismiss];
                    NSString * message = @"Edit drink success.";
                    [Util showAlertTitle:self title:@"Drink" message:message finish:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }];
        }

    } withFailAction:^(NSString * message, id targetView){
        [Util showAlertTitle:self title:@"Quick Drink" message:message finish:^{
            if(targetView){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(targetView == self.edt_nameOfBeer){
                        [self.edt_nameOfBeer becomeFirstResponder];
                    }else if(targetView == self.edt_price){
                        [self.edt_price becomeFirstResponder];
                    }else if(targetView == self.edt_description){
                        [self.edt_description becomeFirstResponder];
                    }else if(targetView == self.img_itemImage){
//                        [self onAddImage:nil];
                    }
                });
            }
        }];
    }];
}
- (IBAction)onAddImage:(id)sender {
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
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"Take a New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
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
    [self.img_addImage setHidden:YES];
    UIImage * chosenImage = info[UIImagePickerControllerEditedImage];
    m_selectedImage = chosenImage;
    [self.img_itemImage setImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [Util setBorderView:self.img_itemImage.superview color:[UIColor clearColor] width:1.f];
}

@end
