//
//  BusinessInstructionController.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DRINK_RECIPE        0
#define DRINK_INSTRUCTION   1

@interface BusinessInstructionController : UIViewController
@property (nonatomic, retain) NSString * m_str;
@property (nonatomic, retain) NSString * m_recipe;
@property (nonatomic, retain) NSString * m_title;
@property (atomic) int instructionType;
@end
