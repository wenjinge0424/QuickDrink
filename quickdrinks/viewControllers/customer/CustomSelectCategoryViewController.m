//
//  CustomSelectCategoryViewController.m
//  quickdrinks
//
//  Created by developer on 3/18/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "CustomSelectCategoryViewController.h"
#import "CustomItemListController.h"

@interface CustomSelectCategoryViewController ()

@end

@implementation CustomSelectCategoryViewController

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
- (IBAction)onSelectBeer:(id)sender {
    self.m_selectedCateogry = 1;
    [self goToCustomItemList];
}
- (IBAction)onSelectWine:(id)sender {
    self.m_selectedCateogry =3;
    [self goToCustomItemList];
}
- (IBAction)onSelectCocktail:(id)sender {
    self.m_selectedCateogry = 2;
    [self goToCustomItemList];
}
- (IBAction)onSelectSpecial:(id)sender {
    self.m_selectedCateogry = 4;
    [self goToCustomItemList];
}
- (IBAction)onSelectNonAlchol:(id)sender {
    self.m_selectedCateogry = 5;
    [self goToCustomItemList];
}
- (void) goToCustomItemList
{
    CustomItemListController * controller = (CustomItemListController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomItemListController"];
    controller.m_selected_business = self.m_selected_business;
    controller.m_selectedCateogry = self.m_selectedCateogry;
    controller.m_selectedSubCategory = self.m_selectedSubCategory;
    controller.isOpened = self.isOpened;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
