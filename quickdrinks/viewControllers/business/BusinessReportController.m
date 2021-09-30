//
//  BusinessReportController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessReportController.h"
#import "CustomComboBox.h"
#import "BusinessReportDetailController.h"
#import "CommonAPI.h"
#import "Util.h"
#import "DBCong.h"

@interface BusinessReportController ()<CustomComboBox_SelectedItem>
{
    NSString * st_stDate;
    NSString * st_edDate;
    NSString * st_reportType;
    
    int sortType;
}

@property (strong, nonatomic) IBOutlet CustomComboBox *combo_from;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_to;
@property (strong, nonatomic) IBOutlet CustomComboBox *combo_reportType;
@end

@implementation BusinessReportController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    st_reportType = @"";
    self.combo_reportType.lbl_title.text = @"";
    self.combo_reportType.m_comboTitle = @"Report Type";
    self.combo_reportType.m_containDatas = [[NSMutableArray alloc] initWithObjects:@"Sales: By Staff", @"Sales: Hourly", @"Sales: Drink", @"Clientele Profile", @"Tips",nil];
    self.combo_reportType.delegate = self;
    
    self.combo_to.type = 1;
    self.combo_to.delegate = self;
    self.combo_from.type = 1;
    self.combo_from.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.combo_from.lbl_title.text = @"";
    self.combo_to.lbl_title.text = @"";
    self.combo_reportType.lbl_title.text = @"";
    st_stDate = @"";
    st_edDate = @"";
    st_reportType = @"";
}
#pragma mark - Navigation
-(NSDate *)beginningOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
    
}

-(NSDate *)endOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
    
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showReportDetail"]){
        BusinessReportDetailController * controller = segue.destinationViewController;
        controller.m_title = st_reportType;
        controller.m_subTitle = [NSString stringWithFormat:@"%@-%@", st_stDate, st_edDate];
        controller.sortType = sortType;
        controller.stDate = [self beginningOfDay:[CommonAPI convertStringToDate:st_stDate]];
        controller.edDate = [self endOfDay:[CommonAPI convertStringToDate:st_edDate]];
    }
}
- (int) getIndexFromStringArrayforString:(NSString*)str
{
    NSMutableArray *  array = self.combo_reportType.m_containDatas;
    for(NSString * subString in array){
        if([subString isEqualToString:str]){
            return (int)[array indexOfObject:subString];
        }
    }
    return  -1;
}
- (BOOL) dateIsInToday:(NSDate*)date
{
    return [[NSCalendar currentCalendar] isDateInToday:date];
}
- (void) CustomComboBox_SelectedItem:(NSString *)item atCombo:(UIView *)combo
{
    if(combo == self.combo_reportType){
        sortType = [self getIndexFromStringArrayforString:item];
        st_reportType = item;
        
    }else if(combo == self.combo_from){
        st_stDate = item;
        NSDate * inputDate = [CommonAPI convertStringToDate:st_stDate];
        NSDate *date = inputDate;
        DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
//        NSDate *createdDate = defaultUser.row_createdTime;
       
        if([date timeIntervalSinceNow] > 0 && ![self dateIsInToday:date]){
            [self.combo_from.lbl_title setText:@""];
            st_stDate = @"";
            [Util showAlertTitle:self title:@"Report" message:@"You can't select future date." finish:^(void){}];
        }else if([date compare:[Util dateStartOfDay:defaultUser.row_createdTime]] ==  NSOrderedAscending){
            [self.combo_from.lbl_title setText:@""];
            st_stDate = @"";
            [Util showAlertTitle:self title:@"Report" message:@"You can't select date before you registered." finish:^(void){}];
        }
    }else if(combo == self.combo_to){
        st_edDate = item;
        NSDate * date = [CommonAPI convertStringToDate:st_edDate];
        if([date timeIntervalSinceNow] > 0  && ![self dateIsInToday:date]){
            [self.combo_to.lbl_title setText:@""];
            st_edDate = @"";
            
            [Util showAlertTitle:self title:@"Report" message:@"You can't select future date." finish:^(void){}];
        }
        if(st_stDate.length == 0 || [date timeIntervalSinceNow] < [[CommonAPI convertStringToDate:st_stDate] timeIntervalSinceNow]){
            [self.combo_to.lbl_title setText:@""];
            st_edDate = @"";
            
            [Util showAlertTitle:self title:@"Report" message:@"Please select valid dates." finish:^(void){}];
        }
    }
}
- (IBAction)onreport:(id)sender {
    if(st_stDate.length == 0){
        [Util showAlertTitle:self title:@"Report" message:@"Please select From date." finish:^(void){}];
        return;
    }
    if(st_edDate.length == 0){
        [Util showAlertTitle:self title:@"Report" message:@"Please select To date." finish:^(void){}];
        return;
    }
    if(st_reportType.length == 0){
        [Util showAlertTitle:self title:@"Report" message:@"Please select report type." finish:^(void){}];
        return;
    }
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    [self performSegueWithIdentifier:@"showReportDetail" sender:self];
}
@end
