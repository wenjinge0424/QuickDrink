//
//  MainNavigationController.m
//  quickdrinks
//
//  Created by mojado on 7/26/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()
@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    }
- (void) setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    
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

@end
