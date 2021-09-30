//
//  AddOrderDlg.h
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCheckerGroup.h"
#import "DBCong.h"


@protocol AddOrderDlgDelegate
- (void)AddOrderDlgDelegate_complete;
@end

@interface AddOrderDlg : UIView
@property (nonatomic, retain) id<AddOrderDlgDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIImageView *img_item;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title1;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title2;
@property (strong, nonatomic) IBOutlet UILabel *lbl_title3;
@property (strong, nonatomic) IBOutlet UILabel *lbl_price;
@property (strong, nonatomic) IBOutlet UILabel *lbl_desc;
@property (strong, nonatomic) IBOutlet UILabel *edt_count;
@property (strong, nonatomic) IBOutlet CustomCheckerGroup *checker_group;
@property (strong, nonatomic) IBOutlet UITextField *edt_tableNo;
@property (strong, nonatomic) IBOutlet UITextView *edt_instruction;

@property (strong, nonatomic) UIViewController * parentViewController;

@property (strong, nonatomic) IBOutlet UIView *m_glassView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *m_glassViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *m_glass1;
@property (strong, nonatomic) IBOutlet UIButton *m_glass2;
@property (strong, nonatomic) IBOutlet UIButton *m_glass3;
@property (strong, nonatomic) IBOutlet UIButton *m_glass4;
@property (strong, nonatomic) IBOutlet UIButton *m_glass5;
@property (strong, nonatomic) IBOutlet UIButton *m_glass6;

- (void) initWithDrinkInfo:(DrinkItem*)item;

- (IBAction)onClose:(id)sender;
- (IBAction)onUp:(id)sender;
- (IBAction)onDown:(id)sender;
- (IBAction)onAddtoOrder:(id)sender;

- (IBAction)onGlass1:(id)sender;
- (IBAction)onGlass2:(id)sender;
- (IBAction)onGlass3:(id)sender;
- (IBAction)onGlass4:(id)sender;
- (IBAction)onGlass5:(id)sender;
- (IBAction)onGlass6:(id)sender;

- (void)initDelegate;
@end
