//
//  OpenTabTableViewCell.m
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "OpenTabTableViewCell.h"
#import "Util.h"

@implementation OpenTabTableViewCell

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
    return 190 + (30 * (count - 1));
}
- (float) initWithData:(NSMutableArray*)data
{
    float total = 0.f;
    
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
        
        
        UILabel * lbl_title_value = self.lbl_value1;
        UILabel * lbl_value_value = self.lbl_value2;
        [self.lbl_value1 setHidden:YES];
        [self.lbl_value2 setHidden:YES];
        
        
        int cellcount = data.count;
        if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
            cellcount = [[data firstObject] count];
        }
        
        
        for(int i = 0; i< cellcount;i++){
            stPos.y += 30 * i;
            CGRect lbl_titleRect = [self.view_orderitem convertRect:self.lbl_value1.frame toView:self];
            lbl_titleRect.origin.y += 30 *i;
            lbl_titleRect.size.width = 200;
            UILabel * newLabel = [[UILabel alloc] initWithFrame:lbl_titleRect];
            newLabel.tag = 100;
            [newLabel setFont:[UIFont systemFontOfSize:14]];
            [newLabel setTextAlignment:NSTextAlignmentLeft];
            [self.contentView addSubview:newLabel];
            lbl_title_value = newLabel;
            
            
            CGRect lbl_valueRect = lbl_titleRect;
            lbl_valueRect.origin.x = [UIScreen mainScreen].bounds.size.width - 200;
            lbl_valueRect.size.width = 180;
            
//            if([[Util deviceType] isEqualToString:@"iPhone 7"] || [[Util deviceType] isEqualToString:@"iPhone 7 Plus"] ){
//                lbl_valueRect.origin.x = [UIScreen mainScreen].bounds.size.width - 220;
//            }
            
            UILabel * newLabel2 = [[UILabel alloc] initWithFrame:lbl_valueRect];
            newLabel2.tag = 100;
            [newLabel2 setFont:[UIFont systemFontOfSize:14]];
            [newLabel2 setTextAlignment:NSTextAlignmentRight];
            [self.contentView addSubview:newLabel2];
            //                [newLabel2 setBackgroundColor:[UIColor redColor]];
            
            lbl_value_value = newLabel2;
            if([[data objectAtIndex:0] isKindOfClass:[NSMutableArray class]]){
                NSMutableArray * nameArray = [data firstObject];
                NSMutableArray * priceArray = [data lastObject];
                
                [lbl_title_value setText:[nameArray objectAtIndex:i]];
                lbl_value_value.text = [NSString stringWithFormat:@"$ %.2f", [[priceArray objectAtIndex:i] floatValue]];
                
                total += [[priceArray objectAtIndex:i] floatValue];
            }
        }
    }
    return total;
}
- (void) prepareForReuse
{
    [super prepareForReuse];
    BOOL hasContentView = [self.subviews containsObject:self.contentView];
    if(hasContentView){
        self.lbl_name.text = @"";
        self.img_user.image = nil;
    }
}
@end
