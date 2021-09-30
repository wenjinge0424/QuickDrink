//
//  CustomerRestDetailController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerRestDetailController.h"
#import <MapKit/MapKit.h>
#import "Util.h"
#import "BusinessAnnotation.h"

@interface CustomerRestDetailController ()<UITextFieldDelegate, MKMapViewDelegate>
{
    NSMutableArray * openedArray;
}
@property (strong, nonatomic) IBOutlet UIImageView *img_restaurant;
@property (strong, nonatomic) IBOutlet MKMapView *mapkit_rest;
@property (strong, nonatomic) IBOutlet UITextField *edt_address;
@property (strong, nonatomic) IBOutlet UITextField *edt_businessHours;
@property (strong, nonatomic) IBOutlet UITextField *edt_contactNumber;
@property (strong, nonatomic) IBOutlet UITextView *edt_description;

@property (strong, nonatomic) IBOutlet UILabel *lbl_title;
@end

@implementation CustomerRestDetailController

- (int) getOpendStateFromUserId:(NSString*)userId
{
    for(NSDictionary * item in openedArray){
        if([item[@"user_id"] isEqualToString:userId]){
            return [item[@"online_order"] intValue];
        }
    }
    return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.lbl_title setText:self.m_selected_business.row_userName];
    
    // Do any additional setup after loading the view.
    [self.edt_address setText:self.m_selected_business.row_userLocation];
    [self.edt_businessHours setText:[NSString stringWithFormat:@"%@-%@", self.m_selected_business.row_business_stTime, self.m_selected_business.row_business_edTime]];
    [self.edt_contactNumber setText:self.m_selected_business.row_userContactNumber];
    [self.edt_description setText:self.m_selected_business.row_userDescription];
    [Util setImage:self.img_restaurant imgUrl:self.m_selected_business.row_userPhoto];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.m_selected_business.row_position_lat, self.m_selected_business.row_position_lng);
    BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithTitle:self.m_selected_business.row_userName Location:position];
    [self.mapkit_rest addAnnotation:annotation];
    MKCoordinateRegion region;
    region.center = position;
    region.span.latitudeDelta = 0.06;
    region.span.longitudeDelta = 0.06;
    [self.mapkit_rest setRegion:region];
    
    PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [SVProgressHUD dismiss];
        if(!error){
            openedArray = [[NSMutableArray alloc] initWithArray:objects];
            int openstatus = [self getOpendStateFromUserId:self.m_selected_business.row_id];
            if (openstatus == 0) {
                self.lbl_title.textColor = [UIColor redColor];
            } else if (openstatus == 1){
                self.lbl_title.textColor = [UIColor greenColor];
            }
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
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[BusinessAnnotation class]]){
        BusinessAnnotation * customAnnotation = (BusinessAnnotation*)annotation;
        MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BusinessAnnotation"];
        if(!annotationView){
            annotationView = customAnnotation.annotationView;
        }else{
            annotationView.annotation = customAnnotation;
        }
        return annotationView;
    }
    return nil;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
