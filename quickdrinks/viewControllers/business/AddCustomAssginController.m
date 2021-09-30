//
//  AddCustomAssginController.m
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "AddCustomAssginController.h"
#import "CustomAssignCell.h"
#import "DBCong.h"
#import "DBAssignItem.h"

@interface AddCustomAssginController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray * m_staffArray;
    NSMutableArray * m_tableArray;
    NSMutableArray * m_customArray;
    
    NSMutableArray * m_containsTables;
}
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;

@end

@implementation AddCustomAssginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_staffArray = [NSMutableArray new];
    m_tableArray = [NSMutableArray new];
    m_containsTables = [NSMutableArray new];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBAssignItem getAssignItemsWithUserId:defaultUser.row_id :^(id returnItem, NSError * error){
        
        for (DBAssignItem * item in returnItem) {
            if(item.type == 0)
                [m_staffArray addObject:item];
            else{
                [m_tableArray addObject:item];
                NSString * name = [item title];
                name = [name stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
                [m_containsTables addObject:name];
                NSLog(@"table:%@", name);
            }
        }
        [DBCustomAssign getCustomAssignItemsWithUserId:defaultUser.row_id :^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            m_customArray = returnItem;
            [self.m_dataTable reloadData];
            
        } failBlock:^( NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }];
    } failBlock:^( NSError * error){
        
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
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
- (IBAction)onDone:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    for(DBCustomAssign * item in m_customArray){
        
        NSString * row_assignName = item.row_name;
        NSString * row_tables = item.row_tableNumbers;
        
        if(row_assignName.length == 0 && row_tables.length == 0){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Please input staff name and table number"] finish:^(void) {
                CustomAssignCell * cell = [self.m_dataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[m_customArray indexOfObject:item] inSection:0]];
                if(cell.edt_staffName){
                    [cell.edt_staffName becomeFirstResponder];
                }
            }];
            return;
        }
        
        if(row_assignName.length == 0){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Please input staff name for table %@.", row_tables] finish:^(void) {
            }];
            return;
        }
        if(row_assignName.length < 3){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"staff name \"%@\" is too short.", row_assignName] finish:^(void) {
            }];
            return;
        }
        if(row_assignName.length > 10){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"staff name \"%@\" is too long.", row_assignName] finish:^(void) {
            }];
            return;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ, 1234567890"] invertedSet];
        if ([row_assignName rangeOfCharacterFromSet:set].location != NSNotFound){
            [Util showAlertTitle:nil title:@"" message:@"Name can't contain emoji and special characters." finish:^(void) {
            }];
            return;
        }
        
        
        row_tables =  [row_tables stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(row_tables.length == 0){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Please input table number for staff \"%@\"", row_assignName] finish:^(void) {
            }];
            return;
        }
        
        NSArray * tableNames = [row_tables componentsSeparatedByString:@","];
        if(tableNames && tableNames.count > 0){
            for(NSString * item in tableNames){
                NSString * checkItem = [item stringByReplacingOccurrencesOfString:@" " withString:@""];
                if(![self arrayContainsString:checkItem :m_containsTables]){
                    [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! Table %@ doesn't exist.",checkItem] finish:^(void) {
                    }];
                    return;
                }
            }
        }
    }

    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [DBCustomAssign removeAllAssignForUser:defaultUser.row_id :^(NSError * error){
        for(DBCustomAssign * item in m_customArray){
            int index = [m_customArray indexOfObject:item];
            NSString * row_tables = item.row_tableNumbers;
            NSString * row_name = item.row_name;
            if([row_name isEqualToString:@""] || [row_tables isEqualToString:@""]){
                continue;
            }
            item.userId = defaultUser.row_id;
            item.row_name = row_name;
            item.row_tableNumbers = row_tables;
            
            [DBCustomAssign addAsginItemInfo:item];
            
        }
        
        [SVProgressHUD dismiss];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    
}
- (IBAction)onAddMoreStuff:(id)sender {
    DBCustomAssign * lastitem = [m_customArray lastObject];
    if(lastitem){
        if([lastitem.row_name isEqualToString:@""] && [lastitem.row_tableNumbers isEqualToString:@""])
            return;
    }
    
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    DBCustomAssign * newItem = [DBCustomAssign new];
    newItem.userId = defaultUser.row_id;
    newItem.row_name = @"";
    newItem.row_tableNumbers = @"";
    
    [m_customArray addObject:newItem];
    
    [self.m_dataTable reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_customArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 138;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"CustomAssignCell"];
    CustomAssignCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        cell.edt_staffName.delegate = self;
        cell.edt_staffName.tag = indexPath.row *10 + 0;
        cell.edt_tableNumbers.delegate = self;
        cell.edt_tableNumbers.tag = indexPath.row * 10 + 1;
        
        if(m_customArray.count > indexPath.row){
            DBCustomAssign * item = [m_customArray objectAtIndex:indexPath.row];
            [cell.edt_staffName setText:item.row_name];
            [cell.edt_tableNumbers setText:item.row_tableNumbers];
        }
    }
    return cell;
}
- (BOOL) arrayContainsString:(NSString*)str :(NSArray*)array
{
    for(NSString * subItem in array){
        if([subItem isEqualToString:str]){
            return YES;
        }
    }
    return NO;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    CGSize contentSize = [self.m_dataTable contentSize];
    contentSize.height = [m_customArray count] * 138 + 216;
    [self.m_dataTable setContentSize:contentSize];
    
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString*  str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [Util trim:str];
    if([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ 1234567890,"].invertedSet].location != NSNotFound){
        return NO;
    }
    int rowIndex = textField.tag / 10;
    int tagIndex = textField.tag % 10;
    if(tagIndex == 0){
        if(str.length > 10){
            return NO;
        }
    }
    DBCustomAssign * currentCustom = [m_customArray objectAtIndex:rowIndex];
    if(tagIndex == 0){
        currentCustom.row_name = str;
    } else if (tagIndex == 1){
        currentCustom.row_tableNumbers = str;
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    int rowIndex = textField.tag / 10;
    int tagIndex = textField.tag % 10;
    
    
    NSString * textFiledText = [Util trim:textField.text];
    
    DBCustomAssign * currentCustom = [m_customArray objectAtIndex:rowIndex];
    if(tagIndex == 0){
        currentCustom.row_name = textFiledText;
    } else if (tagIndex == 1){
        currentCustom.row_tableNumbers = textFiledText;
    }
    
    if(tagIndex == 0){
        if ([textFiledText isEqualToString:@""]) {
            CGSize contentSize = [self.m_dataTable contentSize];
            contentSize.height = [m_customArray count] * 138;
            [self.m_dataTable setContentSize:contentSize];
            return YES;
        }
        if(textFiledText.length < 3){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! staff name is too short"] finish:^(void) {
                [textField setText:@""];
                currentCustom.row_name = textFiledText;
            }];
            return NO;
        }
        if(textFiledText.length > 10){
            [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! staff name is too long"] finish:^(void) {
                [textField setText:@""];
                currentCustom.row_name = textFiledText;
            }];
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ 1234567890,"] invertedSet];
        if ([textField.text rangeOfCharacterFromSet:set].location != NSNotFound){
            [Util showAlertTitle:nil title:@"" message:@"Name can't contain emoji and special characters." finish:^(void) {
                [textField setText:@""];
                currentCustom.row_name = textFiledText;
            }];
            return NO;
        }

        for(DBCustomAssign * item in m_customArray){
            int index  = [m_customArray indexOfObject:item];
            if(index != rowIndex){
                if([item.row_name isEqualToString:textFiledText]){
                    [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! staff name is already exist"] finish:^(void) {
                        [textField setText:@""];
                        currentCustom.row_name = textFiledText;
                    }];
                    return NO;
                }
            }
        }
    }
    
    if(tagIndex == 1){
        if ([textFiledText isEqualToString:@""]) {
            CGSize contentSize = [self.m_dataTable contentSize];
            contentSize.height = [m_customArray count] * 138;
            [self.m_dataTable setContentSize:contentSize];
            return YES;
            return YES;
        }
        NSArray * tableNames = [textFiledText componentsSeparatedByString:@","];
        if(tableNames && tableNames.count > 0){
            for(NSString * item in tableNames){
                NSString * checkItem = [item stringByReplacingOccurrencesOfString:@" " withString:@""];
                if(![self arrayContainsString:checkItem :m_containsTables]){
                    [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! Table %@ doesn't exist.",checkItem] finish:^(void) {
                        [textField setText:@""];
                        currentCustom.row_tableNumbers = textFiledText;
                    }];
                    return NO;
                }
            }
        }
        NSMutableArray * m_alreadyContainsTables = [NSMutableArray new];
        for(DBCustomAssign * item in m_customArray){
            int index  = [m_customArray indexOfObject:item];
            if(index != rowIndex){
                NSArray * tableNames = [item.row_tableNumbers componentsSeparatedByString:@","];
                for(NSString * str in tableNames){
                    if(str.length > 0){
                        [m_alreadyContainsTables addObject:str];
                    }
                }
            }
        }
        ////
        if(tableNames && tableNames.count > 0){
            for(NSString * item in tableNames){
                for(NSString * recentItem in m_alreadyContainsTables){
                    if([item isEqualToString:recentItem]){
                        [Util showAlertTitle:nil title:@"" message:[NSString stringWithFormat:@"Oops! Table %@ is already exist.",item] finish:^(void) {
                            [textField setText:@""];
                            currentCustom.row_tableNumbers = textFiledText;
                        }];
                        return NO;
                    }
                }
            }
        }
    }
    [textField resignFirstResponder];
    CGSize contentSize = [self.m_dataTable contentSize];
    contentSize.height = [m_customArray count] * 138;
    [self.m_dataTable setContentSize:contentSize];
    return YES;
    return YES;
}
@end
