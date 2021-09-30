//
//  BusinessAddDrinkController.m
//  quickdrinks
//
//  Created by qw on 6/6/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessAddDrinkController.h"
#import "KPDropMenu.h"
#import "CustomComboBox.h"

@interface BusinessAddDrinkController () <CustomComboBox_SelectedItem>
{
}
@property (weak, nonatomic) IBOutlet CustomComboBox *m_comboContainer;

@end

@implementation BusinessAddDrinkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.m_comboContainer.lbl_title.text = @"Drink Category";
    self.m_comboContainer.m_containDatas = [[NSMutableArray alloc] initWithObjects:@"Beer", @"Cocktail",@"Wine", @"Speciality Drinks", @"Non-Alcoholic Drinks",nil];
    self.m_comboContainer.delegate = self;
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
- (int) getIndexFromStringArrayforString:(NSString*)str
{
    NSMutableArray *  array = self.m_comboContainer.m_containDatas;
    for(NSString * subString in array){
        if([subString isEqualToString:str]){
            return (int)[array indexOfObject:subString];
        }
    }
    return  -1;
}
- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    int selectedIndex = [self getIndexFromStringArrayforString:item];
    if(selectedIndex == 0){
        [self performSegueWithIdentifier:@"businessAddDrink1" sender:self];
    }else if(selectedIndex == 1){
        [self performSegueWithIdentifier:@"businessAddDrink2" sender:self];
    }else if(selectedIndex == 2){
        [self performSegueWithIdentifier:@"businessAddDrink5" sender:self];
    }else if(selectedIndex == 3){
        [self performSegueWithIdentifier:@"businessAddDrink3" sender:self];
    }else if(selectedIndex == 4){
        [self performSegueWithIdentifier:@"businessAddDrink4" sender:self];
    }
}

@end
