//
//  BusinessOrderProcessCell.m
//  quickdrinks
//
//  Created by mojado on 7/14/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessOrderProcessCell.h"

@implementation CustomButtonForCheck
@end

@implementation BusinessOrderProcessCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (int) getCellHeightWithValue:(NSMutableArray*)data;
{
    int height = 150;
    for(NSObject * item in data){
        if([item isKindOfClass:[NSString class]]){
            height += 30;
        }else if([[(NSMutableArray*)item lastObject] isEqualToString:@""]){
            height += 45;
        }else{
            height += 45;
        }
    }
    height -= 55;
    return height;
}
- (void) initWithData:(NSMutableArray*)data
{
    cellData = data;
    
    
    
    for(UIView * subView in self.contentView.subviews){
        if([subView tag] == 100){
            [subView removeFromSuperview];
        }else if([subView isKindOfClass:[CustomButtonForCheck class]]){
            [subView removeFromSuperview];
        }
    }
    
    int cur_pos_y = 10;
    [self.lbl_view setHidden:YES];
    
   for(NSObject * item in data){
        if([item isKindOfClass:[NSString class]]){
            UIView * title_view = [[UIView alloc] initWithFrame:CGRectMake(72, cur_pos_y, self.lbl_view.frame.size.width, 30)];
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:title_view.bounds];
            [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            titleLabel.tag = 100;
            [title_view addSubview:titleLabel];
            [titleLabel setText:(NSString*)item];
            [self.contentView addSubview:title_view];
            title_view.tag = 100;
            cur_pos_y += 30;
        }else{
            UIView * title_view = [[UIView alloc] initWithFrame:CGRectMake(72, cur_pos_y, self.lbl_view.frame.size.width, 25)];
            UILabel * detailLabel = [[UILabel alloc] initWithFrame:title_view.bounds];
            title_view.tag = 100;
            [detailLabel setFont:[UIFont systemFontOfSize:13]];
            detailLabel.tag = 100;
            [title_view addSubview:detailLabel];
            NSString * title = [(NSMutableArray*)item firstObject];
            [detailLabel setText:title];
            [self.contentView addSubview:title_view];
            cur_pos_y += 25;
            title_view.tag = 100;
             if(![[(NSMutableArray*)item lastObject] isEqualToString:@""]){
                CustomButtonForCheck * button = [[CustomButtonForCheck alloc] initWithFrame:CGRectMake(65, cur_pos_y, 150, 20)];
                [button setTitle:@"customer instructions" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [button setFont:[UIFont systemFontOfSize:13]];
                [self.contentView addSubview:button];
                button.tag = [data indexOfObject:item];
                
                [button addTarget:self action:@selector(onInstruction:) forControlEvents:UIControlEventTouchUpInside];
                 
                 CustomButtonForCheck * otherbutton = [[CustomButtonForCheck alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, cur_pos_y, 80, 20)];
                 [otherbutton setTitle:@"/ drink recipe" forState:UIControlStateNormal];
                 [otherbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                 [otherbutton setFont:[UIFont systemFontOfSize:13]];
                 [self.contentView addSubview:otherbutton];
                 otherbutton.tag = [data indexOfObject:item];
                 cur_pos_y += 20;
                 
                 [otherbutton addTarget:self action:@selector(onDrinkRecipe:) forControlEvents:UIControlEventTouchUpInside];

             }else{
                 CustomButtonForCheck * button = [[CustomButtonForCheck alloc] initWithFrame:CGRectMake(65, cur_pos_y, 150, 20)];
                 [button setTitle:@"customer instructions" forState:UIControlStateNormal];
                 [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                 [button setFont:[UIFont systemFontOfSize:13]];
                 [self.contentView addSubview:button];
                 button.tag = [data indexOfObject:item];
                 
                 [button addTarget:self action:@selector(onNoInstruction:) forControlEvents:UIControlEventTouchUpInside];
                 
                 CustomButtonForCheck * otherbutton = [[CustomButtonForCheck alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, cur_pos_y, 80, 20)];
                 [otherbutton setTitle:@"/ drink recipe" forState:UIControlStateNormal];
                 [otherbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                 [otherbutton setFont:[UIFont systemFontOfSize:13]];
                 [self.contentView addSubview:otherbutton];
                 otherbutton.tag = [data indexOfObject:item];
                 cur_pos_y += 20;
                 
                 [otherbutton addTarget:self action:@selector(onDrinkRecipe:) forControlEvents:UIControlEventTouchUpInside];
             }
            
        }
    }
}

- (IBAction)onClick:(id)sender {
    [self.delegate BusinessOrderTableViewCellDelegate_actionAtCell:self];
}
- (void)onInstruction:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    NSMutableArray * data = [cellData objectAtIndex:tag];
    [self.delegate BusinessOrderTableViewCellDelegate_actionAtCellInstruction:self :[data objectAtIndex:1]];
}

- (void)onDrinkRecipe:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    NSMutableArray * data = [cellData objectAtIndex:tag];
    [self.delegate BusinessOrderTableViewCellDelegate_actionAtCellDrinkRecipe:self :[data lastObject]];
}

- (void)onNoInstruction:(id)sender
{
    int tag = ((UIButton*)sender).tag;
    NSMutableArray * data = [cellData objectAtIndex:tag];
    [self.delegate BusinessOrderTableViewCellDelegate_actionAtCellNoInstruction:self :[data objectAtIndex:1]];
}
@end
