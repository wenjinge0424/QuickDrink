//
//  UITextField+Complete.m
//  quickdrinks
//
//  Created by mojado on 6/13/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "UITextField+Complete.h"

@implementation UITextField (Complete)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)removeCheck
{
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[UIImageView class]] && subview.tag == 100){
            [subview removeFromSuperview];
        }
    }
}
- (void)checkComplete:(BOOL (^ __nullable)())checkFunc
{
//    [UIView animateWithDuration:0.1 animations:^(void){} completion:^(BOOL finished){}];
    
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[UIImageView class]] && subview.tag == 100){
            [subview removeFromSuperview];
        }
    }

    if(checkFunc()){
        CGRect ImageViewRect = CGRectMake(0, 0, 20, 20);
        ImageViewRect.origin.x = self.frame.size.width - 26;
        ImageViewRect.origin.y = self.frame.size.height / 2 - 13;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:ImageViewRect];
        imageView.tag = 100;
        [imageView setImage:[UIImage imageNamed:@"ico_blueCheck"]];
        [self addSubview:imageView];
    }else{
        CGRect ImageViewRect = CGRectMake(0, 0, 20, 20);
        ImageViewRect.origin.x = self.frame.size.width - 26;
        ImageViewRect.origin.y = self.frame.size.height / 2 - 10;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:ImageViewRect];
        imageView.tag = 100;
        [imageView setImage:[UIImage imageNamed:@"ico_redCheck"]];
        [self addSubview:imageView];
    }
}

- (CGRect) textRectForBounds:(CGRect)bounds
{
    bounds.size.width = bounds.size.width - 20.f;
    return bounds;
}
- (CGRect) editingRectForBounds:(CGRect)bounds
{
    bounds.size.width = bounds.size.width - 20.f;
    return bounds;
}
@end
