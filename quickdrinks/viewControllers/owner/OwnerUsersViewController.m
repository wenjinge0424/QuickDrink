//
//  OwnerUsersViewController.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerUsersViewController.h"
#import "DBCong.h"
#import "OwnerUserCell.h"
#import "OwnerCustomerProfileController.h"
#import "OwnerBusinessProfileController.h"
#import "Util.h"

@interface OwnerUsersViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * m_tableData;
    
    DBUsers * m_user;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *selectSegue;

@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@end

@implementation OwnerUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    int index = self.selectSegue.selectedSegmentIndex;
    [self reloadTableWithType:index];
}
- (void) reloadTableWithType:(int)type
{
    if(type == 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getAllUsers:^(NSMutableArray * datas, NSError* error){
            [SVProgressHUD dismiss];
            m_tableData = datas;
            [self.m_dataTable reloadData];
        } failBlock:^(NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }else{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getAllBanUsers:^(NSMutableArray * datas, NSError* error){
            [SVProgressHUD dismiss];
            m_tableData = datas;
            [self.m_dataTable reloadData];
        } failBlock:^(NSError* error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showBusinessProfile"]){
        OwnerBusinessProfileController * controller = (OwnerBusinessProfileController*)[segue destinationViewController];
        controller.m_currentUser = m_user;
    }else if([segue.identifier isEqualToString:@"showCustomerProfile"]){
        OwnerCustomerProfileController * controller = (OwnerCustomerProfileController*)[segue destinationViewController];
        controller.m_currentUser = m_user;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_tableData count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"OwnerUserCell"];
    OwnerUserCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        cell.lbl_title.userInteractionEnabled = NO;
        DBUsers * item = [m_tableData objectAtIndex:indexPath.row];
        NSString * name = item.row_userName;
        if(name.length == 0){
            name = item.row_userEmail;
        }
        cell.lbl_title.text = name;
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectSegue.selectedSegmentIndex == 0){
        m_user = [m_tableData objectAtIndex:indexPath.row];
        if(m_user.row_userType == 0){
            [self performSegueWithIdentifier:@"showBusinessProfile" sender:self];
        }else{
            [self performSegueWithIdentifier:@"showCustomerProfile" sender:self];
        }
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSelectCategory:(id)sender {
    if(self.selectSegue.selectedSegmentIndex == 0){
        [self reloadTableWithType:0];
    }else{
        [self reloadTableWithType:1];
    }
}

@end
