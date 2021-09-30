//
//  CustomerRegistPaymentController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerRegistPaymentController.h"
#import "DBCong.h"
#import "Util.h"

@interface CustomerRegistPaymentController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *edt_cardnum;
@property (strong, nonatomic) IBOutlet UITextField *edt_expire;
@property (strong, nonatomic) IBOutlet UITextField *edt_cvv;

@end

@implementation CustomerRegistPaymentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.edt_cardnum setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_expire setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.edt_cvv setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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
    if(self.edt_cardnum.text.length == 0 || self.edt_expire.text.length == 0 || self.edt_cvv.text.length == 0){
        [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again" finish:^(void){}];
        return;
    }else if(self.edt_cardnum.text.length != 19){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card number." finish:^(void){}];
        return;
    }else if(self.edt_expire.text.length != 5){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card expire." finish:^(void){}];
        return;
    }else if(self.edt_cvv.text.length < 3){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card cvv." finish:^(void){}];
        return;
    }else if(self.edt_cvv.text.length > 4){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card cvv." finish:^(void){}];
        return;
    }
    NSString * cvvStr = self.edt_expire.text;
    NSArray * arrayStr = [cvvStr componentsSeparatedByString:@"/"];
    BOOL isValideCVV = NO;
    if(arrayStr.count >=2 ){
        int month = [[arrayStr firstObject] intValue];
        int year  = [[arrayStr lastObject] intValue];
        if(month <= 12){
            if(year > 16){
                isValideCVV = YES;
            }
        }
    }
    
    if(!isValideCVV){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card expire." finish:^(void){}];
    }else{
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        DBPaymentInfos * item = [DBPaymentInfos new];
        item.row_credit_userId = defaultUser.row_id;
        item.row_credit_num = self.edt_cardnum.text;
        item.row_credit_expiry = self.edt_expire.text;
        item.row_credit_cvv = self.edt_cvv.text;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBPaymentInfos checkUserPaymentInfo:defaultUser sucessBlock:^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:@"gotoTermsAnduse" sender:self];
        } failBlock:^( NSError * error){
            [DBPaymentInfos addUserPaymentInfo:item sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                [self performSegueWithIdentifier:@"gotoTermsAnduse" sender:self];
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }];
        }];
    }
}
- (NSMutableString *) filteredPhoneStringFromStringWithFilter:(NSString * )string :(NSString *)filter
{
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([filter length])];
    BOOL done = NO;
    
    while(onFilter < [filter length] && !done)
    {
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if(originalChar=='\0')
                {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                if(isdigit(originalChar))
                {
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                }
                else
                {
                    onOriginal++;
                }
                break;
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if(originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [NSString stringWithUTF8String:outputString];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.edt_cardnum){
        NSString * filter = @"#### #### #### ####";
        NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if(range.length == 1 && // Only do for single deletes
           string.length < range.length &&
           [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
        {
            // Something was deleted.  Delete past the previous number
            NSInteger location = changedString.length-1;
            if(location > 0)
            {
                for(; location > 0; location--)
                {
                    if(isdigit([changedString characterAtIndex:location]))
                    {
                        break;
                    }
                }
                changedString = [changedString substringToIndex:location];
            }
        }
        
        textField.text = [self filteredPhoneStringFromStringWithFilter:changedString :filter];
        
        return NO;
    }
    if(textField == self.edt_expire){
        NSString * filter = @"##/##";
        NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if(range.length == 1 && // Only do for single deletes
           string.length < range.length &&
           [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
        {
            // Something was deleted.  Delete past the previous number
            NSInteger location = changedString.length-1;
            if(location > 0)
            {
                for(; location > 0; location--)
                {
                    if(isdigit([changedString characterAtIndex:location]))
                    {
                        break;
                    }
                }
                changedString = [changedString substringToIndex:location];
            }
        }
        
        textField.text = [self filteredPhoneStringFromStringWithFilter:changedString :filter];
        
        return NO;
    }
    if(textField == self.edt_cvv){
        NSString * filter = @"####";
        NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if(range.length == 1 && // Only do for single deletes
           string.length < range.length &&
           [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound)
        {
            // Something was deleted.  Delete past the previous number
            NSInteger location = changedString.length-1;
            if(location > 0)
            {
                for(; location > 0; location--)
                {
                    if(isdigit([changedString characterAtIndex:location]))
                    {
                        break;
                    }
                }
                changedString = [changedString substringToIndex:location];
            }
        }
        
        textField.text = [self filteredPhoneStringFromStringWithFilter:changedString :filter];
        
        return NO;
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
