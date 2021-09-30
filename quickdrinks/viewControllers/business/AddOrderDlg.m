//
//  AddOrderDlg.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "AddOrderDlg.h"
#import "Util.h"

@interface AddOrderDlg() <UITextViewDelegate>
{
    int animationHeight;
    
    int m_count;
    
    DrinkItem * m_curent_item;
    CGFloat glassViewOrgHeight;
}
@end
/*
 @property (strong, nonatomic) IBOutlet UIImageView *img_item;
 @property (strong, nonatomic) IBOutlet UILabel *lbl_title1;
 @property (strong, nonatomic) IBOutlet UILabel *lbl_title2;
 @property (strong, nonatomic) IBOutlet UILabel *lbl_title3;
 @property (strong, nonatomic) IBOutlet UILabel *lbl_price;
 @property (strong, nonatomic) IBOutlet UILabel *lbl_desc;
 @property (strong, nonatomic) IBOutlet UITextField *edt_count;
 @property (strong, nonatomic) IBOutlet CustomCheckerGroup *checker_group;
 @property (strong, nonatomic) IBOutlet UITextField *edt_tableNo;
 @property (strong, nonatomic) IBOutlet UITextView *edt_instruction;
 */
@implementation AddOrderDlg

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initDelegate
{
    [self.checker_group initViewDelegate];
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done1Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForContactNumber)];
    UIBarButtonItem * done2Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onHideKeyboardForDescription)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done1Button, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_tableNo setInputAccessoryView:toolbar1];
    
    UIToolbar * toolbar2 = [[UIToolbar alloc] init];
    [toolbar2 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar2 sizeToFit];
    NSArray * items2Array = [NSArray arrayWithObjects:flexButton,done2Button, nil];
    [toolbar2 setItems:items2Array];
    [self.edt_instruction setInputAccessoryView:toolbar2];
    
    m_count = 0;
    self.edt_count.text = @"";
    glassViewOrgHeight = 0.0f;
    
}

- (void) initWithDrinkInfo:(DrinkItem*)item
{
    m_curent_item = item;
    [self.img_item setImage:[UIImage imageNamed:@""]];
    [Util setImage:self.img_item imgUrl:item.row_img];

    NSMutableArray * drinkTitleArray = [StackMemory getDrinkTitlesFrom:m_curent_item.row_category_id :m_curent_item.row_subcategory_id :m_curent_item.row_selected_type];
    [self.lbl_title1 setText:[drinkTitleArray objectAtIndex:0]];
    //@"Beers", @"Cocktails",@"Wines",@"Speciality Drinks", @"Non-Alcoholic Drinks"
    if(item.row_category_id == 1 || item.row_category_id == 4){
        [self.lbl_title2 setText:[drinkTitleArray objectAtIndex:2]];
    }else if(item.row_category_id == 2 || item.row_category_id == 3){
        [self.lbl_title2 setText:[NSString stringWithFormat:@"%@",[drinkTitleArray objectAtIndex:1]]];
    }else{
        [self.lbl_title2 setText:@""];
    }
    [self.lbl_title3 setText:item.row_name];
    [self.lbl_desc setText:item.row_description];
    [self.lbl_price setText:[NSString stringWithFormat:@"$%.2f", item.row_price]];
    [self.edt_count setTextAlignment:NSTextAlignmentCenter];
    [self.edt_count setText:@"0"];
    
    [self.checker_group setSelectItem:0];
    m_count = 0;
    self.edt_instruction.text = @"";
    self.edt_tableNo.text = @"";
    
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.m_glassView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    if (glassViewOrgHeight == 0) {
        glassViewOrgHeight = self.m_glassView.frame.size.height;
    }
    
    int category = m_curent_item.row_category_id;
    
    CGRect glassRect = self.m_glassView.frame;
    
    
    if (category == 3){ // for Wine
        CGRect glassRect = self.m_glassView.frame;
        glassRect.size.height = glassViewOrgHeight;
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.m_glassView setFrame:glassRect];
            [_m_glassView setHidden:NO];
        }];
    }else{
        glassRect.size.height = 0;
        [UIView animateWithDuration:0.1 animations:^{
            [self.m_glassView setFrame:glassRect];
            [_m_glassView setHidden:YES];
        }];
    }
}



- (IBAction)onGlass1:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor whiteColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor blackColor] forState:normal];
}
- (IBAction)onGlass2:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor whiteColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor blackColor] forState:normal];

}
- (IBAction)onGlass3:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor whiteColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor blackColor] forState:normal];
}
- (IBAction)onGlass4:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor whiteColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor blackColor] forState:normal];
}
- (IBAction)onGlass5:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor whiteColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor blackColor] forState:normal];
}
- (IBAction)onGlass6:(id)sender
{
    UIImage *imageBlue = [UIImage imageNamed:@"bg_rectangle_blue"];
    UIImage *imageWhite = [UIImage imageNamed:@"bg_rectangle_white"];
    [_m_glass1 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass2 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass3 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass4 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass5 setBackgroundImage:imageWhite forState:UIControlStateNormal];
    [_m_glass6 setBackgroundImage:imageBlue forState:UIControlStateNormal];
    
    [_m_glass1 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass2 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass3 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass4 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass5 setTitleColor:[UIColor blackColor] forState:normal];
    [_m_glass6 setTitleColor:[UIColor whiteColor] forState:normal];
}
- (IBAction)onClose:(id)sender
{
    [self setHidden:YES];
}
- (IBAction)onUp:(id)sender
{
    if(m_count > 0)
        m_count -= 1;
    self.edt_count.text = [NSString stringWithFormat:@"%d",m_count];
}
- (IBAction)onDown:(id)sender
{
    if(m_count == 12)
        return;
    m_count += 1;
    self.edt_count.text = [NSString stringWithFormat:@"%d",m_count];
}
- (IBAction)onAddtoOrder:(id)sender
{
    if(m_count == 0){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please insert drink count" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){}];
        }];
        [alert addAction:cancel];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [DBUsers getUserInfoFromUserId:m_curent_item.user_id sucessBlock:^(DBUsers * m_owner, NSError * error){
        [SVProgressHUD dismiss];
        DBUsers * m_sender = [[StackMemory createInstance] stack_signInItem];
        StackCartItem * item = [StackCartItem new];
        item.item = m_curent_item;
        item.sender_name = m_sender.row_userName;
        item.sender_id = m_sender.row_id;
        item.owner_name = m_owner.row_userName;
        item.owner_id = m_owner.row_id;
        
        NSMutableArray * drinkTitleArray = [StackMemory getDrinkTitlesFrom:m_curent_item.row_category_id :m_curent_item.row_subcategory_id :m_curent_item.row_selected_type];
        NSString * itemName = [NSString stringWithFormat:@"%d %@", [self.edt_count.text intValue], [drinkTitleArray objectAtIndex:0]];
        if(![[drinkTitleArray objectAtIndex:1] isEqualToString:@""])
            itemName = [itemName stringByAppendingFormat:@" %@", [drinkTitleArray objectAtIndex:1]];
        if(m_curent_item.row_category_id == 1)
            itemName = [itemName stringByAppendingFormat:@", %@", [drinkTitleArray objectAtIndex:2]];
//        if(![[drinkTitleArray objectAtIndex:2] isEqualToString:@""])
//            itemName = [itemName stringByAppendingFormat:@", %@", [drinkTitleArray objectAtIndex:2]];
        itemName = [itemName stringByAppendingFormat:@" - %@", m_curent_item.row_name];
        item.item_name = itemName;
        item.drink_price = m_curent_item.row_price * [self.edt_count.text intValue];
        item.drink_count = [self.edt_count.text intValue];
        item.item_descrption = @"";
        item.item_drinkInstruction = @"";
        if([self.edt_instruction text].length > 0){
            item.item_descrption = [self.edt_instruction text];
        }
        if(m_curent_item.row_instruction.length > 0){
            item.item_drinkInstruction = m_curent_item.row_instruction;
        }
        [StackMemory addItemToCart:item];
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Drink was successfully added in cart." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){}];
        }];
        [alert addAction:cancel];
        [self.parentViewController presentViewController:alert animated:YES completion:^{
            [self setHidden:YES];
            if(self.delegate){
                [self.delegate AddOrderDlgDelegate_complete];
            }
        }];
        
        
        
    }failBlock:^(NSError*error){
        [SVProgressHUD dismiss];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"network error" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){}];
        }];
        [alert addAction:cancel];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
    }];
}

/////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    animationHeight = 0;
    CGRect selfviewRect = [textView.superview convertRect:textView.frame toView:self];
    if(self.frame.size.height -  selfviewRect.origin.y - selfviewRect.size.height < 230){
        animationHeight = 230 + selfviewRect.origin.y + selfviewRect.size.height - self.frame.size.height;
        [self gotoUpAnimation:animationHeight];
    }
    return YES;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    animationHeight = 0;
    CGRect selfviewRect = [textField.superview convertRect:textField.frame toView:self];
    if(self.frame.size.height -  selfviewRect.origin.y - selfviewRect.size.height < 230){
        animationHeight = 230 + selfviewRect.origin.y + selfviewRect.size.height - self.frame.size.height;
        [self gotoUpAnimation:animationHeight];
    }
    return YES;
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
    return YES;
}
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 160;
}
- (void)onHideKeyboardForContactNumber
{
    [self.edt_tableNo resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
}
- (void)onHideKeyboardForDescription
{
    [self.edt_instruction resignFirstResponder];
    if(animationHeight > 0){
        [self gotoDownAnimation:animationHeight];
    }
}
- (void) gotoUpAnimation:(int)height
{
//    [UIView animateWithDuration:0.1 animations:^(){
//        [self setFrame:CGRectMake(0, -height, self.frame.size.width, self.frame.size.height)];
//    }];
}
- (void) gotoDownAnimation:(int)height
{
//    [UIView animateWithDuration:0.1 animations:^(){
//        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    }];
}

@end
