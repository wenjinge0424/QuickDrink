//
//  CustomItemListController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomItemListController.h"
#import "BusinessItemTableViewCell.h"
#import "CustomComboBox.h"
#import "AddOrderDlg.h"
#import "CustomerRestDetailController.h"
#import "Util.h"

@interface CustomItemListController ()<UITableViewDelegate, UITableViewDataSource,CustomComboBox_SelectedItem, BusinessItemTableViewCellDelegate, AddOrderDlgDelegate>
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
    int current_type;
    
    DrinkItem * m_editItem;
    
    NSMutableArray * m_favouriteItems;
}
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_1;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_2;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_3;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_combo_4;
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@property (strong, nonatomic) IBOutlet AddOrderDlg *addOrderDlg;

@property (weak, nonatomic) IBOutlet UIView *view_cartAlert;
@property (weak, nonatomic) IBOutlet UILabel *lbl_cartCount;
@end

@implementation CustomItemListController
- (void) AddOrderDlgDelegate_complete
{
    NSMutableArray * m_cartArray = [StackMemory  getCartItems];
    self.view_cartAlert.layer.cornerRadius = self.view_cartAlert.frame.size.width / 2;
    if(m_cartArray && m_cartArray.count > 0){
        [self.view_cartAlert setHidden:NO];
        [self.lbl_cartCount setText:[NSString stringWithFormat:@"%d", (int)m_cartArray.count]];
    }else{
        [self.view_cartAlert setHidden:YES];
        [self.lbl_cartCount setText:@""];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(checkBusinessState) withObject:nil afterDelay:5];
    
    self.addOrderDlg.delegate = self;
    
    NSMutableArray * m_cartArray = [StackMemory  getCartItems];
    self.view_cartAlert.layer.cornerRadius = self.view_cartAlert.frame.size.width / 2;
    if(m_cartArray && m_cartArray.count > 0){
        [self.view_cartAlert setHidden:NO];
        [self.lbl_cartCount setText:[NSString stringWithFormat:@"%d", (int)m_cartArray.count]];
    }else{
        [self.view_cartAlert setHidden:YES];
        [self.lbl_cartCount setText:@""];
    }
}

- (void) checkBusinessState
{
    if(self.m_selected_business){
        PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
        [query whereKey:@"user_id" equalTo:self.m_selected_business.row_id];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
            if(object){
                self.isOpened = [object[@"online_order"] intValue];
            }else{
                self.isOpened = 0;
            }
            [self performSelector:@selector(checkBusinessState) withObject:nil afterDelay:5];
        }];
    }
}

- (void) changeBusinessTo:(NSString *) userId
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if([self.m_selected_business.row_id isEqualToString:userId]){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
        [query whereKey:@"user_id" equalTo:userId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
            [SVProgressHUD dismiss];
            if(object){
                self.isOpened = [object[@"online_order"] intValue];
            }else{
                self.isOpened = 0;
            }
            current_category = self.m_selectedCateogry;
            current_sub_category = self.m_selectedSubCategory;
            [self animatedToCategory:current_category :current_sub_category];
            
            [self getDataForCategory:current_category subCategory:current_sub_category subType:0];
        }];
    }else{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [DBUsers getUserInfoFromUserId:userId sucessBlock:^(DBUsers * val, NSError * error){
            self.m_selected_business = val;
            tableItemCount  = 0;
            current_category = self.m_selectedCateogry;
            current_sub_category = self.m_selectedSubCategory;
            [self animatedToCategory:current_category :current_sub_category];
            
            PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
            [query whereKey:@"user_id" equalTo:userId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
                [SVProgressHUD dismiss];
                if(object){
                    self.isOpened = [object[@"online_order"] intValue];
                    [self getDataForCategory:current_category subCategory:current_sub_category subType:0];
                }else{
                    self.isOpened = 0;
                    [self getDataForCategory:current_category subCategory:current_sub_category subType:0];
                }
            }];
        } failBlock:^(NSError*error){
            [SVProgressHUD dismiss];
        }];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    
    if(self.m_selectedCateogry == 1){
        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Draft", @"Bottle", @"Can", nil];
        m_containsString2 = [[NSMutableArray alloc] init];
    }else if(self.m_selectedCateogry == 2){
        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Brandy",@"Cognac",@"Schnapps",@"Gin",@"Rum",@"Tequila",@"Vodka",@"Whisky",@"Bourbon", @"Scotch", nil];
        m_containsString2 = [[NSMutableArray alloc] initWithObjects:@"Bloody Mary", @"Cosmopolitan", @"Martini",nil];
    }else if(self.m_selectedCateogry == 3){
        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Bottle", @"Glass", nil];
        m_containsString2 = [[NSMutableArray alloc] initWithObjects:@"Chardonnay", @"Riesling", @"Pinot Gris" , @"Sauvignon Blanc", @"Merlot", @"Cabernet Sauvignon", @"Pinot Noir", @"Shiraz", @"Sangiovese", @"Nebbiolo", @"Malbec", @"Tempranillo", @"Gamay", @"Zinfandel", nil];
    }else if(self.m_selectedCateogry == 4){
        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Vodka", @"Bourbon", @"Rum", @"Whiskey", @"Tequila", @"Wine", nil];
        m_containsString2 = [NSMutableArray new];
    }else if(self.m_selectedCateogry == 5){
        m_containsString1 = [[NSMutableArray alloc] init];
    }
    if(m_containsString1.count > 0){
        self.m_combo_1.lbl_title.text = [m_containsString1 firstObject];
        self.m_combo_1.m_comboTitle = [m_containsString1 firstObject];
        self.m_combo_1.m_containDatas = m_containsString1;
        if(m_containsString2.count > 0){
            self.m_combo_2.lbl_title.text = [m_containsString2 firstObject];
            self.m_combo_2.m_comboTitle = [m_containsString2 firstObject];
            self.m_combo_2.m_containDatas = m_containsString2;
        }
    }
    
    self.m_combo_1.delegate = self;
    self.m_combo_2.delegate = self;
    self.m_combo_3.delegate = self;
    self.m_combo_4.delegate = self;
    
    self.m_dataTable.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self showComboBoxAt:0];
    [self.addOrderDlg initDelegate];
    self.addOrderDlg.parentViewController = self;
    [self.addOrderDlg setHidden:YES];
    
    NSMutableArray * m_cartArray = [StackMemory  getCartItems];
    self.view_cartAlert.layer.cornerRadius = self.view_cartAlert.frame.size.width / 2;
    if(m_cartArray && m_cartArray.count > 0){
        [self.view_cartAlert setHidden:NO];
        [self.lbl_cartCount setText:[NSString stringWithFormat:@"%d", (int)m_cartArray.count]];
    }else{
        [self.view_cartAlert setHidden:YES];
        [self.lbl_cartCount setText:@""];
    }
    
    [self.lbl_title setText:self.m_selected_business.row_userName];
    UITapGestureRecognizer * recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectTitle:)];
    [self.lbl_title addGestureRecognizer:recog];
    tableItemCount  = 0;
    current_type = 0;
    
    if(self.m_selectedCateogry == 0)
        self.m_selectedCateogry = 1;
    current_category = self.m_selectedCateogry;
    current_sub_category = self.m_selectedSubCategory;
    
    
    [self animatedToCategory:current_category :current_sub_category];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
    [query whereKey:@"user_id" equalTo:self.m_selected_business.row_id];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error){
        [SVProgressHUD dismiss];
        if(object){
            self.isOpened = [object[@"online_order"] intValue];
            [self getDataForCategory:current_category subCategory:current_sub_category subType:current_type];
        }else{
            self.isOpened = 0;
            [self getDataForCategory:current_category subCategory:current_sub_category  subType:current_type];
        }
    }];
}
- (IBAction)onSelectTitleFormButton:(id)sender {
    [self performSegueWithIdentifier:@"showBusinessDetail" sender:self];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onSelectTitle:(UIGestureRecognizer*)recog
{
    [self performSegueWithIdentifier:@"showBusinessDetail" sender:self];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showBusinessDetail"]){
        CustomerRestDetailController * controller = (CustomerRestDetailController*)[segue destinationViewController];
        controller.m_selected_business = self.m_selected_business;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void) getDataForCategory:(int) category subCategory:(int)subCat subType:(int)type
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    DBUsers * logInUser = [[StackMemory createInstance] stack_signInItem];
    DBUsers * defaultUser = self.m_selected_business;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBFavourtie allFavouriteIds:logInUser.row_id :^(NSMutableArray* array, NSError* error){
        
        m_favouriteItems = [[NSMutableArray alloc] initWithArray:array];
        if(category == 1){
            [DrinkItem getDrinkArrayWithCategoryId:category withSubCategory:0 withType:subCat :defaultUser.row_id :^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                [self reloadTable:returnItem];
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                
            }];
        }else if(category == 1){
            [DrinkItem getDrinkArrayWithCategoryId:category withSubCategory:subCat :defaultUser.row_id :^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                [self reloadTable:returnItem];
            }  failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                
            }];
        }
        else if(category == 5){
            [DrinkItem getDrinkArrayWithCategoryId:category :defaultUser.row_id :^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                [self reloadTable:returnItem];

            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                
            }];
        }else{
            [DrinkItem getDrinkArrayWithCategoryId:category withSubCategory:subCat withType:type :defaultUser.row_id :^(id returnItem, NSError * error){
                [SVProgressHUD dismiss];
                [self reloadTable:returnItem];
            } failBlock:^( NSError * error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
                
            }];
        }
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableItemCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"BusinessItemTableViewTitleCell";
    BusinessItemTableViewTitleCell * cell = (BusinessItemTableViewTitleCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell layoutIfNeeded];
    
    if([[self getCurrentItem:(int)indexPath.row] isKindOfClass:[NSString class]])
        return 50;
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
            [cell.m_item1View checkFavourite:m_favouriteItems];
            [cell.m_item2View checkFavourite:m_favouriteItems];
            [cell.m_item1View setHidden:NO];
            [cell.m_item2View setHidden:NO];
        }else{
            [cell.m_item1View setInformation:[data firstObject]];
            [cell.m_item1View checkFavourite:m_favouriteItems];
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
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    if(self.isOpened != 1){
        NSString * message = @"Business is closed for online order. Please order through any of our service staff.";
        [Util showAlertTitle:self title:@"Drink" message:message];
        return;
    }
    
    int rowIndex = (int)[self.m_dataTable indexPathForCell:cell].row;
    if(option == 0){
        NSMutableArray * data = [self getCurrentItem:rowIndex];
        DrinkItem * item = [data objectAtIndex:index];
        if(item.row_isTemporarily == 1){
            NSString * message = @"This drink is temporarily out of stock at now. Please select other drinks";
            [Util showAlertTitle:self title:@"Drink" message:message];
            return;
        }
        m_editItem = item;
        
        [self.addOrderDlg initWithDrinkInfo:m_editItem];
        [self.addOrderDlg setHidden:NO];
    }else{//favourite
        NSMutableArray * data = [self getCurrentItem:rowIndex];
        DrinkItem * item = [data objectAtIndex:index];
        m_editItem = item;
        
        BusinessItemTableViewCell * customcell = (BusinessItemTableViewCell*)cell;
        UIButton * favouriteButton  = customcell.m_item1View.btn_favour;
        if(index == 1){
            favouriteButton  = customcell.m_item2View.btn_favour;
        }
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        if(![favouriteButton isSelected]){
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [DBFavourtie addItemWith:defaultUser.row_id :item.row_id :^(id returnVal, NSError * error){
                [favouriteButton setSelected:YES];
                [SVProgressHUD dismiss];
            } failBlock:^(NSError* error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }else{
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [DBFavourtie deleteItemWith:defaultUser.row_id :item.row_id :^(id returnVal, NSError * error){
                [favouriteButton setSelected:NO];
                [SVProgressHUD dismiss];
            } failBlock:^(NSError* error){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^(void){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }
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
    [self.m_combo_1 setHidden:NO];
    if(index == 0){
        [self.m_combo_2 setHidden:YES];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
    }else if(index == 1){
        correctView = self.m_combo_1;
        [self.m_combo_2 setHidden:YES];
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
        [self.m_combo_1 setHidden:YES];
        [self.m_combo_2 setHidden:YES];
        [self.m_combo_3 setHidden:YES];
        [self.m_combo_4 setHidden:YES];
        correctView = self.m_combo_1;
    }
    
    CGRect comboRect = [correctView.superview convertRect:correctView.frame toView:self.view];
    if(correctView == self.m_combo_1){
        comboRect.origin.y = self.m_combo_2.frame.origin.y;
        comboRect.size.height = 0;
    }
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
- (void) animatedToCategory:(int) category :(int) subcategory
{
//    m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Beers", @"Cocktails",@"Wines",@"Speciality Drinks", @"Non-Alcoholic Drinks", nil];
//    self.m_combo_1.lbl_title.text = [self getTitleForCategory:current_category];
    
//    if(category == 2){
//        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Brandy",@"Cognac",@"Schnapps",@"Gin",@"Rum",@"Tequila",@"Vodka",@"Whisky",@"Bourbon", @"Scotch",nil];
//        self.m_combo_1.m_containDatas = m_containsString2;
//        self.m_combo_1.m_comboTitle = @"Drinks";
//        self.m_combo_1.lbl_title.text = [self getSubCategoryTitle:current_category :current_sub_category];
//    }else if(category == 3){
//        m_containsString1 = [[NSMutableArray alloc] initWithObjects:@"Bottle", @"Glass", nil];
//        self.m_combo_1.lbl_title.text = [self getSubCategoryTitle:current_category :current_sub_category];
//        self.m_combo_1.m_comboTitle = @"Drinks";
//        self.m_combo_1.m_containDatas = m_containsString2;
//    }else{
//        m_containsString2 = [NSMutableArray new];
//    }
    
    [self showComboBoxAt:current_category-1];
}
- (NSString * )getTitleForCategory:(int) categoryId
{
    return [m_containsString1 objectAtIndex:categoryId-1];
}

- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    CustomComboBox * currentCombo = (CustomComboBox*)combo;
    if(currentCombo ==  self.m_combo_1){
        int selectedIndex = [self getIndexFromStringArray:m_containsString1 forString:item];
        current_sub_category = selectedIndex-1;
        self.m_selectedCateogry = current_category;
        self.m_selectedSubCategory = current_sub_category;
        [self getDataForCategory:current_category subCategory:current_sub_category subType:current_type];
    }else if(currentCombo ==  self.m_combo_2){
        int selectedIndex = [self getIndexFromStringArray:self.m_combo_2.m_containDatas forString:item];
        current_type = selectedIndex -1;
        [self getDataForCategory:current_category subCategory:current_sub_category subType:current_type];
    }
}


@end
