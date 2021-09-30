//
//  CustomerOrderHistoryController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerOrderHistoryController.h"
#import "CutomerOrderHistoryCell.h"
#import "OpenTabTableViewCell.h"
#import "DBCong.h"
#import "Util.h"
#import "CustomerTabBarController.h"
#import "SCLAlertView.h"
#import "UIImageView+WebCache.h"

@interface CustomerOrderHistoryController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * m_orderArray;
    NSMutableArray * m_clientArray;
}
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet UILabel *lbl_noData;
@end

@implementation CustomerOrderHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_dataTable.allowsSelectionDuringEditing = NO;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self reloadTable];
}

- (void) reloadTable
{
    m_clientArray = [NSMutableArray new];
    NSMutableArray * clientIdArray = [NSMutableArray new];
    [self.lbl_noData setHidden:YES];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query1 = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query1 whereKey:@"sender_id" equalTo:defaultUser.row_id];
    [query1 whereKey:@"isPaid" equalTo:[NSNumber numberWithBool:YES]];
    [query1 whereKey:@"deleted" notEqualTo:[NSNumber numberWithInt:1]];
    
    PFQuery * query2 = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query2 whereKey:@"sender_id" equalTo:defaultUser.row_id];
    [query2 whereKey:@"step" equalTo:[NSNumber numberWithInt:SYSTEM_ORDER_DELETED]];
    [query1 whereKey:@"deleted" notEqualTo:[NSNumber numberWithInt:1]];
    
    
    PFQuery * query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            m_orderArray = [NSMutableArray new];
            for(PFObject * subItem in objects){
                if([subItem[@"deleted"] intValue] != 1){
                    [m_orderArray addObject:subItem];
                    NSString * ownerId = subItem[@"owner_id"];
                    BOOL contains = NO;
                    for(NSString * subString in clientIdArray){
                        if([subString isEqualToString:ownerId]){
                            contains = YES;
                        }
                    }
                    if(!contains)
                        [clientIdArray addObject:ownerId];
                }
            }
            [DBUsers getUserInfoFromUserIds:clientIdArray sucessBlock:^(NSMutableArray * usersArray, NSError* error){
                [SVProgressHUD dismiss];
                m_clientArray = usersArray;
                if(m_orderArray.count  == 0){
                    [self.lbl_noData setHidden:NO];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.m_dataTable reloadData];
                    [self.m_dataTable setContentOffset:CGPointZero];
                });
                
                
            } failBlock:^(NSError* error){
                [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
            
            
        }else{
            [SVProgressHUD dismiss];
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
- (DBUsers*) getUserInfo:(NSString*)userId
{
    for(DBUsers * item in m_clientArray){
        if([item.row_id isEqualToString:userId]){
            return item;
        }
    }
    return nil;
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
    return [m_orderArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"OpenTabTableViewCell";
    OpenTabTableViewCell * cell = (OpenTabTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell setNeedsLayout];
   
    
    PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
    return [OpenTabTableViewCell getCellHeightWithValue:[object[@"names"] count]] - 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"OpenTabTableViewCell"];
    OpenTabTableViewCell * cell = (OpenTabTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        
        cell.img_user.image = nil;
        cell.lbl_name.text = @"";
        
        PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
        [cell initWithData:[[NSMutableArray alloc] initWithObjects:object[@"names"], object[@"prices"], nil]];
        
        
        DBUsers * owner = [self getUserInfo:object[@"owner_id"]];
        [cell.lbl_name setText:owner.row_userName];
        [cell.img_user sd_setImageWithURL:[NSURL URLWithString:owner.row_userPhoto]];
        
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
        
        int step = [object[@"step"] integerValue];
        BOOL isPaid = [object[@"isPaid"] boolValue];
        if(isPaid){
            cell.img_paid.hidden = NO;
        }else{
            cell.img_paid.hidden = YES;
        }
    }
    return cell;
}
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        NSString *msg = @"Are you sure you want to delete this order history?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Cancel" actionBlock:^(void) {
        }];
        [alert addButton:@"Yes" actionBlock:^(void) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
            object[@"deleted"] = [NSNumber numberWithInt:1];
            [object saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                [SVProgressHUD dismiss];
                [self reloadTable];
            }];
        }];
        [alert showError:@"Delete" subTitle:msg closeButtonTitle:nil duration:0.0f];
        
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PFObject * object = [m_orderArray objectAtIndex:indexPath.row];
    NSString * ownerId = object[@"owner_id"];
    CustomerTabBarController * controller = (CustomerTabBarController*)self.navigationController.tabBarController;
    
    PFQuery * query = [PFQuery queryWithClassName:TBL_NAME_ORDER];
    [query whereKey:@"ContainsId" equalTo:object.objectId];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            if(objects.count  > 0){
                PFObject * firstObject = [objects firstObject];
                NSString * drinkId = firstObject[@"drinkid"];
                
                [DrinkItem getDrinkItemFromId:drinkId sucessBlock:^(DrinkItem * item, NSError * error){
                    [SVProgressHUD dismiss];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [controller gotoBussinessScreen:ownerId :item.row_category_id :item.row_subcategory_id];
                    });
                    
                } failBlock: ^(NSError * error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }];
            }
            
        }else{
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
        //    [controller gotoBussinessScreen:ownerId :];
}
@end
