//
//  UITextField+Complete.h
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextField (Complete)
- (void)checkComplete:(BOOL (^ __nullable)())checkFunc;
- (void)removeCheck;
@end
