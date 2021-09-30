//
//  BusinessOrdersController.m
//  quickdrinks
//  tracy19890721@163.com
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.

///showInforViewFromCustom
//

#import "BusinessOrdersController.h"
#import "BusinessOrderTableViewCell.h"
#import "DBCong.h"
#import "Util.h"
#import "BusinessInstructionController.h"
#import "BusinessOrderProcessCell.h"

@interface BusinessOrdersController () <UITableViewDelegate, UITableViewDataSource, BusinessOrderProcessCellDelegate>
{
    NSMutableArray * m_orderlist;
    NSMutableArray * m_infolist;
    
    PFObject * m_selectedOrder;
    NSString * m_senderName;
    NSString * m_instruction;
    NSString * m_drinkRecipe;
    
    NSTimer * getOrderTimer;
    int instructionType;
}
@property (weak, nonatomic) IBOutlet UITableView *m_dataTable;
@end

@implementation BusinessOrdersController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.m_dataTable setAllowsSelection:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTable];
//    getOrderTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(getOrders) userInfo:nil repeats:YES];
    getOrderTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getOrders) userInfo:nil repeats:YES];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [getOrderTimer invalidate];
}

- (NSMutableArray *) showData:(int)index
{
    PFObject * order = [m_orderlist objectAtIndex:index];
    
    NSMutableArray * categoryNames = [[NSMutableArray alloc] initWithObjects:@"Beers", @"Cocktails",@"Wines",@"Speciality Drinks", @"Non-Alcoholic Drinks", nil];
    NSMutableArray * categoryIds = order[@"categories"];
    NSMutableArray * titles = order[@"names"];
    NSMutableArray * descriptions = order[@"descriptions"];
    NSMutableArray * drinkIds = order[@"drinkIds"];
    
    NSMutableArray * titleArray = [NSMutableArray new];
    NSMutableArray * stringArray = [NSMutableArray new];
    for(int numIndex = 0;numIndex<categoryIds.count;numIndex++){
        NSNumber * number = [categoryIds objectAtIndex:numIndex];
        //    for(NSNumber * number in categoryIds){
        BOOL categoryAdd = NO;
        for(NSNumber * subNum in titleArray){
            if(subNum.intValue == number.intValue){
                int index = [titleArray indexOfObject:subNum];
                NSMutableArray * itemArray = [stringArray objectAtIndex:index];
                [itemArray addObject:[titles objectAtIndex:numIndex]];
                categoryAdd = YES;
            }
        }
        if(!categoryAdd){
            [titleArray addObject:number];
            NSMutableArray * array = [NSMutableArray new];
            [stringArray addObject:array];
            NSMutableArray * itemArray = [stringArray lastObject];
            [itemArray addObject:[titles objectAtIndex:[categoryIds indexOfObject:number]]];
        }
    }


    NSMutableArray * returnValue = [NSMutableArray new];
    for(int i = 0;i<[titleArray count];i++){
        [returnValue addObject:[categoryNames objectAtIndex:[[titleArray objectAtIndex:i] intValue] - 1]];
        NSMutableArray * stringarray = [stringArray objectAtIndex:i];
        for(int j=0;j<stringarray.count;j++){
            NSString * str = [stringarray objectAtIndex:j];
            [returnValue addObject:[[NSMutableArray alloc] initWithObjects:str, [descriptions objectAtIndex:[titles indexOfObject:str]], [drinkIds objectAtIndex:[titles indexOfObject:str]], nil]];
        }
    }
    
    return returnValue;
}

- (void)reloadTable
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    
    PFQuery * query = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query whereKey:@"owner_id" equalTo:defaultUser.row_id];
    [query whereKey:@"step" lessThan:[NSNumber numberWithInteger:SYSTEM_ORDER_DELETED]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        [SVProgressHUD dismiss];
        if(!error){
            m_orderlist = [[NSMutableArray alloc] initWithArray:objects];
            m_infolist = [NSMutableArray new];
            for(int i=0;i<m_orderlist.count;i++){
                [m_infolist addObject:[self showData:i]];
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                 [self.m_dataTable reloadData];
                [super tableChecker:self.m_dataTable];
            });
           
        }
        
    }];
    
}

- (void) getOrders
{
    NSLog(@"getOrders");
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery * query = [PFQuery queryWithClassName:DB_ORDER_ITEM];
    [query whereKey:@"owner_id" equalTo:defaultUser.row_id];
    [query whereKey:@"step" lessThan:[NSNumber numberWithInteger:SYSTEM_ORDER_DELETED]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        if(!error){
            if(objects.count != m_orderlist.count){
                m_orderlist = [[NSMutableArray alloc] initWithArray:objects];
                m_infolist = [NSMutableArray new];
                for(int i=0;i<m_orderlist.count;i++){
                    [m_infolist addObject:[self showData:i]];
                }
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.m_dataTable reloadData];
                    [super tableChecker:self.m_dataTable];
                });
            }
            
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_orderlist count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"BusinessOrderProcessCell";
    BusinessOrderProcessCell * cell = (BusinessOrderProcessCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell layoutIfNeeded];
    
    NSMutableArray * infoData = [m_infolist objectAtIndex:indexPath.row];
    return [BusinessOrderProcessCell getCellHeightWithValue:infoData];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject * order = [m_orderlist objectAtIndex:indexPath.row];
    NSString *reuseIdentifier = @"BusinessOrderProcessCell";
    BusinessOrderProcessCell * cell = (BusinessOrderProcessCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        dispatch_async(dispatch_get_main_queue(), ^(){
            cell.delegate = self;
            if([order[@"sendType"] intValue] == 0){
                NSString * courseName = order[@"courseName"];
                NSString * laneNum = order[@"laneNum"];
                cell.lbl_tableNum.text = [NSString stringWithFormat:@"%@ \n%@", courseName, laneNum];
            }else{
                cell.lbl_tableNum.text = @"Bar";
            }
            [cell.lbl_time setText:[self calcAgoTime:order.updatedAt]];
            NSMutableArray * infoData = [m_infolist objectAtIndex:indexPath.row];
            [cell initWithData:infoData];
            
            [cell.lbl_name setText:@""];
            
            [DBUsers getUserInfoFromUserId:order[@"sender_id"] sucessBlock:^(DBUsers * val, NSError * error){
                [Util setImage:cell.img_user imgUrl:val.row_userPhoto];
                [cell.lbl_name setText:val.row_userName];
            } failBlock:^(NSError*error){
            }];
            cell.img_user.layer.cornerRadius = cell.img_user.frame.size.width/2;
            
            NSNumber * step = order[@"step"];
            if(step.intValue == SYSTEM_ORDER_CREATED){// start
                [cell.btn_order setTitle:@"START THE ORDER" forState:UIControlStateNormal];
            }else if(step.intValue == SYSTEM_ORDER_STARTED){//complete
                [cell.btn_order setTitle:@"ORDER COMPLETE" forState:UIControlStateNormal];
            }else if(step.intValue > SYSTEM_ORDER_STARTED){//close
                [cell.btn_order setTitle:@"CLOSE ORDER" forState:UIControlStateNormal];
            }
            
            [cell setNeedsDisplay];
        });
    }
    return cell;
}

- (void) BusinessOrderTableViewCellDelegate_actionAtCell:(UITableViewCell *)cell
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int index = (int)[self.m_dataTable indexPathForCell:cell].row;
    m_selectedOrder = [m_orderlist objectAtIndex:index];
    int style = [m_selectedOrder[@"step"] intValue];
    if(style > SYSTEM_ORDER_STARTED)//close order
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        PFObject *obj = [PFObject objectWithClassName:DB_ORDER_ITEM];
        obj[@"step"] = [NSNumber numberWithInt:SYSTEM_ORDER_DELETED];
        obj.objectId = m_selectedOrder.objectId;
        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if(succeed){
                [self reloadTable];
            }else{
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }
            
        }];
    }else if(style == SYSTEM_ORDER_STARTED)// order complete
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        PFObject *obj = [PFObject objectWithClassName:DB_ORDER_ITEM];
        obj[@"step"] = [NSNumber numberWithInt:SYSTEM_ORDER_COMPLETE];
        obj.objectId = m_selectedOrder.objectId;
        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if(succeed){
                [self reloadTable];
                
                NSString * notifyStr = @"Ready to pick up";
                if([m_selectedOrder[@"sendType"] intValue] == 1){
                    notifyStr = @"Ready to send to table";
                }
                [DBNotification sendNotification:m_selectedOrder[@"sender_id"] :notifyStr :m_selectedOrder.objectId];
                
            }else{
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }
            
        }];
    
    }else if(style == SYSTEM_ORDER_CREATED)// start order
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        PFObject *obj = [PFObject objectWithClassName:DB_ORDER_ITEM];
        obj[@"step"] = [NSNumber numberWithInt:SYSTEM_ORDER_STARTED];
        obj.objectId = m_selectedOrder.objectId;
        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if(succeed){
                [DBNotification sendNotification:m_selectedOrder[@"sender_id"] :[NSString stringWithFormat:@"Order started"] :m_selectedOrder.objectId];
                [self reloadTable];
            }else{
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }
            
        }];
        
    }else if(style == 3)// drink instruction
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getUserInfoFromUserId:m_selectedOrder[@"sender_id"] sucessBlock:^(DBUsers * val, NSError * error){
            [SVProgressHUD dismiss];
            m_senderName = val.row_userName;
            [self performSegueWithIdentifier:@"showInstruction" sender:self];
        } failBlock:^(NSError*error){
            [SVProgressHUD dismiss];
        }];
        
    }
}
- (void) BusinessOrderTableViewCellDelegate_actionAtCellInstruction:(UITableViewCell *)cell :(NSString *)instruction
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int index = (int)[self.m_dataTable indexPathForCell:cell].row;
    m_selectedOrder = [m_orderlist objectAtIndex:index];
    
    m_instruction = @"";
    m_instruction = instruction;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:m_selectedOrder[@"sender_id"] sucessBlock:^(DBUsers * val, NSError * error){
        [SVProgressHUD dismiss];
        m_senderName = val.row_userName;
        instructionType = DRINK_INSTRUCTION;
        [self performSegueWithIdentifier:@"showInstruction" sender:self];
    } failBlock:^(NSError*error){
        [SVProgressHUD dismiss];
    }];
}
- (void) BusinessOrderTableViewCellDelegate_actionAtCellNoInstruction:(UITableViewCell *)cell :(NSString *)instruction
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int index = (int)[self.m_dataTable indexPathForCell:cell].row;
    m_selectedOrder = [m_orderlist objectAtIndex:index];
    
    m_instruction = @"";
    m_instruction = instruction;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:m_selectedOrder[@"sender_id"] sucessBlock:^(DBUsers * val, NSError * error){
        [SVProgressHUD dismiss];
        m_senderName = val.row_userName;
        instructionType = DRINK_INSTRUCTION;
        [self performSegueWithIdentifier:@"showInstruction" sender:self];
    } failBlock:^(NSError*error){
        [SVProgressHUD dismiss];
    }];
}
- (void) BusinessOrderTableViewCellDelegate_actionAtCellDrinkRecipe:(UITableViewCell *)cell :(NSString *)drinkId
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    int index = (int)[self.m_dataTable indexPathForCell:cell].row;
    m_selectedOrder = [m_orderlist objectAtIndex:index];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFObject * object  = [PFObject objectWithClassName:TBL_NAME_DRINKS];
    object.objectId = drinkId;
    [object fetchInBackgroundWithBlock:^(PFObject * drinkItem, NSError * error){
        m_drinkRecipe = @"";
        m_drinkRecipe = drinkItem[TBL_DRINKS_INSTRUCTION];
        [SVProgressHUD dismiss];
        m_senderName = drinkItem[@"name"];
        instructionType = DRINK_RECIPE;
        [self performSegueWithIdentifier:@"showInstruction" sender:self];
    }];
}
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([segue.identifier isEqualToString:@"showInstruction"]){
         BusinessInstructionController * controller = (BusinessInstructionController*)[segue destinationViewController];
         controller.m_str = m_instruction;
         controller.m_recipe = m_drinkRecipe;
         controller.m_title = m_senderName;
         controller.instructionType = instructionType;
     }
 }

@end
