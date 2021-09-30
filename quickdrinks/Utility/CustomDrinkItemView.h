//
//  CustomDrinkItemView.h
//  quickdrinks
//
//  Created by mojado on 6/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrinkItem.h"

@protocol CustomDrinkItemViewDelegate
- (void)CustomDrinkItemViewDelegate_clicked:(UIView*)view;
@end

@interface CustomDrinkItemView : UIView
@property (atomic) BOOL isCustomMode;
@property (nonatomic, retain) id<CustomDrinkItemViewDelegate>delegate;
@property (nonatomic, retain)IBOutlet UILabel * lbl_title;
@property (nonatomic, retain)IBOutlet UILabel * lbl_description;
@property (nonatomic, retain)IBOutlet UILabel * lbl_price1;
@property (nonatomic, retain)IBOutlet UILabel * lbl_price2;
@property (nonatomic, retain)IBOutlet UIImageView * img_item;
@property (nonatomic, retain)IBOutlet UIButton * btn_favour;

@property (nonatomic, retain)IBOutlet UIImageView * img_stock;

@property (nonatomic, retain) DrinkItem * m_item;

- (void) setInformation:(DrinkItem * )item;
- (void) checkFavourite:(NSMutableArray*) items;

- (IBAction)onClickAction:(id)sender;
@end
