//
//  DeliveryViewController.m
//  quickdrinks
//
//  Created by developer on 3/18/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "DeliveryViewController.h"
#import "Util.h"
#import "DBCong.h"

@interface DeliveryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *edt_section1_name;
@property (weak, nonatomic) IBOutlet UITextField *edt_section1_option;
@property (weak, nonatomic) IBOutlet UITextField *edt_section2_name;
@property (weak, nonatomic) IBOutlet UITextField *edt_section2_option;
@property (weak, nonatomic) IBOutlet UITextField *edt_section3_name;
@property (weak, nonatomic) IBOutlet UITextField *edt_section3_option;

@end

@implementation DeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:@"Delivery"];
    [query whereKey:@"user_id" equalTo:defaultUser.row_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if(!error){
            if(objects.count > 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    PFObject * object = [objects firstObject];
                    self.edt_section1_name.text = object[@"section1_name"];
                    self.edt_section1_option.text = object[@"section1_option"];
                    self.edt_section2_name.text = object[@"section2_name"];
                    self.edt_section2_option.text = object[@"section2_option"];
                    self.edt_section3_name.text = object[@"section3_name"];
                    self.edt_section3_option.text = object[@"section3_option"];
                    
                });
            }
        }else{
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    }];
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
- (IBAction)onDone:(id)sender {
    if(self.edt_section1_name.text.length > 0){
        if(self.edt_section1_option.text.length == 0){
            [Util showAlertTitle:self title:@"Delivery Location" message:@"Please input Section Options" finish:^{
                [self.edt_section1_option becomeFirstResponder];
            }];
            return;
        }
    }
    if(self.edt_section2_name.text.length > 0){
        if(self.edt_section2_option.text.length == 0){
            [Util showAlertTitle:self title:@"Delivery Location" message:@"Please input Subsection Options" finish:^{
                [self.edt_section2_option becomeFirstResponder];
            }];
            return;
        }
    }
    if(self.edt_section3_name.text.length > 0){
        if(self.edt_section3_option.text.length == 0){
            [Util showAlertTitle:self title:@"Delivery Location" message:@"Please input Subsection Options" finish:^{
                [self.edt_section3_option becomeFirstResponder];
            }];
            return;
        }
    }
    if(self.edt_section1_name.text.length == 0){
        [Util showAlertTitle:self title:@"Delivery Location" message:@"Please input Section Name" finish:^{
            [self.edt_section1_name becomeFirstResponder];
        }];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    DBUsers * defaultUser = [[StackMemory createInstance] stack_signInItem];
    PFQuery *query = [PFQuery queryWithClassName:@"Delivery"];
    [query whereKey:@"user_id" equalTo:defaultUser.row_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            for (PFObject * object in objects) {
                [object deleteInBackground];
            }
            PFObject *obj = [PFObject objectWithClassName:@"Delivery"];
            obj[@"user_id"] = defaultUser.row_id;
            obj[@"section1_name"] = [Util trim:self.edt_section1_name.text];
            obj[@"section1_option"] = [Util trim:self.edt_section1_option.text];
            obj[@"section2_name"] = [Util trim:self.edt_section2_name.text];
            obj[@"section2_option"] = [Util trim:self.edt_section2_option.text];
            obj[@"section2_name"] = [Util trim:self.edt_section2_name.text];
            obj[@"section2_option"] = [Util trim:self.edt_section2_option.text];
            [obj saveInBackground];
            
            [SVProgressHUD dismiss];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else{
            [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection." finish:^{
                [SVProgressHUD dismiss];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
        
    }];
}

@end
