//
//  NewAssignmentController.m
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "NewAssignmentController.h"
#import "AssignActionView.h"
#import "DBCong.h"
#import "SCLAlertView.h"
#import "SCLTextView.h"
@interface NewAssignmentController ()<AssignActionViewDelegate, UITextFieldDelegate>
{
    NSMutableArray * m_containActions;
    NSMutableArray * m_containItems;
    NSMutableArray * m_containRects;
    
    AssignActionView * activeView;
    
    NSMutableArray  * m_customStaffs;
    
    UITextField * tmptextfield;
    
    NSString * recentname;
}
@property (strong, nonatomic) IBOutlet UIButton *btn_text;

@property (strong, nonatomic) IBOutlet UIView *m_actionView;
@end

@implementation NewAssignmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
      return;
    }
    [self.btn_text setEnabled:NO];
    tmptextfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    tmptextfield.delegate = self;
    tmptextfield.returnKeyType = UIReturnKeyDone;
    [self.m_actionView addSubview:tmptextfield];
    
    m_containRects = [NSMutableArray new];
    
    [self displayItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) displayItems
{
    for(UIView * subview in self.m_actionView.subviews){
        [subview removeFromSuperview];
    }
    m_containActions = [NSMutableArray new];
    m_containItems = [NSMutableArray new];
    
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBCustomAssign getCustomAssignItemsWithUserId:defaultUser.row_id :^(id returnItem, NSError * error){
        m_customStaffs = returnItem;
        
        [DBAssignItem getAssignItemsWithUserId:defaultUser.row_id :^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            for (DBAssignItem * item in returnItem) {
                [m_containItems addObject:item];
                if(item.type == 0)
                    [self addRectView:item];
                else
                    [self addCircleView:item];
            }
            
        } failBlock:^( NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    } failBlock:^( NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
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
- (int) getTableCount
{
    int i = 0;
    for(AssignActionView * subview in m_containActions){
        DBAssignItem * item = [subview getInfo];
        if(item.type == 1)
            i++;
    }
    return i+1;
}
- (CGRect) getDefaultRectForRect
{
    CGRect item = CGRectZero;
    item.origin.x = 20/self.m_actionView.frame.size.width;
    item.origin.y = self.m_actionView.center.y / self.m_actionView.frame.size.width;
    item.size.width= (self.m_actionView.frame.size.width - 40) / self.m_actionView.frame.size.width;
    item.size.height = 80 / self.m_actionView.frame.size.width;
    return item;
}
- (CGRect) getDefaultRectForCircle
{
    CGRect item = CGRectZero;
    item.origin.x = 20/self.m_actionView.frame.size.width;
    item.origin.y = self.m_actionView.center.y / self.m_actionView.frame.size.width;
    item.size.width = 60 / self.m_actionView.frame.size.width;;
    item.size.height = 60 / self.m_actionView.frame.size.width;
    return item;
}
- (CGRect) getViewRectFrom:(DBAssignItem*)item
{
    CGRect rect = CGRectZero;
    rect.origin.x = item.pos_x;
    rect.origin.y = item.pos_y;
    rect.size.width = item.width;
    rect.size.height = item.height;
    return rect;
}
- (void) addRectView:(DBAssignItem*)item
{
    AssignActionView * actionview = [AssignActionView new];
    actionview.tag = [m_containActions count];
    actionview.delegate = self;
    [m_containActions addObject:actionview];
    [self.m_actionView addSubview:actionview];
    [actionview initWithType:item];
    
    int index = (int)[m_containItems indexOfObject:item];
    if(m_containRects.count <= index){
        [m_containRects addObject:[NSValue valueWithCGRect:[self getViewRectFrom:item]]];
    }else{
        CGRect viewRect = [[m_containRects objectAtIndex:index] CGRectValue];
        viewRect.origin.x *= self.m_actionView.frame.size.width;
        viewRect.origin.y *= self.m_actionView.frame.size.width;
        viewRect.size.width *= self.m_actionView.frame.size.width;
        viewRect.size.height *= self.m_actionView.frame.size.width;
        [actionview setFrame:viewRect];
    }
}
- (void) addCircleView:(DBAssignItem*)item
{
    AssignActionView * actionview = [AssignActionView new];
    actionview.tag = [m_containActions count];
    actionview.delegate = self;
    [m_containActions addObject:actionview];
    
    [self.m_actionView addSubview:actionview];
    [actionview initWithType:item];
    
    
    int index = (int)[m_containItems indexOfObject:item];
    if(m_containRects.count <= index){
        [m_containRects addObject:[NSValue valueWithCGRect:[self getViewRectFrom:item]]];
    }else{
        CGRect viewRect = [[m_containRects objectAtIndex:index] CGRectValue];
        viewRect.origin.x *= self.m_actionView.frame.size.width;
        viewRect.origin.y *= self.m_actionView.frame.size.width;
        viewRect.size.width *= self.m_actionView.frame.size.width;
        viewRect.size.height *= self.m_actionView.frame.size.width;
        [actionview setFrame:viewRect];
    }
    
    for(DBCustomAssign * customitem in m_customStaffs){
        NSString * tables = [customitem row_tableNumbers];
        NSString * name = [item title];
        name = [name stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
        NSArray * tableNames = [tables componentsSeparatedByString:@","];
        if(tableNames && tableNames.count > 0){
            for(NSString * item in tableNames){
                if([item isEqualToString:name]){
                    actionview.m_staffnameLabel.text = customitem.row_name;
                    return;
                }
            }
        }
    }
    
}

- (IBAction)onClickRect:(id)sender {
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    DBAssignItem * item = [DBAssignItem new];
    item.user_id = defaultUser.row_id;
    item.pos_x = 20/self.m_actionView.frame.size.width;
    item.pos_y = self.m_actionView.center.y / self.m_actionView.frame.size.width;
    item.width = (self.m_actionView.frame.size.width - 40) / self.m_actionView.frame.size.width;
    item.height = 80 / self.m_actionView.frame.size.width;
    item.title = @"";
    item.type = 0;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBAssignItem addAsginItemInfo:item :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        if(error){
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayItems];
            });
        }
    }];
}
- (IBAction)onClickCircle:(id)sender {
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    DBAssignItem * item = [DBAssignItem new];
    item.user_id = defaultUser.row_id;
    item.pos_x = 20/self.m_actionView.frame.size.width;
    item.pos_y = self.m_actionView.center.y / self.m_actionView.frame.size.width;
    item.width = 80 / self.m_actionView.frame.size.width;;
    item.height = 80 / self.m_actionView.frame.size.width;
    item.title = [NSString stringWithFormat:@"Table\n%d", [self getTableCount]];
    item.type = 1;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBAssignItem addAsginItemInfo:item :^(id val, NSError * error){
        [SVProgressHUD dismiss];
        if(error){
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayItems];
            });
        }
    }];
}
- (IBAction)onClickText:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    NSString *title = @"Title";
    SCLTextView *nameView = [alert addTextField:@"title"];
    [nameView setTextAlignment:NSTextAlignmentCenter];
    nameView.tintColor = MAIN_COLOR;
    nameView.secureTextEntry = NO;
    nameView.keyboardType = UIKeyboardTypeNamePhonePad;
    nameView.text = activeView.m_titleLabel.text;
    
    NSString * recentName = activeView.m_titleLabel.text;
    
    if(activeView.m_info.type == 1){
        NSString * name = activeView.m_titleLabel.text;
        name = [name stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
        nameView.text = name;
    }
    
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    
    [alert addButton:@"Confirm" validationBlock:^BOOL {
        NSString *name = [Util trim:nameView.text];
        [nameView resignFirstResponder];
        if (name.length < 1) {
            [Util showAlertTitle:nil title:@"" message:@"Oops! Name is too short." finish:^(void) {
                [nameView becomeFirstResponder];
            }];
            return NO;
        }
        if (name.length > 50) {
            [Util showAlertTitle:nil title:@"" message:@"Oops! Name is too long." finish:^(void) {
                [nameView becomeFirstResponder];
            }];
            return NO;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ 1234567890"] invertedSet];
        if ([name rangeOfCharacterFromSet:set].location != NSNotFound){
            [Util showAlertTitle:nil title:@"" message:@"Name can't contain emoji and special characters." finish:^(void) {
                [nameView becomeFirstResponder];
            }];
            return NO;
        }
        
        for(AssignActionView * _actionView in m_containActions){
            if(activeView != _actionView){
                if(activeView.m_info.type == _actionView.m_info.type){
                    NSString * othername = [_actionView.m_titleLabel.text stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
                    if([othername isEqualToString:nameView.text]){
                        [Util showAlertTitle:nil title:@"" message:@"Oops! same table name exists." finish:^(void) {
                            [nameView setText:recentName];
                            [nameView becomeFirstResponder];
                        }];
                        return NO;
                    }
                }
            }
        }
        
        return YES;
    } actionBlock:^(void) {
        NSString *rename = [Util trim:nameView.text];
        if(activeView.m_info.type == 1){
            rename = [NSString stringWithFormat:@"Table\n%@", rename];
        }
        recentname = activeView.m_info.title;
        activeView.m_info.title = rename;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBAssignItem updateAsginItemInfo:activeView.m_info :^(BOOL res, NSError * error){
            [SVProgressHUD dismiss];
            if(res){
                if(activeView.m_info.type == 0){
                    [self displayItems];
                }else{
                    ///// check
                    BOOL checked = NO;
                    for(DBCustomAssign * customitem in m_customStaffs){
                        NSString * tables = [customitem row_tableNumbers];
                        NSString * name = recentname;
                        name = [name stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
                        NSArray * tableNames = [tables componentsSeparatedByString:@","];
                        if(tableNames && tableNames.count > 0){
                            for(NSString * item in tableNames){
                                if([item isEqualToString:name]){
                                    checked = YES;
                                    ////// delete custom item
                                    NSString * newTables = @"";
                                    for (NSString * subitem in tableNames) {
                                        if([subitem isEqualToString:name]){
                                            NSString * str = activeView.m_info.title;
                                            str = [str stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
                                            newTables = [newTables stringByAppendingFormat:@"%@,", str];
                                        }else{
                                            newTables = [newTables stringByAppendingFormat:@"%@,", subitem];
                                        }
                                    }
                                    newTables = [newTables substringToIndex:newTables.length - 1];
                                    customitem.row_tableNumbers = newTables;
                                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                                    [DBCustomAssign updateItemTableInfo:customitem :^(BOOL res, NSError* error){
                                        [SVProgressHUD dismiss];
                                        if(res){
                                            [self displayItems];
                                        }else{
                                            [SVProgressHUD dismiss];
                                            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                                        }
                                    }];
                                }
                                if(checked)
                                    break;
                            }
                            if(checked)
                                break;
                        }
                        if(checked)
                            break;
                    }
                    if(!checked)
                        [self displayItems];
                }
                
            }else{
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }
        }];
        
    }];
    
    [alert showEdit:self title:@"" subTitle:title closeButtonTitle:nil duration:0.0f];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [activeView setText:textField.text];
    [textField resignFirstResponder];
    [self.btn_text setEnabled:NO];
    [textField setText:@""];
    return YES;
}
- (IBAction)onNext:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if(!m_containActions || m_containActions.count == 0){
        [Util showAlertTitle:self title:@"Drink" message:@"Please input staff assignments"];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self updateAsignItem:m_containActions atIndex:0 complete:^(id returnItem){
        [self performSegueWithIdentifier:@"EditStaffAssign" sender:self];
    }];
}

- (void) updateAsignItem:(NSMutableArray * )items atIndex:(int)index complete:(void (^)(id returnItem))sucessblock
{
    if(index == items.count){
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            sucessblock(nil);
        });
    }else{
        AssignActionView * subview = [m_containActions objectAtIndex:index];
        CGRect asignPosition = [[m_containRects objectAtIndex:index] CGRectValue];
        DBAssignItem * item = [subview getInfo];
        item.pos_x = asignPosition.origin.x;
        item.pos_y = asignPosition.origin.y;
        item.width = asignPosition.size.width;
        item.height = asignPosition.size.height;
        [DBAssignItem updateAsginItemInfo:item :^(BOOL res, NSError * error){
            if(res){
                [self updateAsignItem:m_containActions atIndex:index+1 complete:sucessblock];
            }else{
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            }
        }];
    }
}

- (IBAction)onBack:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self updateAsignItem:m_containActions atIndex:0 complete:^(id returnItem){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (void)AssignActionViewDelegate_longPressed:(UIView *)view
{
    activeView = (AssignActionView*)view;
    [self.btn_text setEnabled:YES];
}
- (void) AssignActionViewDelegate_deleted:(UIView *)view
{
    activeView = (AssignActionView*)view;
    int index = (int)[m_containActions indexOfObject:view];
    /////// delete//////
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBAssignItem * item = [activeView getInfo];
    [DBAssignItem removeAsginItemIndex:item.row_id :^(BOOL res, NSError* error){
        [SVProgressHUD dismiss];
        if(res){
            for(DBCustomAssign * customitem in m_customStaffs){
                NSString * tables = [customitem row_tableNumbers];
                NSString * name = [item title];
                name = [name stringByReplacingOccurrencesOfString:@"Table\n" withString:@""];
                NSArray * tableNames = [tables componentsSeparatedByString:@","];
                if(tableNames && tableNames.count > 0){
                    for(NSString * item in tableNames){
                        if([item isEqualToString:name]){
                            ////// delete custom item
                            [DBCustomAssign removeAssignItem:customitem];
                        }
                    }
                }
            }
            [m_containRects removeObjectAtIndex:index];
            [self displayItems];
        }else{
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        }
    }];
    
}
- (void) AssignActionViewDelegate_locationChanged:(AssignActionView *)view
{
    CGRect viewRect = view.frame;
    viewRect.origin.x = viewRect.origin.x/self.m_actionView.frame.size.width;
    viewRect.origin.y = viewRect.origin.y/self.m_actionView.frame.size.width;
    viewRect.size.width = viewRect.size.width/self.m_actionView.frame.size.width;
    viewRect.size.height = viewRect.size.height/self.m_actionView.frame.size.width;
    int index = (int)[m_containItems indexOfObject:view.m_info];
    if(m_containRects.count > index){
        [m_containRects replaceObjectAtIndex:index withObject:[NSValue valueWithCGRect:viewRect]];
    }
}
@end
