//
//  BusinessItemTableViewCell.h
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomDrinkItemView.h"


@protocol BusinessItemTableViewCellDelegate
- (void)BusinessItemTableViewCellDelegate_clickedAt:(UITableViewCell*)cell atIndex:(int)index withOption:(int)option;
@end

@interface BusinessItemTableViewCell : UITableViewCell
@property (atomic) BOOL isCustomMode;
@property (nonatomic, retain) id<BusinessItemTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet CustomDrinkItemView *m_item1View;
@property (weak, nonatomic) IBOutlet CustomDrinkItemView *m_item2View;
- (void)initDelegate;
@end


@interface BusinessItemTableViewTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel  * lbl_title;


@end
