//
//  CustomCheckerGroup.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomCheckerGroup.h"

@implementation CustomCheckerBox
- (IBAction)onClickAction:(id)sender
{
    [self.btn_checkBox setSelected:YES];
    [self.delegate CustomCheckerBoxDelegate_didSelected:(int)self.tag];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void) setSelected:(BOOL)res
{
    [self.btn_checkBox setSelected:res];
}
- (BOOL) isSelected
{
    return [self.btn_checkBox isSelected];
}
@end

@interface CustomCheckerGroup () <CustomCheckerBoxDelegate>
@end
@implementation CustomCheckerGroup

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initViewDelegate
{
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[CustomCheckerBox class]]){
            ((CustomCheckerBox*)subview).delegate = self;
            if(self.receiver){
                ((CustomCheckerBox*)subview).delegate = self.receiver;
            }
        }
    }
}
- (void) setSelectItem:(int)index
{
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[CustomCheckerBox class]]){
            if(subview.tag != index){
                [((CustomCheckerBox*)subview) setSelected:NO];
            }else{
                [((CustomCheckerBox*)subview) setSelected:YES];
            }
        }
    }
}
- (int) getSelectedIndex
{
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[CustomCheckerBox class]]){
            if([((CustomCheckerBox*)subview) isSelected]){
                return (int)subview.tag;
            }
        }
    }
    return -1;
}
- (void)CustomCheckerBoxDelegate_didSelected:(int)tag
{
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[CustomCheckerBox class]]){
            if(subview.tag != tag){
                [((CustomCheckerBox*)subview) setSelected:NO];
            }
        }
    }
}
@end
