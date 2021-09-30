//
//  CustomerCartViewController.m
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerCartViewController.h"
#import "CurrentOrderCell.h"
#import "DBCong.h"
#import "Util.h"
#import "StripeRest.h"
#import "CustomCheckerGroup.h"
#import "CustomComboBox.h"
#import "AssignActionView.h"
#import "CustomerStripeAccountController.h"

@interface CustomerCartViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, CustomCheckerBoxDelegate, CustomComboBox_SelectedItem, CurrentCartCellDelegate>
{
    NSMutableArray * m_orderArray;
    
    float totalOrder;
    float tax;
    float tip;
    
    NSMutableArray * m_locationTitles;
    NSMutableArray * m_locationOptions;
}

@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet CustomCheckerGroup *selectMethod;
@property (strong, nonatomic) IBOutlet UIView *view_locationView;

@property (weak, nonatomic) IBOutlet UILabel *lbl_checkview;
@property (weak, nonatomic) IBOutlet CustomComboBox *combo_courseName;
@property (weak, nonatomic) IBOutlet CustomComboBox *combo_laneNumber;
@end

@implementation CustomerCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectMethod.receiver = self;
    [self.selectMethod initViewDelegate];
    [self.selectMethod setSelectItem:0];
    
    m_orderArray = [StackMemory  getCartItems];
    if(!m_orderArray || m_orderArray.count == 0){
        [Util showAlertTitle:self title:@"" message:@"There are no carted items." finish:^(void){
        [self.navigationController popViewControllerAnimated:YES];
        }];
        
        return;
    }
    totalOrder = 0;
    for(StackCartItem * item in m_orderArray){
        totalOrder += item.drink_price;
    }
    
    StackCartItem * first_item = [m_orderArray firstObject];
    PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
    [query whereKey:@"user_id" equalTo:first_item.owner_id];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
        if(object){
            int opened = [object[@"online_order"] intValue];
            if(opened == 1){
                
                PFQuery *query = [PFQuery queryWithClassName:@"Delivery"];
                [query whereKey:@"user_id" equalTo:first_item.owner_id];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    [SVProgressHUD dismiss];
                    if(!error){
                        if(objects.count > 0){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                PFObject * object = [objects firstObject];
                                NSString * locationName1 = object[@"section1_name"];
                                NSString * locationOption1 = object[@"section1_option"];
                                NSString * locationName2 = object[@"section2_name"];
                                NSString * locationOption2 = object[@"section2_option"];
                                NSString * locationName3 = object[@"section3_name"];
                                NSString * locationOption3 = object[@"section3_option"];
                                
                                m_locationTitles = [NSMutableArray new];
                                m_locationOptions = [NSMutableArray new];
                                
                                if(locationName1 && locationName1.length > 0){
                                    [m_locationTitles addObject:locationName1];
                                    NSArray * tableNames = [locationOption1 componentsSeparatedByString:@","];
                                    if(tableNames && tableNames.count > 0){
                                        NSMutableArray * items = [NSMutableArray new];
                                        for(NSString * item in tableNames){
                                            [items addObject:item];
                                        }
                                        [m_locationOptions addObject:items];
                                    }
                                }
                                if(locationName2 && locationName2.length > 0){
                                    [m_locationTitles addObject:locationName2];
                                    NSArray * tableNames = [locationOption2 componentsSeparatedByString:@","];
                                    if(tableNames && tableNames.count > 0){
                                        NSMutableArray * items = [NSMutableArray new];
                                        for(NSString * item in tableNames){
                                            [items addObject:item];
                                        }
                                        [m_locationOptions addObject:items];
                                    }
                                }
                                if(locationName3 && locationName3.length > 0){
                                    [m_locationTitles addObject:locationName3];
                                    NSArray * tableNames = [locationOption3 componentsSeparatedByString:@","];
                                    if(tableNames && tableNames.count > 0){
                                        NSMutableArray * items = [NSMutableArray new];
                                        for(NSString * item in tableNames){
                                            [items addObject:[Util trim:item]];
                                        }
                                        [m_locationOptions addObject:items];
                                    }
                                }
                                
                                self.combo_courseName.m_containDatas = m_locationTitles;
                                self.combo_courseName.delegate = self;
                                
                                if(m_locationTitles.count > 0){
                                    self.combo_courseName.lbl_title.text = [m_locationTitles firstObject];
                                    NSMutableArray * combo2Strings = [m_locationOptions objectAtIndex:0];
                                    self.combo_laneNumber.m_containDatas = combo2Strings;
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.m_dataTable reloadData];
                                });
                            });
                        }else{
                            NSString * message = @"Business don't have delivery location.";
                            [Util showAlertTitle:self title:@"" message:message finish:^(void){
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        }
                    }else{
                        NSString * message = @"Business don't have delivery location.";
                        [Util showAlertTitle:self title:@"" message:message finish:^(void){
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                }];
                
            }else{
                NSString * message = @"Business is close for online order. Please order through any of our service staff.";
                [Util showAlertTitle:self title:@"" message:message finish:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
    }];
    
    
}

- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    CustomComboBox * currentCombo = (CustomComboBox*)combo;
    if(currentCombo == self.combo_courseName){
        int index = -1;
        for(NSString * subString in m_locationTitles){
            if([subString isEqualToString:item]){
                index = (int)[m_locationTitles indexOfObject:subString];
            }
        }
        NSMutableArray * combo2Strings = [m_locationOptions objectAtIndex:index];
        self.combo_laneNumber.m_containDatas = combo2Strings;
    }else{
        
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

- (void)CustomCheckerBoxDelegate_didSelected:(int)tag
{
    for(UIView * subview in self.selectMethod.subviews){
        if([subview isKindOfClass:[CustomCheckerBox class]]){
            if(subview.tag != tag){
                [((CustomCheckerBox*)subview) setSelected:NO];
            }
        }
    }
    if(tag == 0){
        [self.lbl_checkview setHidden:NO];
        [self.combo_courseName setHidden:NO];
        [self.combo_laneNumber setHidden:NO];
    }else{
        [self.lbl_checkview setHidden:YES];
        [self.combo_courseName setHidden:YES];
        [self.combo_laneNumber setHidden:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(m_orderArray.count > 0)
        return 1;
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"CurrentCartCell";
    CurrentCartCell * cell = (CurrentCartCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell layoutIfNeeded];
    return [CurrentCartCell getCellHeightWithValue:(int)m_orderArray.count];;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"CurrentCartCell"];
    CurrentCartCell * cell = (CurrentCartCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        [cell initWithData:m_orderArray];
        cell.delegate = self;
        
        cell.lbl_total.text = [NSString stringWithFormat:@"$ %.2f", totalOrder];
    }
    return cell;
}
- (void) CurrentCartCellDelegate_didDeleted:(int)index
{
    [StackMemory removeItemFromCart:index];
    m_orderArray = [StackMemory  getCartItems];
    totalOrder = 0;
    for(StackCartItem * item in m_orderArray){
        totalOrder += item.drink_price;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_dataTable reloadData];
    });
    if(!m_orderArray || m_orderArray.count == 0){
        [Util showAlertTitle:self title:@"" message:@"There are no carted items." finish:^(void){
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        return;
    }
    
}
- (void) onCheckStripeAccount
{
    CustomerStripeAccountController * controller = (CustomerStripeAccountController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomerStripeAccountController"];
    [self.navigationController pushViewController:controller animated:YES];
}


- (IBAction)onProceed:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:defaultUser.row_id sucessBlock:^(DBUsers * item, NSError * error){
        [SVProgressHUD dismiss];
        //        if(item.row_accountId && item.row_accountId.length > 0){
        if([self.selectMethod getSelectedIndex] == 0){
            if([self.combo_courseName.lbl_title.text isEqualToString:@"Course Name"]){
                [Util showAlertTitle:self title:@"Error" message:@"Please select course name."];
                return;
            }
            if([self.combo_laneNumber.lbl_title.text isEqualToString:@"Lane Number"]){
                [Util showAlertTitle:self title:@"Error" message:@"Please select lane number."];
                return;
            }
        }
        
        StackCartItem * first_item = [m_orderArray firstObject];
        NSString *owner_id= first_item.owner_id;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
        [query whereKey:@"user_id" equalTo:first_item.owner_id];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
            if(object){
                int opened = [object[@"online_order"] intValue];
                if(opened == 1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DBCustomAssign getCustomAssignItemsWithUserId:owner_id :^(NSMutableArray * array, NSError* error){
                            BOOL isValideNumber = YES;
                            if(isValideNumber || self.selectMethod.getSelectedIndex == 1){
                                if(m_orderArray && m_orderArray.count > 0){
                                    
                                    StackCartItem * first_item = [m_orderArray firstObject];
                                    PFObject *obj = [PFObject objectWithClassName:DB_ORDER_ITEM];
                                    obj[@"sender_id"] = first_item.sender_id;
                                    obj[@"sender_name"] = first_item.sender_name;
                                    obj[@"owner_id"] = first_item.owner_id;
                                    obj[@"owner_name"] = first_item.owner_name;
                                    
                                    obj[@"sendType"] = [NSNumber numberWithInteger:self.selectMethod.getSelectedIndex];
                                    if([self.selectMethod getSelectedIndex] == 0){
                                        obj[@"courseName"] = self.combo_courseName.lbl_title.text;
                                        obj[@"laneNum"] = self.combo_laneNumber.lbl_title.text;
                                    }
                                    
                                    float totalPrice = 0;
                                    int totalcount = 0;
                                    NSMutableArray * titles = [NSMutableArray new];
                                    NSMutableArray * prices = [NSMutableArray new];
                                    NSMutableArray * categories = [NSMutableArray new];
                                    NSMutableArray * descriptions = [NSMutableArray new];
                                    NSMutableArray * instructions = [NSMutableArray new];
                                    NSMutableArray * itemIds = [NSMutableArray new];
                                    for(StackCartItem * new_item in m_orderArray){
                                        [itemIds addObject:new_item.item.row_id];
                                        [titles addObject:new_item.item_name];
                                        [prices addObject:[NSNumber numberWithFloat:new_item.drink_price]];
                                        totalPrice += new_item.drink_price;
                                        [categories addObject:[NSNumber numberWithInteger:new_item.item.row_category_id]];
                                        [descriptions addObject:new_item.item_descrption];
                                        totalcount += new_item.drink_count;
                                        [instructions addObject:new_item.item_drinkInstruction];
                                    }
                                    obj[@"total_price"] = [NSNumber numberWithFloat:totalPrice];
                                    obj[@"total_count"] = [NSNumber numberWithFloat:totalcount];
                                    obj[@"names"] = titles;
                                    obj[@"prices"] = prices;
                                    obj[@"categories"] = categories;
                                    obj[@"descriptions"] = descriptions;
                                    obj[@"instructions"] = instructions;
                                    obj[@"drinkIds"] = itemIds;
                                    obj[@"step"] = [NSNumber numberWithInteger:SYSTEM_ORDER_CREATED];
                                    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                                        if(succeed){
                                            NSMutableArray * orders = [NSMutableArray new];
                                            for(StackCartItem * new_item in m_orderArray){
                                                DBOrder * subItem = [DBOrder new];
                                                subItem.row_user_id = new_item.sender_id;
                                                subItem.row_sendType = self.selectMethod.getSelectedIndex;
                                                subItem.row_add_count = new_item.drink_count;
                                                subItem.row_drink_id = new_item.item.row_id;
                                                subItem.row_specialInstruction = new_item.item_descrption;
                                                if([self.selectMethod getSelectedIndex] == 0){
                                                    subItem.row_courseName = self.combo_courseName.lbl_title.text;
                                                    subItem.row_laneNumber = self.combo_laneNumber.lbl_title.text;
                                                }
                                                subItem.row_owner_id = new_item.owner_id;
                                                subItem.row_orderStep = 0;
                                                subItem.row_orderPrice = new_item.drink_price;
                                                subItem.row_drinkname = new_item.item.row_name;
                                                subItem.row_ownername = new_item.owner_name;
                                                subItem.row_username = new_item.sender_name;
                                                [orders addObject:subItem];
                                            }
                                            [DBOrder addItemsWith:orders :obj.objectId :^(id returnItem, NSError * error){
                                                [SVProgressHUD dismiss];
                                                [StackMemory removeCutItems];
                                                [Util showAlertTitle:self title:@"" message:@"Your order successfully sent." finish:^(void){
                                                }];
                                                [self.navigationController popViewControllerAnimated:YES];
                                                
                                                
                                            } failBlock:^(NSError * error){
                                                [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){
                                                    [SVProgressHUD dismiss];
                                                }];
                                            }];
                                            
                                        }else{
                                            [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){
                                                [SVProgressHUD dismiss];
                                            }];
                                        }
                                        
                                    }];
                                }
                                
                            }else{
                                [SVProgressHUD dismiss];
                                [Util showAlertTitle:self title:@"" message:@"Staff is not assigned for this location." finish:^(void){
                                    
                                }];
                            }
                            
                        } failBlock:^(NSError* error){
                            [Util showAlertTitle:self title:@"" message:@"We detected a few errors. Help me review your answers and try again." finish:^(void){
                                [SVProgressHUD dismiss];
                            }];
                        }];
                    });
                }else{
                    NSString * message = @"Business is close for online order. Please order through any of our service staff.";
                    [Util showAlertTitle:self title:@"" message:message finish:^(void){
                    }];
                }
            }
        }];
        //        }else{
        //            [self onCheckStripeAccount];
        //        }
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:error.localizedDescription finish:^(void){
        }];
    }];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    tip = [[textField text] floatValue];
    return YES;
}
@end
