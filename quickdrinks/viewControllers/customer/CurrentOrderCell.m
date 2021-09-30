//
//  CurrentOrderCell.m
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CurrentOrderCell.h"
#import "DBCong.h"

@implementation CurrentOrderCellView

- (IBAction)btn_delete:(id)sender {
}
@end

@implementation CurrentOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (int) getCellHeightWithValue:(int)count
{
    return 100 + (30 * (count - 1));
}
- (void) initWithData:(NSMutableArray*)data
{
    
    [self setNeedsLayout];
    
    if(data.count > 0){
        CGPoint stPos = self.view_orderitem.frame.origin;
        
        for(UIView * subView in self.contentView.subviews){
            if([subView isKindOfClass:[UILabel class]]){
                if(subView.tag == 100){
                    [subView removeFromSuperview];
                }
            }
        }
        [self.view_orderitem setNeedsLayout];
        
        UILabel * lbl_title_value = self.view_orderitem.lbl_name;
        UILabel * lbl_value_value = self.view_orderitem.lbl_value;
        [self.view_orderitem.lbl_name setHidden:YES];
        [self.view_orderitem.lbl_value setHidden:YES];
        
        
        int cellcount = data.count;
        if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
            cellcount = [[data firstObject] count];
        }
        
        
        for(int i = 0; i< cellcount;i++){
            stPos.y += 30 * i;
            CGRect lbl_titleRect = [self.view_orderitem convertRect:self.view_orderitem.lbl_name.frame toView:self];
            lbl_titleRect.origin.y += 30 *i;
            lbl_titleRect.size.width = 250;
            UILabel * newLabel = [[UILabel alloc] initWithFrame:lbl_titleRect];
            newLabel.tag = 100;
            [newLabel setFont:[UIFont systemFontOfSize:14]];
            [newLabel setTextAlignment:NSTextAlignmentLeft];
            [self.contentView addSubview:newLabel];
            lbl_title_value = newLabel;
            
            
            CGRect lbl_valueRect = lbl_titleRect;
            lbl_valueRect.origin.x = [UIScreen mainScreen].bounds.size.width - 200;
            lbl_valueRect.size.width = 180;
            
            UILabel * newLabel2 = [[UILabel alloc] initWithFrame:lbl_valueRect];
            newLabel2.tag = 100;
            [newLabel2 setFont:[UIFont systemFontOfSize:14]];
            [newLabel2 setTextAlignment:NSTextAlignmentRight];
            [self.contentView addSubview:newLabel2];
            
            lbl_value_value = newLabel2;
            if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
                NSMutableArray * nameArray = [data firstObject];
                NSMutableArray * priceArray = [data lastObject];
                
                [lbl_title_value setText:[nameArray objectAtIndex:i]];
                lbl_value_value.text = [NSString stringWithFormat:@"$ %.2f", [[priceArray objectAtIndex:i] floatValue]];
            }else if([[data objectAtIndex:i] isKindOfClass:[StackCartItem class]]){
                StackCartItem * item = [data objectAtIndex:i];
                lbl_value_value.text = [NSString stringWithFormat:@"$ %.2f", item.drink_price];
                [lbl_title_value setText:item.item_name];
            }
        }
    }
}
@end

@implementation CurrentCartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
+ (int) getCellHeightWithValue:(int)count
{
    return 130 + (60 * (count - 1));
}
- (void) initWithData:(NSMutableArray*)data
{
    
    [self setNeedsLayout];
    
    if(data.count > 0){
        CGPoint stPos = self.view_orderitem.frame.origin;
        
        for(UIView * subView in self.contentView.subviews){
            if([subView isKindOfClass:[UILabel class]]){
                if(subView.tag == 100){
                    [subView removeFromSuperview];
                }
            }
        }
        [self.view_orderitem setNeedsLayout];
        
        UILabel * lbl_title_value = self.view_orderitem.lbl_name;
        UILabel * lbl_value_value = self.view_orderitem.lbl_value;
        [self.view_orderitem.lbl_name setHidden:YES];
        [self.view_orderitem.lbl_value setHidden:YES];
        
        
        int cellcount = data.count;
        if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
            cellcount = [[data firstObject] count];
        }
        
        
        for(int i = 0; i< cellcount;i++){
            stPos.y += 60 * i;
            CGRect lbl_titleRect = [self.view_orderitem convertRect:self.view_orderitem.lbl_name.frame toView:self];
            lbl_titleRect.origin.y += 60 *i;
            lbl_titleRect.size.width = 250;
            UILabel * newLabel = [[UILabel alloc] initWithFrame:lbl_titleRect];
            newLabel.tag = 100;
            [newLabel setFont:[UIFont systemFontOfSize:14]];
            [newLabel setTextAlignment:NSTextAlignmentLeft];
            [self.contentView addSubview:newLabel];
            lbl_title_value = newLabel;
            
            
            CGRect lbl_valueRect = lbl_titleRect;
            lbl_valueRect.origin.x = [UIScreen mainScreen].bounds.size.width - 200;
            lbl_valueRect.size.width = 180;
            
            UILabel * newLabel2 = [[UILabel alloc] initWithFrame:lbl_valueRect];
            newLabel2.tag = 100;
            [newLabel2 setFont:[UIFont systemFontOfSize:14]];
            [newLabel2 setTextAlignment:NSTextAlignmentRight];
            [self.contentView addSubview:newLabel2];
            
            UIButton * btnDelete = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 44 + 60 *i, 60, 30)];
            btnDelete.tag = i;
            [btnDelete setTitle:@"Delete" forState:UIControlStateNormal];
            [btnDelete setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [self.contentView addSubview:btnDelete];
            [btnDelete addTarget:self action:@selector(onDeleteCart:) forControlEvents:UIControlEventTouchUpInside];
            
            lbl_value_value = newLabel2;
            if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
                NSMutableArray * nameArray = [data firstObject];
                NSMutableArray * priceArray = [data lastObject];
                
                [lbl_title_value setText:[nameArray objectAtIndex:i]];
                lbl_value_value.text = [NSString stringWithFormat:@"$ %.2f", [[priceArray objectAtIndex:i] floatValue]];
            }else if([[data objectAtIndex:i] isKindOfClass:[StackCartItem class]]){
                StackCartItem * item = [data objectAtIndex:i];
                lbl_value_value.text = [NSString stringWithFormat:@"$ %.2f", item.drink_price];
                [lbl_title_value setText:item.item_name];
            }
        }
    }
}
- (void) onDeleteCart:(UIButton*)button
{
    int index = button.tag;
    [self.delegate CurrentCartCellDelegate_didDeleted:index];
}
@end
