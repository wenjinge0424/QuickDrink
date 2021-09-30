//
//  CustomerTabBarController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerTabBarController.h"
#import "CustomerHomeController.h"
#import "CustomItemListController.h"
#import "CustomNotifyViewController.h"

@interface CustomerTabBarController ()<UITabBarControllerDelegate>
{
    NSString * m_ownerId;
    int m_categoryId;
    int m_subCategoryid;
}
@end

@implementation CustomerTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
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
- (void) gotoBussinessScreen:(NSString*) ownerId :(int) categoryid :(int)subcategory
{
    m_ownerId = ownerId;
    m_categoryId = categoryid;
    m_subCategoryid = subcategory;
    [self setSelectedIndex:0];
    [self performSelector:@selector(onGotoBusinessMain:) withObject:ownerId afterDelay:0.5];
}
- (void)onGotoBusinessMain:(NSString*)ownerId
{
    UINavigationController * mainNav = [self.viewControllers firstObject];
    if([mainNav.visibleViewController isKindOfClass:[CustomerHomeController class]]){
        CustomerHomeController * homeController = (CustomerHomeController*)mainNav.visibleViewController;
        [homeController gotoBusinessHome:ownerId :m_categoryId :m_subCategoryid];
    }else if([mainNav.visibleViewController isKindOfClass:[CustomItemListController class]]){
        CustomItemListController * homeController = (CustomItemListController*)mainNav.visibleViewController;
        homeController.m_selectedCateogry = m_categoryId;
        homeController.m_selectedSubCategory = m_subCategoryid;
        [homeController changeBusinessTo:ownerId];
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0){
        UINavigationController * navController = [[tabBarController viewControllers] firstObject];
        if(navController){
            UIViewController * controller = [[navController viewControllers] lastObject];
            if([controller isKindOfClass:[CustomNotifyViewController class]]){
                [controller.navigationController popViewControllerAnimated:YES];
            }
        }
    }else if(tabBarController.selectedIndex == 3){
        UINavigationController * navController = [[tabBarController viewControllers] objectAtIndex:3];
        if(navController){
            [navController popToRootViewControllerAnimated:YES];
        }
    }
}
@end
