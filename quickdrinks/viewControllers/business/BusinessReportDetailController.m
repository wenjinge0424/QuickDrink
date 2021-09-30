//
//  BusinessReportDetailController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessReportDetailController.h"
#import "BusinessReportCell.h"
#import "DBCong.h"
#import "CommonAPI.h"
#import "DBAssignItem.h"

@interface CellItem : NSObject
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * subvalue;
@end

@implementation CellItem

@end

@interface BusinessReportDetailController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * m_tabledata;
}
@property (strong, nonatomic) IBOutlet UILabel *lbl_noData;

@end

@implementation BusinessReportDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }

    [self.lbl_noData setHidden:YES];
    // Do any additional setup after loading the view.
    [self.lbl_title setText:self.m_title];
    [self.lbl_subTitle setText:self.m_subTitle];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:@"orderitems"];
    [query whereKey:@"updatedAt" greaterThan:self.stDate];
    [query whereKey:@"updatedAt" lessThan:self.edDate];
    [query whereKey:@"owner_id" equalTo:defaultUser.row_id];
    //    [query whereKey:TBL_ORDER_STEPS equalTo:[NSNumber numberWithInt:3]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (!error){
            NSMutableArray * array = [NSMutableArray new];
            for (int i=0;i<objects.count;i++){
                PFObject *obj = [objects objectAtIndex:i];
                [array addObject:obj];
            }
            
            [self reloadData:array];
        }else{
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)loadStuffReport:(NSMutableArray*)array
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    CellItem * new_item = [CellItem new];
    new_item.title = @"Staff Name";
    new_item.value = @"Tips";
    new_item.subvalue = @"Sales";
    [m_tabledata addObject:new_item];
    
    NSMutableDictionary * dataDict = [NSMutableDictionary new];

    for(PFObject * item in array){
        NSString * keyString = @"";
        int sendType = [item[@"sendType"] intValue];
        if(sendType == 1){
            keyString = @"Bar";
        }else{
            NSString * deliveryName = item[@"courseName"];
            NSString * laneName = item[@"laneNum"];
            keyString = [NSString stringWithFormat:@"%@(%@)", laneName, deliveryName];
        }
        NSMutableDictionary * subDict = [dataDict objectForKey:keyString];
        if(!subDict)
            subDict = [NSMutableDictionary new];
        if(keyString){
            float  totalVal = 0;
            float  tips = 0;
            float orderVal = 0;
            float tipVal = 0;
            if(subDict){
                totalVal = [[subDict objectForKey:@"Sales"] floatValue];
                tips = [[subDict objectForKey:@"Tips"] floatValue];
                orderVal = [item[@"total_price"] floatValue];
                tipVal = [item[@"tip"] floatValue];
                orderVal += totalVal;
                tipVal += tips;
            }
            [subDict setObject:[NSNumber numberWithFloat:orderVal] forKey:@"Sales"];
            [subDict setObject:[NSNumber numberWithFloat:tipVal] forKey:@"Tips"];
            [dataDict setObject:subDict forKey:keyString];
        }
    }
    
    for(NSString * subdataDict in dataDict.allKeys){
        NSMutableDictionary * subDict = [dataDict objectForKey:subdataDict];
        CellItem * new_item = [CellItem new];
        new_item.title = subdataDict;
        new_item.value = [NSString stringWithFormat:@"$%.2f", [[subDict objectForKey:@"Tips"] floatValue]];
        new_item.subvalue = [NSString stringWithFormat:@"$%.2f", [[subDict objectForKey:@"Sales"] floatValue]];
        [m_tabledata addObject:new_item];
    }
    
    if(m_tabledata.count == 1){
        [self.lbl_noData setHidden:NO];
        [self.m_dataTable setHidden:YES];
    }else{
        [self.lbl_noData setHidden:YES];
        [self.m_dataTable reloadData];
    }
}

- (void)loadHourlyReport:(NSMutableArray*)array
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    CellItem * item = [CellItem new];
    item.title = @"Hour";
    item.value = @"Sales";
    [m_tabledata addObject:item];
    
    NSMutableDictionary * dataDict = [NSMutableDictionary new];
    for(PFObject * item in array){
        NSString * keyString = [Util hourKeyFromDate:item.updatedAt];
        NSMutableDictionary * subDict = [dataDict objectForKey:keyString];
        if(!subDict){
            subDict = [NSMutableDictionary new];
        }
        float totalValue = [[subDict objectForKey:@"Value"] floatValue];
        totalValue = totalValue + [item[@"total_price"] floatValue];
        [subDict setObject:[NSNumber numberWithFloat:totalValue] forKey:@"Value"];
        [dataDict setObject:subDict forKey:keyString];
    }
    for(NSString * subdataDict in dataDict.allKeys){
        NSMutableDictionary * subDict = [dataDict objectForKey:subdataDict];
        CellItem * new_item = [CellItem new];
        new_item.title = subdataDict;
        new_item.value = [NSString stringWithFormat:@"$%.2f", [[subDict objectForKey:@"Value"] floatValue]];
        [m_tabledata addObject:new_item];
    }
    
    if(m_tabledata.count == 1){
        [self.lbl_noData setHidden:NO];
        [self.m_dataTable setHidden:YES];
    }else{
        [self.lbl_noData setHidden:YES];
        [self.m_dataTable reloadData];
    }
}

- (void)loadProfileReport:(NSMutableArray*)data
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBOrder getHistoryFrom:self.stDate :self.edDate :^(NSMutableArray * datas, NSError * error){
        [SVProgressHUD dismiss];
        
        NSMutableArray * userIdArray = [NSMutableArray new];
        for(DBOrder * item in datas){
            BOOL alreadyContains = NO;
            for(NSString * userId in userIdArray){
                if([item.row_user_id isEqualToString:userId]){
                    alreadyContains = YES;
                }
            }
            if(!alreadyContains){
                [userIdArray addObject:item.row_user_id];
            }
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getUserInfoFromUserIds:userIdArray sucessBlock:^(NSArray * users, NSError * error){
            [SVProgressHUD dismiss];
            
            CellItem * item = [CellItem new];
            item.title = @"Type";
            item.value = @"Count";
            [m_tabledata addObject:item];
            
            int manCount = 0;
            int girlCount = 0;
            for(DBUsers * userItem in users){
                if([userItem.row_gender isEqualToString:@"Male"]){
                    manCount ++;
                }else{
                    girlCount ++;
                }
            }
            
            CellItem * item1 = [CellItem new];
            item1.title = @"Male";
            item1.value = [NSString stringWithFormat:@"%d", manCount];
            [m_tabledata addObject:item1];
            
            CellItem * item2 = [CellItem new];
            item2.title = @"Female";
            item2.value = [NSString stringWithFormat:@"%d", girlCount];
            [m_tabledata addObject:item2];
            
            NSMutableArray * tmpArray = [NSMutableArray new];
            for(DBUsers * userItem in users){
                int age = userItem.row_age;
                BOOL alreadyContains = NO;
                for(CellItem * tmpitem in tmpArray){
                    if([tmpitem.title intValue] == age){
                        alreadyContains = YES;
                        tmpitem.value = [NSString stringWithFormat:@"%d", [tmpitem.value intValue] + 1];
                    }
                }
                if(!alreadyContains){
                    CellItem * newItem  = [CellItem new];
                    newItem.title = [NSString stringWithFormat:@"%d", age];
                    newItem.value = @"1";
                    [tmpArray addObject:newItem];
                }
            }
            NSArray * sortedArray = [tmpArray sortedArrayUsingComparator:^NSComparisonResult(CellItem* id1, CellItem* id2){
                float  value1 = [id1.value floatValue];
                float  value2 = [id2.value floatValue];
                if(value1 < value2) return NSOrderedDescending;
                return NSOrderedAscending;
            }];
            for(CellItem * subItem in sortedArray){
                [m_tabledata addObject:subItem];
            }
            if(m_tabledata.count == 1){
                [self.lbl_noData setHidden:NO];
                [self.m_dataTable setHidden:YES];
            }else{
                [self.lbl_noData setHidden:YES];
                [self.m_dataTable reloadData];
            }
            
        } failBlock:^(NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }];
        
    } failBlock:^(NSError*error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
- (void) onReportTips:(NSMutableArray*)array
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    CellItem * new_item = [CellItem new];
    new_item.title = @"Date Time";
    new_item.value = @"Tip";
    [m_tabledata addObject:new_item];
    
    for(PFObject * item in array){
        CellItem * new_item = [CellItem new];
        new_item.title = [CommonAPI convertDateTimeToString:item.updatedAt];
        new_item.value = [NSString stringWithFormat:@"$%.2f", [item[@"tip"] floatValue]];
        [m_tabledata addObject:new_item];
    }
    if(m_tabledata.count == 1){
        [self.lbl_noData setHidden:NO];
        [self.m_dataTable setHidden:YES];
    }else{
        [self.lbl_noData setHidden:YES];
        [self.m_dataTable reloadData];
    }
    [self.m_dataTable reloadData];
    
}
- (void)reloadData:(NSMutableArray*)data
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    m_tabledata = [NSMutableArray new];
    if(self.sortType == 0){
        [self loadStuffReport:data];
    }else if(self.sortType == 1){// hourly
        [self loadHourlyReport:data];
    }else if(self.sortType == 2){// drink
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBOrder getHistoryFrom:self.stDate :self.edDate :^(NSMutableArray * datas, NSError * error){
            [SVProgressHUD dismiss];
            
            for(DBOrder * item in datas){
                BOOL checked = NO;
                for(CellItem * subItem in m_tabledata){
                    if([subItem.title isEqualToString:item.row_drinkname]){
                        subItem.value = [NSString stringWithFormat:@"$%.2f", [subItem.value floatValue] + item.row_orderPrice];
                        checked = YES;
                    }
                }
                if(!checked){
                    CellItem * new_item = [CellItem new];
                    new_item.title = item.row_drinkname;
                    new_item.value = [NSString stringWithFormat:@"$%.2f",item.row_orderPrice];
                    [m_tabledata addObject:new_item];
                }
            }
            CellItem * item = [CellItem new];
            item.title = @"Drink Name";
            item.value = @"Sales";
            [m_tabledata insertObject:item atIndex:0];
            if(m_tabledata.count == 1){
                [self.lbl_noData setHidden:NO];
                [self.m_dataTable setHidden:YES];
            }else{
                [self.lbl_noData setHidden:YES];
                [self.m_dataTable reloadData];
            }
            [self.m_dataTable reloadData];
            
        } failBlock:^(NSError*error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
 
    }else if(self.sortType == 3){// profile
        [self loadProfileReport:data];
    }else if(self.sortType == 4){// fee
        [self onReportTips:data];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onShare:(id)sender {
    if (m_tabledata.count <= 1 ){
        return;
    }
    
    NSString *full;
    NSString *caption = self.m_title;
    full = [NSString stringWithFormat:@"%@",@"\n"];
    full = [full stringByAppendingFormat:@"%@\n\%@\n", self.lbl_title.text, self.lbl_subTitle.text];
    for(int i=1; i< m_tabledata.count; i++) {
        CellItem * new_item = [m_tabledata objectAtIndex:i];
        full = [NSString stringWithFormat:@"%@\n%@ : $%@", full, new_item.title, new_item.value];
    }
    [[UIPasteboard generalPasteboard] setString:caption];
    
    NSArray *items = @[full];
    
    // and present it
    dispatch_async(dispatch_get_main_queue(), ^{
        // build an activity view controller
        UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:@"shareReminder"];
        if(show == NO){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminder" message:@"Some applications don't allow pre-filled captions. To copy your caption, simple paste it in." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Okay, don't remind me again." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shareReminder"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:controller animated:YES completion:^{
                // executes after the user selects something
                [controller presentViewController:alertController animated:YES completion:^{
                    // executes after the user selects something
                }];
            }];
        }else{
            [self presentViewController:controller animated:YES completion:^{
                
            }];
        }
    });
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_tabledata count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.sortType == 0){
        NSString *reuseIdentifier = [NSString stringWithFormat:@"BusinessReportCell3"];
        CellItem * new_item = [m_tabledata objectAtIndex:indexPath.row];
        if(indexPath.row == 0){
            BusinessReportCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            cell.lbl_title.text = new_item.title;
            cell.lbl_value.text = new_item.value;
            cell.lbl_subvalue.text = new_item.subvalue;
            return cell;
        }
        reuseIdentifier = [NSString stringWithFormat:@"BusinessReportCell4"];
        BusinessReportCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.lbl_title.text = new_item.title;
        cell.lbl_value.text = new_item.value;
        cell.lbl_subvalue.text = new_item.subvalue;
        return cell;
    }else{
        NSString *reuseIdentifier = [NSString stringWithFormat:@"BusinessReportCell1"];
        CellItem * new_item = [m_tabledata objectAtIndex:indexPath.row];
        if(indexPath.row == 0){
            BusinessReportCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            cell.lbl_title.text = new_item.title;
            cell.lbl_value.text = new_item.value;
            return cell;
        }
        reuseIdentifier = [NSString stringWithFormat:@"BusinessReportCell2"];
        BusinessReportCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.lbl_title.text = new_item.title;
        cell.lbl_value.text = new_item.value;
        return cell;
    }
    return nil;
}

- (UIImage*) imageWithTableView:(UITableView*)tableView
{
    UIImage * image = nil;
    UIGraphicsBeginImageContextWithOptions(tableView.contentSize, NO, 0.0);
    CGPoint samvedContentOffSet = tableView.contentOffset;
    CGRect savedFrame = tableView.frame;
    tableView.contentOffset = CGPointZero;
    tableView.frame = CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height);
    [tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    tableView.contentOffset = samvedContentOffSet;
    tableView.frame = savedFrame;
    UIGraphicsEndImageContext();
    return image;
}
- (IBAction)saveImage:(id)sender {
    if (m_tabledata.count >0 ){
        UIImage * image = [self imageWithTableView:self.m_dataTable];
        if(image){
          
            
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
            [Util showAlertTitle:self title:@"Report" message:@"Report saved." finish:^(void){}];
            
            
            
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        // handle error
    }
    else
    {
        // handle ok status
    }
}

@end
