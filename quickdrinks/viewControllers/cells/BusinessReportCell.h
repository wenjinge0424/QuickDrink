//
//  BusinessReportCell.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessReportCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet UILabel *lbl_value;
@property (strong, nonatomic) IBOutlet UILabel *lbl_subvalue;

@end
