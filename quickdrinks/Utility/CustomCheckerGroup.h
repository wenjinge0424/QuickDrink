//
//  CustomCheckerGroup.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol CustomCheckerBoxDelegate
- (void)CustomCheckerBoxDelegate_didSelected:(int)tag;
@end

@interface CustomCheckerBox : UIView
@property (nonatomic, retain)IBOutlet UIButton * btn_checkBox;
@property (nonatomic, retain)IBOutlet UILabel * lbl_title;
@property (nonatomic, retain) id<CustomCheckerBoxDelegate> delegate;
- (IBAction)onClickAction:(id)sender;
- (void) setSelected:(BOOL)res;
- (BOOL) isSelected;
@end

@interface CustomCheckerGroup : UIView
@property (nonatomic, retain) id receiver;
- (void) initViewDelegate;
- (void) setSelectItem:(int)index;
- (int) getSelectedIndex;
@end
