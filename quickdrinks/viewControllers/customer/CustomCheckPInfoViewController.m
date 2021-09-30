//
//  CustomCheckPInfoViewController.m
//  quickdrinks
//
//  Created by developer on 4/3/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "CustomCheckPInfoViewController.h"
#import "DBCong.h"
#import "Util.h"
#import "StripeRest.h"


@interface CustomCheckPInfoViewController ()<UITextFieldDelegate>
{
    DBPaymentInfos * m_info;
}
@property (strong, nonatomic) IBOutlet UITextField *edt_cardNum;
@property (strong, nonatomic) IBOutlet UITextField *edt_expire;
@property (strong, nonatomic) IBOutlet UITextField *edt_cvv;
@end

@implementation CustomCheckPInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


- (void) saveOrderItems:(int)index :(NSMutableArray*)array
{
    if(index >= array.count){
        /// complete
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Payment succeed." finish:^(void){}];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        PFObject * orderItem = [array objectAtIndex:index];
        [orderItem saveInBackgroundWithBlock:^(BOOL success, NSError * error){
            int newindex = index + 1;
            [self saveOrderItems:newindex :array];
        }];
    }
}

- (IBAction)onPayment:(id)sender
{
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
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        DBUsers * m_sender = [[StackMemory createInstance] stack_signInItem];
        
        float totalPrice = 0;
        for(PFObject * orderItem in self.saveData){
            float price = [orderItem[@"total_price"] floatValue];
            totalPrice += price;
        }
        
        [self saveOrderItems:0 :self.saveData];
        
        
        //+ (void) getUserInfoFromUserId:(NSString*)userId sucessBlock:(void (^)(id returnItem, NSError * error))sucessblock failBlock:(void (^)(NSError * error))failblock;
        /**/
 /*       [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getUserInfoFromUserId:self.saveData[@"owner_id"] sucessBlock:^(DBUsers * m_owner, NSError * error){
            if(m_owner.row_accountId.length  == 0){
                [Util showAlertTitle:self title:@"" message:@"Owner account not verified." finish:^(void){
                    [SVProgressHUD dismiss];
                }];
            }else{
                NSArray *paths = [self.edt_expire.text pathComponents];
                
                NSString *description = [NSString stringWithFormat:@"MAIN - '%@' paid",m_sender.row_userName];
                NSString *amount = [NSString stringWithFormat:@"%d", (int)([self.saveData[@"total_price"] floatValue] * 100)];
                NSString *accountId = m_owner.row_accountId;
                
                NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                 @"iOS", @"DeviceType",
                                                 nil];
                NSMutableDictionary *chargeDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                   amount, @"amount",
                                                   @"usd", @"currency",
                                                   @"false", @"capture",
                                                   accountId, @"destination",
                                                   description, @"description",
                                                   metadata, @"metadata",
                                                   nil];
                NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                   self.edt_cardNum.text, @"number",
                                                   paths[1], @"exp_year",
                                                   paths[0], @"exp_month",
                                                   self.edt_cvv.text, @"cvc",
                                                   @"usd", @"currency",
                                                   nil],
                                                  @"card",
                                                  nil];
                [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) {
                    if (err) {
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Please check your details and try again."];
                    } else {
                        [self.saveData saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                            if(succeed){
                                [SVProgressHUD dismiss];
                                [Util showAlertTitle:self title:@"" message:@"Payment succeed." finish:^(void){}];
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            }else{
                                [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                                    [SVProgressHUD dismiss];}];
                            }
                        }];
                    }
                }];
            }
        } failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            }];
        }];*/
        /**/
        
        
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
