//
//  CustomerFavouriteController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerFavouriteController.h"
#import "BusinessItemTableViewCell.h"
#import "DBCong.h"
#import "Util.h"
#import "CustomerTabBarController.h"

@interface CustomerFavouriteController ()<UITableViewDelegate, UITableViewDataSource, BusinessItemTableViewCellDelegate>
{
    NSMutableArray * m_itemArray;
    int tableItemCount;
}
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet UILabel *lbl_nodata;
@end

@implementation CustomerFavouriteController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.m_dataTable reloadData];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self refreshTable];
}

- (void) refreshTable
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    [self.lbl_nodata setHidden:YES];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBFavourtie allFavouriteItems:defaultUser.row_id :^(id returnVal, NSError * error){
        [SVProgressHUD dismiss];
        m_itemArray = returnVal;
        if(m_itemArray.count == 0){
            [self.lbl_nodata setHidden:NO];
        }
        [self.m_dataTable reloadData];
        [self.m_dataTable setContentOffset:CGPointZero animated:NO];
        
    } failBlock:^( NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Network Error." finish:^(void){}];        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(m_itemArray){
        if([m_itemArray count] %2 == 0)
            return [m_itemArray count] /2;
        return [m_itemArray count] /2 + 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"BusinessItemTableViewCell"];
    BusinessItemTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    NSMutableArray * data = [NSMutableArray new];
    [data addObject:[m_itemArray objectAtIndex:indexPath.row * 2]];
    if([m_itemArray count] > indexPath.row * 2 +1){
        [data addObject:[m_itemArray objectAtIndex:indexPath.row * 2 + 1]];
    }
    [cell.m_item1View setIsCustomMode:YES];
    [cell.m_item2View setIsCustomMode:YES];
    
    cell.m_item1View.btn_favour.selected = YES;
    cell.m_item2View.btn_favour.selected = YES;
    
    if(data.count == 2){
        [cell.m_item1View setInformation:[data firstObject]];
        [cell.m_item2View setInformation:[data lastObject]];
        [cell.m_item1View setHidden:NO];
        [cell.m_item2View setHidden:NO];
    }else{
        [cell.m_item1View setInformation:[data firstObject]];
        [cell.m_item1View setHidden:NO];
        [cell.m_item2View setHidden:YES];
    }
    cell.delegate = self;
    [cell initDelegate];
    return cell;
}
- (void)BusinessItemTableViewCellDelegate_clickedAt:(UITableViewCell *)cell atIndex:(int)index withOption:(int)option
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int rowIndex = (int)[self.m_dataTable indexPathForCell:cell].row * 2 + index;
    
    if(option == 0){
        DrinkItem * item = [m_itemArray objectAtIndex:rowIndex];
        NSString * ownerId = item.user_id;
        CustomerTabBarController * controller = (CustomerTabBarController*)self.navigationController.tabBarController;
        [controller gotoBussinessScreen:ownerId :item.row_category_id :item.row_subcategory_id];
    }else{//edit
        DrinkItem * item = [m_itemArray objectAtIndex:rowIndex];
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBFavourtie deleteItemWith:defaultUser.row_id :item.row_id :^(id returnVal, NSError * error){
            [SVProgressHUD dismiss];
            [self refreshTable];
        } failBlock:^(NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
