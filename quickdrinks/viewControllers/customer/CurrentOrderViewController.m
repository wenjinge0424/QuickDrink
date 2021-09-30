//
//  CurrentOrderViewController.m
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CurrentOrderViewController.h"
#import "CurrentOrderCell.h"
#import "DBCong.h"
#import "Util.h"
#import "StripeRest.h"
#import "CustomCheckPInfoViewController.h"

@interface CurrentOrderViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
    PFObject * currentOrder;
    
    float totalOrder;
    float tax;
    float tip;
    
    NSMutableArray * linkedOrders;
}

@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet UITextField *edt_tips;
@property (strong, nonatomic) IBOutlet UILabel *lbl_totalBill;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@end

@implementation CurrentOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done1Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForTipNumber)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done1Button, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_tips setInputAccessoryView:toolbar1];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query whereKey:@"sender_id" equalTo:defaultUser.row_id];
    [query whereKey:@"step" greaterThan:[NSNumber numberWithInteger:SYSTEM_ORDER_CREATED]];
    [query whereKey:@"isPaid" notEqualTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        [SVProgressHUD dismiss];
        if(!error){
            if(objects && objects.count > 0){
                tip = 0;
                UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.edt_tips.frame.size.height)];
                self.edt_tips.leftView = paddingView;
                self.edt_tips.leftViewMode = UITextFieldViewModeAlways;
                [self.edt_tips setText:[NSString stringWithFormat:@""]];
                self.edt_tips.delegate = self;
                
                linkedOrders = [self getLinkedOrder:objects];
                
                [self.lbl_totalBill setText:[NSString stringWithFormat:@"$ %.2f", totalOrder + tip + tax]];
                [self.m_dataTable reloadData];
                
            }else{
                [Util showAlertTitle:self title:@"" message:@"There are no active orders" finish:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
            
        }else{
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSMutableArray * ) getLinkedOrder:(NSArray*)array
{
    float totalPrice = 0;
    
    NSMutableArray * orders = [NSMutableArray new];
    if(array.count > 0){
        PFObject * order_0 = [array firstObject];
        NSString * ownerId_0 = order_0[@"owner_id"];
        for(PFObject * subOrder in array){
            NSString * ownerId = subOrder[@"owner_id"];
            if([ownerId_0 isEqualToString:ownerId]){
                [orders addObject:subOrder];
                totalPrice += [subOrder[@"total_price"] floatValue];
            }
        }
    }
    tax = totalPrice * 0.03;
    totalOrder = totalPrice;
    return orders;
}

- (NSMutableArray *) getDrinkNames
{
    NSMutableArray * names = [NSMutableArray new];
    for(PFObject * subObj in linkedOrders){
        [names addObjectsFromArray:subObj[@"names"]];
    }
    return names;
}
- (NSMutableArray *) getPrices
{
    NSMutableArray * prices = [NSMutableArray new];
    for(PFObject * subObj in linkedOrders){
        [prices addObjectsFromArray:subObj[@"prices"]];
    }
    return prices;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([linkedOrders count] > 0)
        return 1;
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CurrentOrderCell getCellHeightWithValue:[[self getDrinkNames] count]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"CurrentOrderCell"];
    CurrentOrderCell * cell = (CurrentOrderCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        [cell initWithData:[[NSMutableArray alloc] initWithObjects:[self getDrinkNames], [self getPrices], nil]];
        
        cell.lbl_total.text = [NSString stringWithFormat:@"$ %.2f", totalOrder];
        cell.lbl_taxes.text = [NSString stringWithFormat:@"$ %.2f", tax];
    }
    return cell;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
-(bool) isNumeric:(NSString*) checkText{
    return [[NSScanner scannerWithString:checkText] scanFloat:NULL];
}
- (void)onHideKeyboardForTipNumber
{
//    if([[_edt_tips text] intValue] < 0 || [[_edt_tips text] intValue] > 100){
//        [Util showAlertTitle:self title:@"" message:@"You can select number from 0 to 100." finish:^(void){}];
//        [_edt_tips becomeFirstResponder];
//        return;
//    }
    if(![self isNumeric:[_edt_tips text]]){
        [Util showAlertTitle:self title:@"" message:@"Please input valid tip amount." finish:^(void){
            [_edt_tips becomeFirstResponder];
        }];
    }else{
        tip = [[_edt_tips text] doubleValue];
        [self.lbl_totalBill setText:[NSString stringWithFormat:@"%.2f", totalOrder + tip + tax]];
        [self.edt_tips resignFirstResponder];
        [self.edt_tips setText:[NSString stringWithFormat:@"%.2f", tip]];
    }
}

- (IBAction)onProceed:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
//    if([[self.edt_tips text] intValue] < 0 || [[self.edt_tips text] intValue] > 100){
//        [Util showAlertTitle:self title:@"" message:@"You can select number from 0 to 100." finish:^(void){}];
//        [self.edt_tips  becomeFirstResponder];
//        return;
//    }
    if(![self isNumeric:[_edt_tips text]]){
        [Util showAlertTitle:self title:@"" message:@"Please input valid tip amount." finish:^(void){
            [_edt_tips becomeFirstResponder];
        }];
        return;
    }
    
    tip = [[_edt_tips text] doubleValue];
    for(PFObject * orderItem in linkedOrders){
        float per_tip = tip / (linkedOrders.count);
        float totalPrice = 0;
        for(NSNumber * price in orderItem[@"prices"]){
            totalPrice += [price floatValue];
        }
        totalPrice = totalPrice * 1.04 + per_tip;
        orderItem[@"isPaid"] = [NSNumber numberWithBool:YES];
        orderItem[@"total_price"] = [NSNumber numberWithFloat:totalPrice];
        orderItem[@"tip"] = [NSNumber numberWithFloat:per_tip];
    }
    
    CustomCheckPInfoViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomCheckPInfoViewController"];
    controller.saveData = linkedOrders;
    [self.navigationController pushViewController:controller animated:YES];
    return;
    
    
    
    
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    [DBUsers getUserInfoFromUserId:currentOrder[@"owner_id"] sucessBlock:^(DBUsers * m_owner, NSError * error){
//        if(m_owner.row_accountId.length  == 0){
//            [Util showAlertTitle:self title:@"" message:@"Owner account not verified." finish:^(void){
//                [SVProgressHUD dismiss];
//            }];
//        }else{
//            [DBPaymentInfos checkUserPaymentInfo:m_sender sucessBlock:^(DBPaymentInfos * myPaymentInfo, NSError * error){
//                if(myPaymentInfo.row_credit_num.length != 0 && myPaymentInfo.row_credit_cvv.length != 0 && myPaymentInfo.row_credit_expiry.length !=0){
//                    NSArray *paths = [myPaymentInfo.row_credit_expiry pathComponents];
//                    if(paths.count == 2){
//                        NSString *description = [NSString stringWithFormat:@"MAIN - '%@' paid to '%@'",m_sender.row_userName, m_owner.row_userName];
//                        NSString *amount = [NSString stringWithFormat:@"%d", (int)((totalOrder + tip + tax) * 100)];
//                        NSString *accountId = m_owner.row_accountId;
//                        
//                        NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                                         @"iOS", @"DeviceType",
//                                                         nil];
//                        NSMutableDictionary *chargeDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                                           amount, @"amount",
//                                                           @"usd", @"currency",
//                                                           @"false", @"capture",
//                                                           accountId, @"destination",
//                                                           description, @"description",
//                                                           metadata, @"metadata",
//                                                           nil];
//                        NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                                          [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                                           myPaymentInfo.row_credit_num, @"number",
//                                                           paths[1], @"exp_year",
//                                                           paths[0], @"exp_month",
//                                                           myPaymentInfo.row_credit_cvv, @"cvc",
//                                                           @"usd", @"currency",
//                                                           nil],
//                                                          @"card",
//                                                          nil];
//                        
//                        [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
//                        [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) {
//                            
//                            if (err) {
//                                [SVProgressHUD dismiss];
//                                [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Please check your details and try again."];
//                            } else {
//                                NSDictionary *dict = response;
//                                NSString *  mainId = dict[@"id"];
//                                
//                                //                    NSString *message = [NSString stringWithFormat:@"%@ accepted your bid and sent $%.2f(accessible upon delivery confirmation)", me[PARSE_FIELD_USER_FULLNAME], [self.selectedBid[PARSE_FIELD_BIDS_PRICE] doubleValue]];
//                                NSString *message = [NSString stringWithFormat:@"%@ ordered your food. Funds accessible upon delivery confirmation", m_sender.row_userName];
//                                NSString *email = [NSString stringWithFormat:@"You paid $%.2f", (totalOrder + tip + tax)];
//                                
//                                DBPaymentHistory * item = [DBPaymentHistory new];
//                                item.senderId = [PFObject objectWithClassName:TBL_NAME_USERS];
//                                item.senderId.objectId = m_sender.row_id;
//                                item.receiverId = [PFObject objectWithClassName:TBL_NAME_USERS];
//                                item.receiverId.objectId = m_owner.row_id;
//                                item.amount = (totalOrder - tip - tax);
//                                
//                                [DBPaymentHistory addItem:item :^(id val, NSError * error){
//                                    PFObject *obj = [PFObject objectWithClassName:DB_ORDER_ITEM];
//                                    obj[@"step"] = [NSNumber numberWithInt:1];
//                                    obj.objectId = currentOrder.objectId;
//                                    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
//                                        [SVProgressHUD dismiss];
//                                        if(succeed){
//                                            [DBNotification sendNotification:currentOrder[@"owner_id"] :[NSString stringWithFormat:@"%@ pay to you.", currentOrder[@"sender_name"]]];
//                                            [Util showAlertTitle:self title:@"" message:@"Payment Success." finish:^(void){}];
//                                            [self.navigationController popViewControllerAnimated:YES];
//                                        }else{
//                                            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){}];
//                                        }
//                                        
//                                    }];
//                                } failBlock:^(NSError * error){
//                                    [SVProgressHUD dismiss];
//                                    [Util showAlertTitle:self title:@"" message:@"Network error." finish:^(void){
//                                        [SVProgressHUD dismiss];
//                                    }];
//                                }];
//                            }
//                        }];
//                    }else{
//                        [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){
//                            [SVProgressHUD dismiss];
//                        }];
//                    }
//                }else{
//                    [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){
//                        [SVProgressHUD dismiss];
//                    }];
//                }
//                
//            } failBlock:^(NSError * error){
//                [Util showAlertTitle:self title:@"" message:@"Network error." finish:^(void){
//                    [SVProgressHUD dismiss];
//                }];
//            }];
//        }
//    } failBlock:^(NSError*error){
//        [Util showAlertTitle:self title:@"" message:@"Network error." finish:^(void){
//            [SVProgressHUD dismiss];
//        }];
//        }];

}

@end
