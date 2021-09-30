//
//  AssignActionView.m
//  quickdrinks
//
//  Created by mojado on 6/22/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "AssignActionView.h"
#import "SCLAlertView.h"
#import "Util.h"

@implementation AssignActionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) initWithType:(DBAssignItem*) item
{
    self.m_info = item;
    if(item.type == 0){
        [self setBackgroundImage:[UIImage imageNamed:@"bg_moveView"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"bg_moveView"] forState:UIControlStateSelected];
    }else{
        [self setBackgroundImage:[UIImage imageNamed:@"ico_whiteCircle"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"ico_whiteCircle"] forState:UIControlStateSelected];
    }
    CGRect selfRect = CGRectMake(item.pos_x, item.pos_y, item.width, item.height);
    selfRect.origin.x = selfRect.origin.x * self.superview.frame.size.width;
    selfRect.origin.y = selfRect.origin.y * self.superview.frame.size.width;
    selfRect.size.width = selfRect.size.width  * self.superview.frame.size.width;
    selfRect.size.height = selfRect.size.height  * self.superview.frame.size.width;
    
    [self setFrame:selfRect];
    
    
    
    self.m_deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(selfRect.size.width - 25, -15, 40, 40)];
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    [self.m_deleteButton  addTarget:self action:@selector(onClickDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_deleteButton];
    [self.m_deleteButton setHidden:YES];
    
    if(self.m_titleLabel)
        [self.m_titleLabel removeFromSuperview];
    self.m_titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.m_titleLabel.textAlignment = NSTextAlignmentCenter;
    self.m_titleLabel.text = item.title;
    [self.m_titleLabel setNumberOfLines:0];
    [self.m_titleLabel setFont:[UIFont systemFontOfSize:11]];
    [self addSubview:self.m_titleLabel];
    
    
    if(self.m_staffnameLabel)
        [self.m_staffnameLabel removeFromSuperview];
    
    self.m_staffnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.frame.size.height - 30, self.frame.size.width-16, 30)];
    self.m_staffnameLabel.textAlignment = NSTextAlignmentCenter;
    self.m_staffnameLabel.numberOfLines = 0;
    self.m_staffnameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.m_staffnameLabel.text = @"";
    [self.m_staffnameLabel setFont:[UIFont systemFontOfSize:9]];
    [self.m_staffnameLabel setNumberOfLines:0];
    [self addSubview:self.m_staffnameLabel];
    
    if(self.m_info.type == 0){
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
        [pinchGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:pinchGestureRecognizer];
    }
    
    
    // creat and configure the pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
    
    UILongPressGestureRecognizer * longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGestureDetected:)];
    [longGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:longGestureRecognizer];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}
- (void) setText:(NSString*)str
{
    [self.m_titleLabel setText:str];
}

- (void)pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGFloat scale = [recognizer scale];
        [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, 1.0, scale)];
        [recognizer setScale:1.0];
        [self.delegate AssignActionViewDelegate_locationChanged:self];
    }
}

- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        [recognizer.view setTransform:CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        [self.delegate AssignActionViewDelegate_locationChanged:self];
    }
}
- (void)longGestureDetected:(UILongPressGestureRecognizer *)recognizer
{
    [self.m_deleteButton setHidden:NO];
//    [self.delegate AssignActionViewDelegate_longPressed:self];
}

- (void) tapGestureDetected:(UITapGestureRecognizer*)recognizer
{
    [self.delegate AssignActionViewDelegate_longPressed:self];
}

- (void) onClickDelete:(id) sender
{
    NSString *msg = @"Are you sure you want to delete this assign item?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
        [sender setHidden:YES];
    }];
    [alert addButton:@"Yes" actionBlock:^(void) {
        [self.delegate AssignActionViewDelegate_deleted:self];
    }];
    [alert showError:@"Delete Assign Item" subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (DBAssignItem*) getInfo
{
    self.m_info.title = self.m_titleLabel.text;
    self.m_info.pos_x = self.frame.origin.x / self.superview.frame.size.width;
    self.m_info.pos_y = self.frame.origin.y / self.superview.frame.size.width;
    self.m_info.width = self.frame.size.width / self.superview.frame.size.width;
    self.m_info.height = self.frame.size.height / self.superview.frame.size.width;
    return self.m_info;
}
@end
