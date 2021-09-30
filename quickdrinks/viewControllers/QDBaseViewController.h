//
//  QDBaseViewController.h
//  quickdrinks
//
//  Created by mojado on 11/28/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDBaseViewController : UIViewController <UITextFieldDelegate>
- (void) addTextField:(UITextField*) textfield withCheckFunction:(BOOL (^)(NSString* str))checkBlock
                                                withSuccessAction:(void (^)(void)) successAction
                                                withFailAction:(void (^)(void)) failAction
                                                withDefaultAction:(void (^)(void)) defaultAction;
- (void) addActionField:(UIView*) textfield withCheckFunction:(BOOL (^)(id str))checkBlock;
- (void) addActionField:(UIView*) textfield withCheckFunction:(BOOL (^)(id str))checkBlock
                                                withSuccessAction:(void (^)(void)) successAction
                                                withFailAction:(void (^)(void)) failAction
                                                withDefaultAction:(void (^)(void)) defaultAction;

- (void) onDone:(void (^)(void)) successAction withFailAction:(void (^)(NSString * message, id tagetView)) failAction;


- (void) tableChecker:(UITableView*)tablView;
@end
