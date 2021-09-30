//
//  CustomNotifyViewController.m
//  quickdrinks
//
//  Created by mojado on 7/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomNotifyViewController.h"
#import "NotifyTableViewCell.h"
#import "DBCong.h"
#import "Util.h"
#import "StripeRest.h"


@interface CustomNotifyViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray * m_dataArray;
    BOOL isActive;
}
@property (strong, nonatomic) IBOutlet UITableView *tblData;
@property (strong, nonatomic) IBOutlet UILabel *lbl_nodata;

@end

@implementation CustomNotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lbl_nodata setHidden:YES];
    // Do any additional setup after loading the view.
    isActive = YES;
    [self reloadDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) reloadDatas
{
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:@"db_notification"];
    [query whereKey:@"toUserId" equalTo:defaultUser.row_id];
    [query orderByDescending:@"updatedAt"];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [query findObjectsInBackgroundWithBlock:^(NSArray * array, NSError * error){
        m_dataArray = [[NSMutableArray alloc] initWithArray:array];
        if(m_dataArray.count == 0){
            [self.lbl_nodata setHidden:NO];
        }
        [_tblData reloadData];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss ZZZ"];
        NSUserDefaults * detalts = [NSUserDefaults standardUserDefaults];
        [detalts setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"notification_check_date"];
        [detalts synchronize];
        [self performSelector:@selector(recheckNotification) withObject:nil afterDelay:3];
        [SVProgressHUD dismiss];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) recheckNotification
{
    if(!isActive)
        return;
    NSLog(@"recheckNotification");
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    NSUserDefaults * detalts = [NSUserDefaults standardUserDefaults];
    NSString * checkedString = [detalts valueForKey:@"notification_check_date"];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss ZZZ"];
    NSDate * date = [dateFormatter dateFromString:checkedString];
    PFQuery *query = [PFQuery queryWithClassName:@"db_notification"];
    [query whereKey:@"toUserId" equalTo:defaultUser.row_id];
    [query whereKey:@"updatedAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
        if(!error){
            int count = (int)[objects count];
            if(count > 0){
                [self reloadDatas];
            }else{
                [self performSelector:@selector(recheckNotification) withObject:nil afterDelay:3];
            }
        }else{
        }
    }];
}
- (NSString*) calcAgoTime:(NSDate*)from
{
    NSTimeInterval timeinterval = [from timeIntervalSinceNow];
    int min =  timeinterval / 60;
    if(min < 0 )
        min = -min;
    if(min < 60){
        return [NSString stringWithFormat:@"%d mins ago", min];
    }else if(min < 24*60){
        min = min / 60;
        return [NSString stringWithFormat:@"%d hours ago", min];
    }else{
        min = min / (24 * 60);
        return [NSString stringWithFormat:@"%d days ago", min];
    }
    return @"";
}

- (IBAction)onBack:(id)sender {
    isActive = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [m_dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"NotifyTableViewCell"];
    NotifyTableViewCell * cell = (NotifyTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        [cell.lbl_name setText:@""];
        PFObject * object = [m_dataArray objectAtIndex:indexPath.row];
        [DBUsers getUserInfoFromUserId:object[@"fromUserId"] sucessBlock:^(DBUsers * val, NSError * error){
            [Util setImage:cell.img_user imgUrl:val.row_userPhoto];
            [cell.lbl_name setText:val.row_userName];
        } failBlock:^(NSError*error){
        }];
        [cell.lbl_title setText:object[@"message"]];
        [cell.lbl_time setText:[self calcAgoTime:object.updatedAt]];
    }
    return cell;
}

@end
