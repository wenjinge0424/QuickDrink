//
//  BusinessOrderTableViewCell.h
//  quickdrinks
//
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BusinessOrderTableViewCellDelegate
- (void)BusinessOrderTableViewCellDelegate_actionWithStyle:(int)style atCell:(UITableViewCell*)cell;
@end

@interface BusinessOrderTableViewCell : UITableViewCell
@property (nonatomic, retain) id<BusinessOrderTableViewCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_tableTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subTitle1;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subTitle2;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subTitle3;
@property (weak, nonatomic) IBOutlet UILabel *lbl_secondTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title4;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title5;

@property (weak, nonatomic) IBOutlet UIImageView *img_user;

@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
- (IBAction)onCloseOrder:(id)sender;
- (IBAction)onStartOrder:(id)sender;
- (IBAction)onCompleteOrder:(id)sender;
- (IBAction)onInstruction:(id)sender;
@end
