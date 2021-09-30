//
//  BusinessTabBarController.m
//  quickdrinks
//
//  Created by mojado on 6/7/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessTabBarController.h"
#import "DBCong.h"
#import "Util.h"

@interface BusinessTabBarController ()<UITabBarControllerDelegate>
{
    BOOL isSelectedOrder;
}
@end

@implementation BusinessTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    isSelectedOrder = NO;
    [self performSelector:@selector(checkNewOffers) withObject:nil afterDelay:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) checkNewOffers
{
//    if(isSelectedOrder){
//        return;
//    }
    
    NSUserDefaults * detalts = [NSUserDefaults standardUserDefaults];
    NSString * checkedString = [detalts valueForKey:@"order_check_date"];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss ZZZ"];
    NSDate * date = [dateFormatter dateFromString:checkedString];
    if(!date){
        NSDateFormatter *dateFormatter2=[[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"MM-dd-yyyy"];
        NSString * dateString1 = [dateFormatter2 stringFromDate:[NSDate date]];
        dateString1 = [dateString1 stringByAppendingString:@" 00:00:00 +0000"];
        date = [dateFormatter dateFromString:dateString1];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
        if(defaultUser){
            if(defaultUser.row_id){
                PFQuery * query = [PFQuery queryWithClassName:DB_ORDER_ITEM];
                [query whereKey:@"owner_id" equalTo:defaultUser.row_id];
                [query whereKey:@"step" equalTo:[NSNumber numberWithInt:0]];
                if(date){
                    [query whereKey:@"updatedAt" greaterThan:date];
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
                    if(!error){
                        int count = (int)[objects count];
                        UITabBarItem * secondItem = [[self.tabBar items] objectAtIndex:1];
                        if(count > 0){
                            secondItem.badgeValue = [NSString stringWithFormat:@"%d", count];
                            NSLog(@"badge set");
                        }else{
                            secondItem.badgeValue = nil;
                        }
                    }else{
                    }
                }];
            }
        }
    });
    [self performSelector:@selector(checkNewOffers) withObject:nil afterDelay:5];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if(tabBarController.selectedIndex == 0){
        UINavigationController * navController = [[tabBarController viewControllers] objectAtIndex:0];
        if(navController){
            [navController popToRootViewControllerAnimated:YES];
        }
    }else if (tabBarController.selectedIndex == 1){
        isSelectedOrder = YES;
        UITabBarItem * secondItem = [[self.tabBar items] objectAtIndex:1];
        secondItem.badgeValue = nil;
        
        //////
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm:ss ZZZ"];
        NSUserDefaults * detalts = [NSUserDefaults standardUserDefaults];
        [detalts setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"order_check_date"];
        [detalts synchronize];
        
    } else if(tabBarController.selectedIndex == 2){
        UINavigationController * navController = [[tabBarController viewControllers] objectAtIndex:2];
        if(navController){
            [navController popToRootViewControllerAnimated:YES];
        }
    }else if(tabBarController.selectedIndex == 3){
        UINavigationController * navController = [[tabBarController viewControllers] objectAtIndex:3];
        if(navController){
            [navController popToRootViewControllerAnimated:YES];
        }
    }else {
        isSelectedOrder = NO;
    }
}
@end
