//
//  NotifyTableViewCell.h
//  quickdrinks
//
//  Created by mojado on 7/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_user;
@property (strong, nonatomic) IBOutlet UILabel *lbl_name;
@property (strong, nonatomic) IBOutlet UILabel *lbl_time;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@end
