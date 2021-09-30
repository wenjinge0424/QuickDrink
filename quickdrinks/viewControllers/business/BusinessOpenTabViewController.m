//
//  BusinessOpenTabViewController.m
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessOpenTabViewController.h"
#import "OpenTabTableViewCell.h"
#import "DBCong.h"
#import "Util.h"
#import "StripeRest.h"
#import "SCLAlertView.h"

@interface BusinessOpenTabViewController ()<UITabBarDelegate, UITableViewDataSource>

{
    NSMutableArray * m_orderArray;
}

@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@end

@implementation BusinessOpenTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self fetchData];
}
- (void) fetchData
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query whereKey:@"owner_id" equalTo:defaultUser.row_id];
    [query whereKey:@"step" greaterThan:[NSNumber numberWithInteger:SYSTEM_ORDER_STARTED]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        [SVProgressHUD dismiss];
        if(!error){
            m_orderArray = [NSMutableArray new];
            for(PFObject * object in objects){
                NSDate * currentTime = object.updatedAt;
                NSDate * atNow = [NSDate date];
                int interval = [atNow timeIntervalSinceDate:currentTime];
                if( interval < 24*3600){
                    [m_orderArray addObject:object];
                }
            }
            if(m_orderArray.count > 0){
                [self.m_dataTable reloadData];
            }else{
                [Util showAlertTitle:self title:@"" message:@"There are no active tabs." finish:^(void){
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_orderArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"OpenTabTableViewCell";
    OpenTabTableViewCell * cell = (OpenTabTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell layoutIfNeeded];
    
    PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
    BOOL isPaid = [object[@"isPaid"] boolValue];
    if(isPaid){
        return [OpenTabTableViewCell getCellHeightWithValue:[object[@"names"] count]];
    }
    return [OpenTabTableViewCell getCellHeightWithValue:[object[@"names"] count]] + 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"OpenTabTableViewCell"];
    OpenTabTableViewCell * cell = (OpenTabTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell layoutIfNeeded];
    if(cell){
        PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
        [cell initWithData:[[NSMutableArray alloc] initWithObjects:object[@"names"], object[@"prices"], nil]];
        
        [cell.lbl_name setText:@""];
        [cell.img_user setImage:[UIImage imageNamed:@""]];
        
        [DBUsers getUserInfoFromUserId:object[@"sender_id"] sucessBlock:^(DBUsers * val, NSError * error){
            [Util setImage:cell.img_user imgUrl:val.row_userPhoto];
            [cell.lbl_name setText:val.row_userName];
        } failBlock:^(NSError*error){
        }];
        
        cell.img_user.layer.cornerRadius = cell.img_user.frame.size.width/2;
        
        if([object[@"sendType"] intValue] == 0){
            NSString * courseName = object[@"courseName"];
            NSString * laneNum = object[@"laneNum"];
            cell.lbl_location.text = [NSString stringWithFormat:@"%@ \n%@", courseName, laneNum];
        }else{
            cell.lbl_location.text = @"Bar";
        }
        cell.lbl_dateTime.text = [Util convertDate2String:object.updatedAt];
        cell.lbl_total.text = [NSString stringWithFormat:@"$%.2f", [object[@"total_price"] floatValue]];
        cell.lbl_orderTotal.text = [NSString stringWithFormat:@"%d", [object[@"total_count"] intValue]];
        
        BOOL isPaid = [object[@"isPaid"] boolValue];
        if(isPaid){
            cell.img_paid.hidden = NO;
            cell.btn_requestPayment.hidden = YES;
            
        }else{
            cell.img_paid.hidden = YES;
            cell.btn_requestPayment.hidden = NO;
            cell.btn_requestPayment.tag = indexPath.row;
            [cell.btn_requestPayment addTarget:self action:@selector(onSendPaymentRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void) onSendPaymentRequest:(UIButton*)button
{
    PFObject * object = [m_orderArray objectAtIndex:button.tag];
    NSString * senderId = object[@"sender_id"];
    
    OpenTabTableViewCell * cell = (OpenTabTableViewCell*)[_m_dataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    NSString * message = [NSString stringWithFormat:@"Are you sure collect payment from %@ for %@?", cell.lbl_name.text, cell.lbl_total.text];
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Not Now" actionBlock:^(void) {
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        [self paymentFor:cell.lbl_total.text from:senderId atItem:object];
    }];
    [alert showError:@"Collect payment" subTitle:message closeButtonTitle:nil duration:0.0f];
}
- (void) paymentFor:(NSString*)value from:(NSString * )user atItem:(PFObject*)orderObj
{
    NSString * payamount = [value stringByReplacingOccurrencesOfString:@"$" withString:@""];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFUser * receiver = [PFUser currentUser];
    [receiver fetchIfNeededInBackgroundWithBlock:^(PFObject * object , NSError * error){
        PFUser * receiver = (PFUser*)object;
        [DBUsers getUserInfoFromUserId:user sucessBlock:^(DBUsers * val, NSError * error){
            
            DBUsers * sender = val;
            NSString * stripeId_receiver = receiver[TBL_USERS_ACCOUNT_ID];
            
            PFQuery * paymentInfo  = [PFQuery queryWithClassName:@"tbl_paymentinfo"];
            [paymentInfo whereKey:@"userId" equalTo:sender.row_id];
            [paymentInfo getFirstObjectInBackgroundWithBlock:^(PFObject* object, NSError * error){
                if(error || !object){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:@"This user not have payment information." finish:^(void){
                    }];
                }else{
                    NSString * cardNum = object[@"num"];
                    NSString * expire = object[@"expire"];
                    NSString * cvv = object[@"cvv"];
                    NSArray *paths = [expire pathComponents];
                    
                    NSString * senderName = [NSString stringWithFormat:@"%@", sender.row_userName];
                    NSString * receiverName = [NSString stringWithFormat:@"%@", receiver[TBL_USERS_NAME]];
                    
                    NSString *description = [NSString stringWithFormat:@"MAIN - '%@' paid to '%@'",senderName, receiverName];
                    NSString *amount = [NSString stringWithFormat:@"%d", (int)([payamount intValue] * 100)];
                    NSString *accountId = stripeId_receiver;
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
                                                       cardNum, @"number",
                                                       paths[1], @"exp_year",
                                                       paths[0], @"exp_month",
                                                       cvv, @"cvc",
                                                       @"usd", @"currency",
                                                       nil],
                                                      @"card",
                                                      nil];
                    [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) {
                        
                        if (err) {
                            [SVProgressHUD dismiss];
                            [Util showAlertTitle:self title:@"" message:@"Unable to process payment. Please check your details and try again."];
                        } else {
                            NSDictionary *dict = response;
                            NSString *  mainId = dict[@"id"];
                            
                            orderObj[@"isPaid"] = [NSNumber numberWithBool:YES];
                            [orderObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                                [SVProgressHUD dismiss];
                                [Util showAlertTitle:self title:@"Success" message:@"You'd collect payment from customer." finish:^{
                                    [self fetchData];
                                }];
                            }];
                        }
                    }];
                }
            }];
            
        } failBlock:^(NSError*error){
        }];
    }];
}
@end
