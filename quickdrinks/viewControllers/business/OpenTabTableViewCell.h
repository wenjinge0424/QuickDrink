//
//  OpenTabTableViewCell.h
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//160

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface OpenTabTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *img_user;
@property (strong, nonatomic) IBOutlet UILabel *lbl_name;
@property (strong, nonatomic) IBOutlet UILabel *lbl_location;
@property (strong, nonatomic) IBOutlet UILabel *lbl_dateTime;
@property (strong, nonatomic) IBOutlet UILabel *lbl_total;
@property (strong, nonatomic) IBOutlet UILabel *lbl_orderTotal;
@property (strong, nonatomic) IBOutlet UIImageView *img_paid;

@property (strong, nonatomic) IBOutlet UIView *view_orderitem;
@property (strong, nonatomic) IBOutlet UILabel *lbl_value1;
@property (strong, nonatomic) IBOutlet UILabel *lbl_value2;
@property (weak, nonatomic) IBOutlet UIButton *btn_requestPayment;

+ (int) getCellHeightWithValue:(int)count;
- (float) initWithData:(NSMutableArray*)data;
@end
