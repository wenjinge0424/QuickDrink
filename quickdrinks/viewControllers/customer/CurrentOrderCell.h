//
//  CurrentOrderCell.h
//  quickdrinks
//
//  Created by mojado on 6/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentOrderCellView : UIView
@property (strong, nonatomic) IBOutlet UILabel * lbl_name;
@property (strong, nonatomic) IBOutlet UILabel * lbl_value;
@property (strong, nonatomic) IBOutlet UIButton * btnDelete;
@end

@interface CurrentOrderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet CurrentOrderCellView * view_orderitem;
@property (strong, nonatomic) IBOutlet UILabel * lbl_total;
@property (strong, nonatomic) IBOutlet UILabel * lbl_taxes;

+ (int) getCellHeightWithValue:(int)count;
- (void) initWithData:(NSMutableArray*)data;

@end

@protocol CurrentCartCellDelegate
- (void) CurrentCartCellDelegate_didDeleted:(int)index;
@end

@interface CurrentCartCell : UITableViewCell
@property (nonatomic, retain) id<CurrentCartCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet CurrentOrderCellView * view_orderitem;
@property (strong, nonatomic) IBOutlet UILabel * lbl_total;
@property (strong, nonatomic) IBOutlet UILabel * lbl_taxes;

+ (int) getCellHeightWithValue:(int)count;
- (void) initWithData:(NSMutableArray*)data;

@end
