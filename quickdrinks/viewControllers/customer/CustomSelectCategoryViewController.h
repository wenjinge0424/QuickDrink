//
//  CustomSelectCategoryViewController.h
//  quickdrinks
//
//  Created by developer on 3/18/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackMemory.h"
#import "DBCong.h"

@interface CustomSelectCategoryViewController : UIViewController
@property (nonatomic, retain) DBUsers * m_selected_business;
@property (atomic) int m_selectedCateogry;
@property (atomic) int m_selectedSubCategory;
@property (atomic) int isOpened;
@end
