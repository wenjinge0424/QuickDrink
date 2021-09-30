//
//  CustomComboBox.h
//  quickdrinks
//
//  Created by mojado on 6/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerView.h"

@protocol CustomComboBox_SelectedItem
- (void)CustomComboBox_SelectedItem:(NSString * )item atCombo:(UIView*) combo;
@end

@interface CustomComboBox : UIView
@property (nonatomic, retain)IBOutlet UILabel * lbl_title;
@property (nonatomic, retain) NSMutableArray * m_containDatas;
@property (nonatomic, retain) NSString * m_selectData;
@property (nonatomic, retain) NSString * m_comboTitle;
@property (nonatomic, retain) id<CustomComboBox_SelectedItem> delegate;

@property (atomic) int type;
- (IBAction)onClickAction:(id)sender;
@end
