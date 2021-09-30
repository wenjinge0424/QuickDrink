//
//  DateTimeCombo.h
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateTimeCombo : UIView <UIActionSheetDelegate>
@property (nonatomic, retain)IBOutlet UILabel * lbl_title;
@property (nonatomic, retain) UIDatePicker * dtPicker;
@property (nonatomic, retain) UIViewController * parentViewController;
@property (nonatomic, retain) NSString * m_title;
- (IBAction)onClickAction:(id)sender;
@end
