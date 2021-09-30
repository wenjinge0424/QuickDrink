//
//  AssignActionView.h
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBAssignItem.h"

@protocol AssignActionViewDelegate
- (void)AssignActionViewDelegate_longPressed:(UIView*)view;
- (void)AssignActionViewDelegate_deleted:(UIView*)view;
- (void)AssignActionViewDelegate_locationChanged:(UIView*)view;
@end

@interface AssignActionView : UIButton <UIGestureRecognizerDelegate>
@property (nonatomic, retain) id<AssignActionViewDelegate>delegate;
@property (nonatomic, retain) DBAssignItem * m_info;

@property (nonatomic, retain) UILabel * m_titleLabel;
@property (nonatomic, retain) UIButton * m_deleteButton;

@property (nonatomic, retain) UILabel * m_staffnameLabel;

- (void) initWithType:(DBAssignItem*) item;
- (void) setText:(NSString*)str;
- (DBAssignItem*) getInfo;
@end
