//
//  OwnerReportUsersViewController.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OwnerReportUsersViewController.h"
#import "DBCong.h"
#import "OwnerUserCell.h"
#import "Util.h"
#import "OwnerRportDetailViewController.h"

@interface OwnerReportUsersViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * m_tableData;
    
    DBReport * selected_item;
}

@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@end

@implementation OwnerReportUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_tableData = [NSMutableArray new];
    
    
    
   
}
- (void) viewWillAppear:(BOOL)animated
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBReport getAllReport:^(NSMutableArray * items, NSError * error){
        [SVProgressHUD dismiss];
        m_tableData = items;
        [self.m_dataTable reloadData];
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"" message:@"Network Error" finish:^(void){
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showReportResult"]){
        OwnerRportDetailViewController * controller = (OwnerRportDetailViewController*)[segue destinationViewController];
        controller.m_data = selected_item;
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        DBReport * item = [m_tableData objectAtIndex:indexPath.row];
        NSString * name = item.row_send_userName;
        if(name.length == 0){
            name = item.row_send_userEmail;
        }
        cell.lbl_title.text = name;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected_item = [m_tableData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showReportResult" sender:self];
}
@end
