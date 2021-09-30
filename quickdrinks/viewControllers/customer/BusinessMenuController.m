//
//  BusinessMenuController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessMenuController.h"
#import "BusinessItemTableViewCell.h"
#import "CustomComboBox.h"
#import "AddOrderDlg.h"
#import "DBCong.h"
#import "Util.h"
#import "BusinessAddDrinkType1Controller.h"
#import "BusinessAddDrinkType2Controller.h"
#import "BusinessAddDrinkType3Controller.h"
#import "BusinessAddDrinkType4Controller.h"
#import "BusinessAddDrinkType5Controller.h"

@interface BusinessMenuController () <UITableViewDelegate, UITableViewDataSource,CustomComboBox_SelectedItem, BusinessItemTableViewCellDelegate>
{
    NSMutableArray * m_containsString1;
    NSMutableArray * m_containsString2;
    
    int selectedcombostyle_1;
    int selectedcombostyle_2;
    int selectedcombostyle_3;
    
    NSMutableArray * m_itemArray;
    int tableItemCount;
    
    int current_category;
    int current_sub_category;
    
    
    DrinkItem * m_editItem;
}

@property (strong, nonatomic) IBOutlet UIView *m_comboMenu;
@property (strong, nonatomic) IBOutlet UIView *m_comboSubCategory;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_1;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_2;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_3;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_4;
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet AddOrderDlg *addOrderDlg;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstance;
@end

@implementation BusinessMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.m_dataTable reloadData];
    
    m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Beers", @"Cocktails",@"Wines",@"Speciality Drinks", @"Non-Alcoholic Drinks", nil];
    
    
    self.m_combo_1.lbl_title.text = @"Beers";
    self.m_combo_1.m_comboTitle = @"Categories";
    self.m_combo_1.m_containDatas = m_containsString1;
    self.m_combo_2.lbl_title.text = @"Vodka";
    self.m_combo_2.m_comboTitle = @"Drinks";
    
    self.m_combo_1.delegate = self;
    self.m_combo_2.delegate = self;
    self.m_combo_3.delegate = self;
    self.m_combo_4.delegate = self;
    
    self.m_dataTable.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self showComboBoxAt:0];
    [self.addOrderDlg initDelegate];
    [self.addOrderDlg setHidden:YES];
    
    tableItemCount  = 0;
    
    current_category = 1;
    current_sub_category = 0;
    
    self.m_dataTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self getDataForCategory:current_category sunCategory:current_sub_category];
}

- (id) getCurrentItem:(int)indexPath
{
    return [m_itemArray objectAtIndex:indexPath];
}
- (void) reloadTable:(NSMutableArray*)array
{
    tableItemCount = 0;
    [self.m_dataTable reloadData];
    
    m_itemArray = [NSMutableArray new];
    for(int i=0; i<[array count]; i+=2){
        NSMutableArray * currentArray = [NSMutableArray new];
        if(i < [array count])
            [currentArray  addObject:[array objectAtIndex:i]];
        if(i+1 < [array count])
            [currentArray  addObject:[array objectAtIndex:i+1]];
        [m_itemArray addObject:currentArray];
    }
    tableItemCount = (int)[m_itemArray count];
    [self.m_dataTable reloadData];
    [super tableChecker:self.m_dataTable];
}

//+ (void) getDrinkArrayWithCategoryId:(int)categoryId :(void (^)(id returnItem, NSError * error))sucessblock failBlock:(void (^)(NSError * error))failblock;
- (void) getDataForCategory:(int) category sunCategory:(int)subCat
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if(category == 1 || category == 5){
        [DrinkItem getDrinkArrayWithCategoryId:category :defaultUser.row_id :^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
            [self showComboBoxAt:category-1];
            [self reloadTable:returnItem];
            
        } failBlock:^( NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            
        }];
    }else{
        [DrinkItem getDrinkArrayWithCategoryId:category withSubCategory:subCat :defaultUser.row_id :^(id returnItem, NSError * error){
            [SVProgressHUD dismiss];
//            m_itemArray = returnItem;
//            tableItemCount = (int)[m_itemArray count];
//            [self.m_dataTable reloadData];
            [self showComboBoxAt:category-1];
            [self reloadTable:returnItem];
        } failBlock:^( NSError * error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
            
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableItemCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"BusinessItemTableViewCell"];
    
    id currentItem = nil;
    currentItem = [self getCurrentItem:(int)indexPath.row];
    if([currentItem isKindOfClass:[NSString class]]){
        reuseIdentifier = [NSString stringWithFormat:@"BusinessItemTableViewTitleCell"];
        BusinessItemTableViewTitleCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [cell.lbl_title setText:[NSString stringWithFormat:@" %@  ", currentItem]];
        return cell;
    }else{
        reuseIdentifier = [NSString stringWithFormat:@"BusinessItemTableViewCell"];
        BusinessItemTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        NSMutableArray * data = currentItem;
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
    return nil;
}

- (void)BusinessItemTableViewCellDelegate_clickedAt:(UITableViewCell *)cell atIndex:(int)index withOption:(int)option
{
    int rowIndex = (int)[self.m_dataTable indexPathForCell:cell].row;
    if(option == 0){
//        [self.addOrderDlg setHidden:NO];
    }else{//edit
        NSMutableArray * data = [self getCurrentItem:rowIndex];
        DrinkItem * item = [data objectAtIndex:index];
        m_editItem = item;
        if(item.row_category_id == 1){
            [self performSegueWithIdentifier:@"EditDrink1" sender:self];
        }else if(item.row_category_id == 2){
            [self performSegueWithIdentifier:@"EditDrink2" sender:self];
        }else if(item.row_category_id == 3){
            [self performSegueWithIdentifier:@"EditDrink3" sender:self];
        }else if(item.row_category_id == 4){
            [self performSegueWithIdentifier:@"EditDrink4" sender:self];
        }else if(item.row_category_id == 5){
            [self performSegueWithIdentifier:@"EditDrink5" sender:self];
        }
    }
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([segue.identifier isEqualToString:@"EditDrink1"]){
         BusinessAddDrinkType1Controller * controller = (BusinessAddDrinkType1Controller*)segue.destinationViewController;
         controller.isEditMode = YES;
         controller.editItm = m_editItem;
     }else if([segue.identifier isEqualToString:@"EditDrink2"]){
         BusinessAddDrinkType2Controller * controller = (BusinessAddDrinkType2Controller*)segue.destinationViewController;
         controller.isEditMode = YES;
         controller.editItm = m_editItem;
     }else if([segue.identifier isEqualToString:@"EditDrink3"]){
         BusinessAddDrinkType5Controller * controller = (BusinessAddDrinkType5Controller*)segue.destinationViewController;
         controller.isEditMode = YES;
         controller.editItm = m_editItem;
     }else if([segue.identifier isEqualToString:@"EditDrink4"]){
         BusinessAddDrinkType3Controller * controller = (BusinessAddDrinkType3Controller*)segue.destinationViewController;
         controller.isEditMode = YES;
         controller.editItm = m_editItem;
     }else if([segue.identifier isEqualToString:@"EditDrink5"]){
         BusinessAddDrinkType4Controller * controller = (BusinessAddDrinkType4Controller*)segue.destinationViewController;
         controller.isEditMode = YES;
         controller.editItm = m_editItem;
     }
 }


- (int) getIndexFromStringArray:(NSMutableArray*)array forString:(NSString*)str
{
    for(NSString * subString in array){
        if([subString isEqualToString:str]){
            return (int)[array indexOfObject:subString] + 1;
        }
    }
    return  -1;
}
- (void) showComboBoxAt:(int)index
{
    UIView * correctView = self.m_combo_1;
    if(index == 0){
        [self.m_combo_2 setHidden:YES];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
    }else if(index == 1){
        correctView = self.m_combo_2;
        [self.m_combo_2 setHidden:NO];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
    }else if(index == 2){
        [self.m_combo_2 setHidden:NO];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
        correctView = self.m_combo_2;
    }else if(index == 3){
        [self.m_combo_2 setHidden:YES];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
        correctView = self.m_combo_1;
    }else if(index == 4){
        [self.m_combo_2 setHidden:YES];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
        correctView = self.m_combo_1;
    }
    CGRect comboRect = [correctView.superview convertRect:correctView.frame toView:self.view];
    CGRect tableRect = self.m_dataTable.frame;
    int newYPosition = comboRect.origin.y + comboRect.size.height + 8;
    tableRect.origin.y = newYPosition;
    tableRect.size.height = [UIScreen mainScreen].bounds.size.height - tableRect.origin.y - 60;
    tableRect.size.width = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        [self.m_dataTable setFrame:tableRect];
//        [self.m_dataTable layoutIfNeeded];
    }];
}

- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    CustomComboBox * currentCombo = (CustomComboBox*)combo;
    if(currentCombo ==  self.m_combo_1){
        int selectedIndex = [self getIndexFromStringArray:m_containsString1 forString:item];
        current_category  = selectedIndex;
        current_sub_category = 0;
        if(selectedIndex == 1){
            m_containsString2 = [NSMutableArray new];
            [self showComboBoxAt:0];
        }else if(selectedIndex == 2){
            m_containsString2 = [[NSMutableArray alloc] initWithObjects:@"Brandy",@"Cognac",@"Schnapps",@"Gin",@"Rum",@"Tequila",@"Vodka",@"Whisky",@"Bourbon", @"Scotch",nil];
            self.m_combo_2.lbl_title.text = @"Brandy";
            self.m_combo_2.m_comboTitle = @"Drinks";
            self.m_combo_2.m_containDatas = m_containsString2;
            [self showComboBoxAt:1];
        }else if(selectedIndex == 3){
            m_containsString2 = [[NSMutableArray alloc] initWithObjects:@"Bottle", @"Glass", nil];
            self.m_combo_2.lbl_title.text = @"Bottle";
            self.m_combo_2.m_comboTitle = @"Drinks";
            self.m_combo_2.m_containDatas = m_containsString2;
            [self showComboBoxAt:2];
        }else if(selectedIndex == 4){
            m_containsString2 = [NSMutableArray new];
            [self showComboBoxAt:3];
        }else if(selectedIndex == 5){
            m_containsString2 = [NSMutableArray new];
            [self showComboBoxAt:4];
        }
        [self getDataForCategory:current_category sunCategory:current_sub_category];
    }else if(currentCombo ==  self.m_combo_2){
        int selectedIndex = [self getIndexFromStringArray:self.m_combo_2.m_containDatas forString:item];
        current_sub_category = selectedIndex -1;
        [self getDataForCategory:current_category sunCategory:current_sub_category];
    }
}
@end
