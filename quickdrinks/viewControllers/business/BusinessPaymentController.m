//
//  BusinessPaymentController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessPaymentController.h"
#import "DBCong.h"
#import "Util.h"

@interface BusinessPaymentController ()<UITextFieldDelegate>
{
    DBPaymentInfos * m_info;
}
@property (strong, nonatomic) IBOutlet UITextField *edt_cardNum;
@property (strong, nonatomic) IBOutlet UITextField *edt_expire;
@property (strong, nonatomic) IBOutlet UITextField *edt_cvv;

@end

@implementation BusinessPaymentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    // Do any additional setup after loading the view.
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBPaymentInfos checkUserPaymentInfo:defaultUser sucessBlock:^(id returnItem, NSError * error){
        [SVProgressHUD dismiss];
        m_info = returnItem;
        
        [self.edt_cardNum setText:m_info.row_credit_num];
        [self.edt_expire setText:m_info.row_credit_expiry];
        [self.edt_cvv setText:m_info.row_credit_cvv];
        
    } failBlock:^( NSError * error){
        [SVProgressHUD dismiss];
        m_info = nil;
    }];
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
    if(self.edt_cardNum.text.length == 0 || self.edt_expire.text.length == 0 || self.edt_cvv.text.length == 0){
        [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again" finish:^(void){}];
        return;
    }else if(self.edt_cardNum.text.length != 19){
         [Util showAlertTitle:self title:@"" message:@"Please input valid card number." finish:^(void){}];
        return;
    }else if(self.edt_expire.text.length != 5){
        [Util showAlertTitle:self title:@"" message:@"Please input valid card expire." finish:^(void){}];
        return;
    }else if(self.edt_cvv.text.length < 3){
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
        if(m_info){
            m_info.row_credit_num = self.edt_cardNum.text;
            m_info.row_credit_expiry = self.edt_expire.text;
            m_info.row_credit_cvv = self.edt_cvv.text;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [DBPaymentInfos editUserPaymentInfo:m_info sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                if(defaultUser.row_accountId.length == 0){
                    [self performSegueWithIdentifier:@"showWebView" sender:self];
                }else{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }];
        }else{
            m_info = [DBPaymentInfos new];
            DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
            m_info.row_credit_num = self.edt_cardNum.text;
            m_info.row_credit_expiry = self.edt_expire.text;
            m_info.row_credit_cvv = self.edt_cvv.text;
            m_info.row_credit_userId = defaultUser.row_id;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [DBPaymentInfos addUserPaymentInfo:m_info sucessBlock:^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
                if(defaultUser.row_accountId.length == 0){
                    [self performSegueWithIdentifier:@"showWebView" sender:self];
                }else{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }];
        }
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
    if(textField == self.edt_cardNum){
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
