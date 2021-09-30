//
//  BusinessItemTableViewCell.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessItemTableViewCell.h"
@interface BusinessItemTableViewCell () <CustomDrinkItemViewDelegate>
@end
@implementation BusinessItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initDelegate
{
    self.m_item1View.delegate = self;
    self.m_item2View.delegate = self;
    
    if(self.isCustomMode){
        [self.m_item1View setIsCustomMode:YES];
        [self.m_item2View setIsCustomMode:YES];
    }
    
    
    UITapGestureRecognizer * recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickView:)];
    UITapGestureRecognizer * recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickView:)];
    [self.m_item1View addGestureRecognizer:recognizer1];
    [self.m_item2View addGestureRecognizer:recognizer2];
}
- (void)CustomDrinkItemViewDelegate_clicked:(UIView *)view
{
    if(view == self.m_item1View){
        [self.delegate BusinessItemTableViewCellDelegate_clickedAt:self atIndex:0 withOption:1];
    }else{
        [self.delegate BusinessItemTableViewCellDelegate_clickedAt:self atIndex:1 withOption:1];
    }
}
-(void)onClickView:(UITapGestureRecognizer*)recog
{
    UIView * view = recog.view;
    if(view == self.m_item1View){
        [self.delegate BusinessItemTableViewCellDelegate_clickedAt:self atIndex:0 withOption:0];
    }else{
        [self.delegate BusinessItemTableViewCellDelegate_clickedAt:self atIndex:1 withOption:0];
    }
}
@end

@implementation BusinessItemTableViewTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.contentView.frame;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    [self.contentView setFrame:rect];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
