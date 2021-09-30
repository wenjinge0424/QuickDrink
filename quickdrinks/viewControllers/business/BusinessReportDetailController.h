//
//  BusinessReportDetailController.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessReportDetailController : UIViewController
@property (nonatomic, retain) NSString * m_title;
@property (nonatomic, retain) NSString * m_subTitle;

@property (atomic) int sortType;
@property (nonatomic, retain) NSDate * stDate;
@property (nonatomic, retain) NSDate * edDate;

@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet UILabel *lbl_subTitle;
@property (strong, nonatomic) IBOutlet UITableView *m_dataTable;
@end
