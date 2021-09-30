//
//  CustomComboBox.m
//  quickdrinks
//
//  Created by mojado on 6/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomComboBox.h"
#import "CommonAPI.h"

@implementation CustomComboBox

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)didMoveToWindow
{
//    [self.lbl_title setText:self.m_selectData];
}
- (IBAction)onClickAction:(id)sender
{
    if(self.type == 1){
        [PickerView showDatePickerWithTitle:self.m_comboTitle dateMode:UIDatePickerModeDate selectionBlock:^(NSDate * selectedDate){
            NSString * str = [CommonAPI convertDateToString:selectedDate];
            [self.lbl_title setText:str];
            self.m_selectData = str;
            [self.delegate CustomComboBox_SelectedItem:str atCombo:self];
        }];
    }else if(self.type == 2){
        [PickerView showDatePickerWithTitle:self.m_comboTitle dateMode:UIDatePickerModeTime selectionBlock:^(NSDate * selectedDate){
            NSString * str = [CommonAPI convertTimeToString:selectedDate];
            [self.lbl_title setText:str];
            self.m_selectData = str;
            [self.delegate CustomComboBox_SelectedItem:str atCombo:self];
        }];
    }else{
        if(!self.m_containDatas || self.m_containDatas.count == 0)
            return;
        [PickerView showPickerWithOptions:self.m_containDatas title:self.m_comboTitle selectionBlock:^(NSString * selectStr){
            [self.lbl_title setText:selectStr];
            self.m_selectData = selectStr;
            [self.delegate CustomComboBox_SelectedItem:selectStr atCombo:self];
        }];
    }
}
@end
