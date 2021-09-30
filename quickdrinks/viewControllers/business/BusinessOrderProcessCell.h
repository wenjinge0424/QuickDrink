//
//  BusinessOrderProcessCell.h
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButtonForCheck:UIButton

@end

@protocol BusinessOrderProcessCellDelegate
- (void)BusinessOrderTableViewCellDelegate_actionAtCell:(UITableViewCell*)cell;
- (void)BusinessOrderTableViewCellDelegate_actionAtCellInstruction:(UITableViewCell*)cell :(NSString*)instruction;
- (void)BusinessOrderTableViewCellDelegate_actionAtCellNoInstruction:(UITableViewCell*)cell :(NSString*)instruction;

- (void)BusinessOrderTableViewCellDelegate_actionAtCellDrinkRecipe:(UITableViewCell*)cell :(NSString*)drinkId;
@end

@interface BusinessOrderProcessCell : UITableViewCell
{
    NSMutableArray * cellData;
}

@property (nonatomic, retain) id<BusinessOrderProcessCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView * lbl_view;
@property (strong, nonatomic) IBOutlet UILabel * lbl_title1;
@property (strong, nonatomic) IBOutlet UILabel *lbl_time;
@property (strong, nonatomic) IBOutlet UIButton *btn_order;
@property (strong, nonatomic) IBOutlet UILabel *lbl_tableNum;
@property (strong, nonatomic) IBOutlet UIImageView *img_user;
@property (strong, nonatomic) IBOutlet UILabel *lbl_name;

+ (int) getCellHeightWithValue:(NSMutableArray*)data;
- (void) initWithData:(NSMutableArray*)data;
- (IBAction)onClick:(id)sender;
@end
