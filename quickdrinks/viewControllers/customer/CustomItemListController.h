//
//  CustomItemListController.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCong.h"
#import "QDBaseViewController.h"

@interface CustomItemListController : QDBaseViewController
@property (nonatomic, retain) DBUsers * m_selected_business;
@property (atomic) int m_selectedCateogry;
@property (atomic) int m_selectedSubCategory;
@property (atomic) int isOpened;

- (void) changeBusinessTo:(NSString *) userId;
@end
