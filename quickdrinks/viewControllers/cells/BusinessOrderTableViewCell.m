//
//  BusinessOrderTableViewCell.m
//  quickdrinks
//
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessOrderTableViewCell.h"

@implementation BusinessOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onCloseOrder:(id)sender
{
    [self.delegate BusinessOrderTableViewCellDelegate_actionWithStyle:0 atCell:self];
}
- (IBAction)onStartOrder:(id)sender
{
    [self.delegate BusinessOrderTableViewCellDelegate_actionWithStyle:1 atCell:self];
}
- (IBAction)onCompleteOrder:(id)sender
{
    [self.delegate BusinessOrderTableViewCellDelegate_actionWithStyle:2 atCell:self];
}
- (IBAction)onInstruction:(id)sender
{
    [self.delegate BusinessOrderTableViewCellDelegate_actionWithStyle:3 atCell:self];
}
@end
