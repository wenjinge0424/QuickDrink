//
//  CustomDrinkItemView.m
//  quickdrinks
//
//  Created by mojado on 6/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomDrinkItemView.h"
#import "Util.h"
#import "DBCong.h"

@implementation CustomDrinkItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
 
 @property (nonatomic, retain)IBOutlet UILabel * lbl_title;
 @property (nonatomic, retain)IBOutlet UILabel * lbl_description;
 @property (nonatomic, retain)IBOutlet UILabel * lbl_price1;
 @property (nonatomic, retain)IBOutlet UILabel * lbl_price2;
 @property (nonatomic, retain)IBOutlet UIImageView * img_item;
 @property (nonatomic, retain)IBOutlet UIButton * btn_favour;
 
}
*/
- (void) layoutSubviews
{
    [super layoutSubviews];
    
}
- (void) setInformation:(DrinkItem * )item
{
    self.m_item = item;
    self.lbl_title.text = item.row_name;
    self.lbl_description.text = item.row_description;
    self.lbl_price1.text = [NSString stringWithFormat:@"%d",(int)item.row_price];
    UIFont * font = self.lbl_price1.font;
    int length = self.lbl_price1.text.length;
    if(length > 2){
        float fontSize = 27;
        fontSize = fontSize / (length/2.f);
        UIFont * newfont = [UIFont fontWithName:font.fontName size:fontSize];
        [self.lbl_price1 setFont:newfont];
    }else{
        float fontSize = 27;
        UIFont * newfont = [UIFont fontWithName:font.fontName size:fontSize];
        [self.lbl_price1 setFont:newfont];
    }
    
    if((int)((item.row_price - (int)item.row_price)*100) > 9){
        self.lbl_price2.text = [NSString stringWithFormat:@"%d",(int)((item.row_price - (int)item.row_price)*100)];
    }else{
        self.lbl_price2.text = [NSString stringWithFormat:@"0%d",(int)((item.row_price - (int)item.row_price)*100)];
    }
    [self.img_item setImage:[UIImage new]];
    [Util setImage:self.img_item imgUrl:item.row_img];
    
    if(item.row_isTemporarily == 1){
        [self.img_stock setHidden:NO];
    }else{
        [self.img_stock setHidden:YES];
    }
}
- (void) checkFavourite:(NSMutableArray*) items
{
    NSString * drinkId = self.m_item.row_id;
    for(NSString * subString in items){
        if([subString isEqualToString:drinkId]){
            [self.btn_favour setSelected:YES];
            return;
        }
    }
    [self.btn_favour setSelected:NO];
}
- (IBAction)onClickAction:(id)sender
{
    if(self.isCustomMode){
        [self.btn_favour setSelected:!self.btn_favour.isSelected];
    }
    [self.delegate CustomDrinkItemViewDelegate_clicked:self];
    
}
@end
