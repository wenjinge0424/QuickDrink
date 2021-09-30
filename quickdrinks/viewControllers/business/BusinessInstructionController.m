//
//  BusinessInstructionController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessInstructionController.h"
#import "DBCong.h"
#import "Util.h"

@interface BusinessInstructionController ()
@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@property (strong, nonatomic) IBOutlet UITextView *edt_textView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_type;

@end

@implementation BusinessInstructionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.lbl_title setText:self.m_title];
    
    if(self.instructionType == DRINK_RECIPE){
        [self.lbl_type setText:@"Drink Recipe"];
        [self.edt_textView setText:self.m_recipe];
    }else{
        [self.lbl_type setText:@"Customer Instruction"];
        [self.edt_textView setText:self.m_str];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
