//
//  BusinessEditDrinkController.m
//  quickdrinks
//
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessEditDrinkController.h"

@interface BusinessEditDrinkController ()

@end

@implementation BusinessEditDrinkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
