//
//  DateTimeCombo.m
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "DateTimeCombo.h"


@implementation DateTimeCombo

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onClickAction:(id)sender
{
    int SCREEN_WIDTH = [[UIApplication sharedApplication] keyWindow].bounds.size.width;
    
    UIAlertController * aac = [UIAlertController alertControllerWithTitle:@"" message:self.m_title preferredStyle:UIAlertControllerStyleActionSheet];
    
    self.dtPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, SCREEN_WIDTH - 16, 216)];
    self.dtPicker.datePickerMode = UIDatePickerModeTime;
    
    UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerDateToolbar sizeToFit];
    
    UIView * aboveBlurLayer= [aac.view.subviews firstObject];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DatePickerDoneClick)];
    
    [barItems addObject:doneBtn];
    
    [pickerDateToolbar setItems:barItems animated:NO];
    
    [aboveBlurLayer addSubview:pickerDateToolbar];
    [aboveBlurLayer addSubview:_dtPicker];
    [aboveBlurLayer setBounds:CGRectMake(0, 0, 320 , 260)];
    [aac.view setBounds:CGRectMake(0, 0, 320 , 260)];
    [self.parentViewController presentViewController:aac animated:YES completion:nil];
    
}
- (void)DatePickerDoneClick
{
    
}
@end
