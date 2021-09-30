//
//  CustomerHomeController.m
//  quickdrinks
//
//  Created by mojado on 6/15/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "CustomerHomeController.h"
#import <MapKit/MapKit.h>
#import "DBCong.h"
#import "BusinessAnnotation.h"
#import "CustomItemListController.h"
#import "AppDelegate.h"
#import "MVPlaceSearchTextField.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SPGooglePlacesAutocompleteViewController.h"
#import "CommonAPI.h"
#import "CustomSelectCategoryViewController.h"

@interface CustomerHomeController () <UITextFieldDelegate, MKMapViewDelegate, SPGooglePlacesAutocompleteViewControllerDelegate>
{
    NSMutableArray * m_customerArray;
    NSMutableArray * openedArray;
    NSMutableArray * m_tmpcustomerArray;
    
    DBUsers * m_selectedUser;
    int m_selectedCategory;
    int m_selectedSubCategory;
    
    BOOL showPlaceSearch;
    BOOL isSettedrRegion;
    
    NSDate * m_checkDate;
}
@property (strong, nonatomic) IBOutlet UITextField *edt_searchBar;
@property (strong, nonatomic) IBOutlet MKMapView *m_mapView;


@property (weak, nonatomic) IBOutlet UIView *view_cartAlert;
@property (weak, nonatomic) IBOutlet UILabel *lbl_cartCount;
@end

@implementation CustomerHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_mapView.showsUserLocation = YES;
    showPlaceSearch = NO;
    
    isSettedrRegion = NO;
    
    m_checkDate = [NSDate date];
    [self refreshMapView];
    [self performSelector:@selector(checkUpadate) withObject:nil afterDelay:5];
    [self performSelector:@selector(onGotoUserPosition:) withObject:nil afterDelay:1];
}
- (int) getOpendStateFromUserId:(NSString*)userId
{
    for(NSDictionary * item in openedArray){
        if([item[@"user_id"] isEqualToString:userId]){
            return [item[@"online_order"] intValue];
        }
    }
    return 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray * m_cartArray = [StackMemory  getCartItems];
    self.view_cartAlert.layer.cornerRadius = self.view_cartAlert.frame.size.width / 2;
    if(m_cartArray && m_cartArray.count > 0){
        [self.view_cartAlert setHidden:NO];
        [self.lbl_cartCount setText:[NSString stringWithFormat:@"%d", (int)m_cartArray.count]];
    }else{
        [self.view_cartAlert setHidden:YES];
        [self.lbl_cartCount setText:@""];
    }
    
    [self.edt_searchBar setText:@""];
}

- (void) checkUpadate
{
    [DBUsers getAllBusinessArrayUpdateFrom:m_checkDate :^(id returnItem, NSError * error){
        if(returnItem && [returnItem count] > 0){
            [self refreshMapView];
        }else{
            PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
            [query orderByAscending:@"user_id"];
            [query whereKey:@"updatedAt" greaterThan:m_checkDate];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(error){
                    [self refreshMapView];
                }else{
                    if(objects && objects.count > 0){
                        [self refreshMapView];
                    }
                }
            }];
        }
        
   }failBlock:^(NSError * error){
        [self refreshMapView];
    }];
    
    
    [self performSelector:@selector(checkUpadate) withObject:nil afterDelay:5];
}
- (void) refreshMapView
{
    
    if(showPlaceSearch){
        showPlaceSearch = NO;
        return;
    }
    if(!openedArray)
        openedArray = [NSMutableArray new];
    
    [_edt_searchBar setText:@""];
    
    if(!isSettedrRegion)
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [DBUsers getAllBusinessArray:^(id returnItem, NSError * error){
        
        if(!m_customerArray)
            m_customerArray = [NSMutableArray new];
        if(!m_tmpcustomerArray)
            m_tmpcustomerArray = [NSMutableArray new];
        PFQuery * query = [PFQuery queryWithClassName:@"Setting_online_order"];
        [query whereKey:@"online_order" equalTo:[NSNumber numberWithInt:1]];
        [query orderByAscending:@"user_id"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [SVProgressHUD dismiss];
            [self.m_mapView  removeAnnotations:self.m_mapView.annotations];
            if(!error){
                openedArray = [[NSMutableArray alloc] initWithArray:objects];
                m_customerArray = [NSMutableArray new];
                m_tmpcustomerArray = [[NSMutableArray alloc] initWithArray:returnItem];
                NSMutableArray * annotationArray = [NSMutableArray new];
                for(DBUsers * item in returnItem){
                    if(item.row_position_lat !=0 || item.row_position_lng !=0){
                        [m_customerArray addObject:item];
                        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(item.row_position_lat, item.row_position_lng);
                        if([self getOpendStateFromUserId:item.row_id] == 0){
                            BusinessAnnotation * annotation = [[BusinessAnnotation alloc] initWithTitle:item.row_userName Location:position];
                            annotation.index = [m_customerArray indexOfObject:item];
                            annotation.opened = 0;
                            [annotationArray addObject:annotation];
                        }else{
                            BusinessActiveAnnotation * annotation = [[BusinessActiveAnnotation alloc] initWithTitle:item.row_userName Location:position];
                            annotation.index = [m_customerArray indexOfObject:item];
                            annotation.opened = 1;
                            [annotationArray addObject:annotation];
                        }
                        
                    }
                }
                
                CLLocation * currentLocation = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentLocation];
                
                
                [self.m_mapView addAnnotations:annotationArray];
                
                m_checkDate = [NSDate date];
                
                if(!isSettedrRegion){
                    
                    MKCoordinateRegion region;
                    region.center = currentLocation.coordinate;//CLLocationCoordinate2DMake(min_lat + (max_lat - min_lat)/2 , min_lng + (max_lng - min_lng)/2 );
                    region.span.latitudeDelta = 0.06;
                    region.span.longitudeDelta = 0.06;
                    [self.m_mapView setRegion:region];
                    
                    isSettedrRegion = YES;
                }else{
                }
                
            }
        }];
        
        
    } failBlock:^(NSError * error){
        [SVProgressHUD dismiss];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    
    //Optional Properties
}
/*
#pragma mark - Place search Textfield Delegates

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
    NSLog(@"SELECTED ADDRESS :%@",responseDict);
    
    CLLocationCoordinate2D coodinate = responseDict.coordinate;
    MKCoordinateRegion region = self.m_mapView.region;
    region.center = coodinate;
    [self.m_mapView setRegion:region animated:YES];
}
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index{
    if(index%2==0){
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}
/*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void) gotoBusinessHome:(NSString*)ownerId :(int) categoryId :(int)subCategory
{
    for(DBUsers * item in m_customerArray){
        if([item.row_id isEqualToString:ownerId]){
            m_selectedUser = item;
            m_selectedCategory = categoryId;
            m_selectedSubCategory = subCategory;
            [self goToCustomItemList];
            return;
        }
    }
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showHomeDetail"]){
        CustomItemListController * controller = (CustomItemListController*)[segue destinationViewController];
        controller.m_selected_business = m_selectedUser;
        controller.m_selectedCateogry = m_selectedCategory;
        controller.m_selectedSubCategory = m_selectedSubCategory;
        controller.isOpened = [self getOpendStateFromUserId:m_selectedUser.row_id];
    }
}
- (IBAction)onGotoUserPosition:(id)sender {
    if([CLLocationManager locationServicesEnabled]){
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"App Permission Denied" message:@"Please go to settings and turn on location service for this app." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [alert dismissViewControllerAnimated:YES completion:^(){
                }];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            CLLocation * currentLocation = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentLocation];
            MKCoordinateRegion region = self.m_mapView.region;
            region.center = currentLocation.coordinate;//CLLocationCoordinate2DMake(min_lat + (max_lat - min_lat)/2 , min_lng + (max_lng - min_lng)/2 );
            [self.m_mapView setRegion:region animated:YES];
        }
    }
}

- (IBAction)onAlarm:(id)sender {
}
- (IBAction)onOrders:(id)sender {
}

- (IBAction)onText:(id)sender {
    //[self performSegueWithIdentifier:@"showHomeDetail" sender:self];
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"App Permission Denied" message:@"Please go to settings and turn on location service for this app." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){
            }];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        
        showPlaceSearch = YES;
        SPGooglePlacesAutocompleteViewController * controller = [[SPGooglePlacesAutocompleteViewController alloc] initWithNibName:@"SPGooglePlacesAutocompleteViewController" bundle:nil];
        controller.customItems = m_customerArray;
        controller.delegate = self;
        [self.navigationController presentViewController:controller animated:YES completion:^{
            [controller.searchDisplayController.searchBar becomeFirstResponder];
        }];
    }
    return NO;
}

- (void)SPGooglePlacesCompleateWith:(NSString*) resultString :(CLLocationCoordinate2D) position
{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"App Permission Denied" message:@"Please go to settings and turn on location service for this app." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [alert dismissViewControllerAnimated:YES completion:^(){
            }];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self.edt_searchBar setText:resultString];
        MKCoordinateRegion region = self.m_mapView.region;
        region.center = position;
        [self.m_mapView setRegion:region animated:YES];
        
        [self searchInMapWithAnnotations:resultString :position];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString * searchStr = textField.text;
    [self searchInMap:searchStr];
    return YES;
}


- (void)getAddressFromAdrress:(NSString *)address withCompletationHandle:(void (^)(CLLocationCoordinate2D))completationHandler {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    //Get the address through geoCoder
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [geoCoder geocodeAddressString:address   completionHandler:^(NSArray *placemarks, NSError *error) {
        [SVProgressHUD dismiss];
        if ([placemarks count] > 0 && !error) {
            //get the address from placemark
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            completationHandler(coordinate);
            
        } else {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = 0;
            coordinate.longitude = 0;
            completationHandler(coordinate);
        }
    }];
}

- (void) searchInMapWithAnnotations :(NSString *) str :(CLLocationCoordinate2D) position
{
    [self.edt_searchBar setText:str];
    MKCoordinateRegion region = self.m_mapView.region;
    region.center = position;
    [self.m_mapView setRegion:region animated:YES];
 }
- (void) searchInMap:(NSString *) str
{
   // [self searchInMapWithAnnotations:str];
    for(DBUsers * item in m_customerArray){
        if([item.row_userName containsString:str]){
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(item.row_position_lat, item.row_position_lng);
            MKCoordinateRegion region = self.m_mapView.region;
            region.center = position;
            [self.m_mapView setRegion:region animated:YES];
            return;
        }
    }
}

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
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(-100, -30, 200, 30)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor blueColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = customAnnotation.title;
        [annotationView addSubview:lbl];
        
        UITapGestureRecognizer * recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectPing:)];
        [annotationView addGestureRecognizer:recog];
        return annotationView;
    }else if([annotation isKindOfClass:[BusinessActiveAnnotation class]]){
        BusinessActiveAnnotation * customAnnotation = (BusinessActiveAnnotation*)annotation;
        MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BusinessActiveAnnotation"];
        if(!annotationView){
            annotationView = customAnnotation.annotationView;
        }else{
            annotationView.annotation = customAnnotation;
        }
        UITapGestureRecognizer * recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectPing:)];
        [annotationView addGestureRecognizer:recog];
        return annotationView;
    }
    return nil;
}
- (void)onSelectPing:(UIGestureRecognizer*)recog
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network error" message:@"Couldn't connect to the Server. Please check your network connection."];
        return;
    }
    MKAnnotationView * anView =  (MKAnnotationView*)recog.view;
    if([recog.view isKindOfClass:[BusinessAnnotation class]]){
        BusinessAnnotation * customAnnotation = anView.annotation;
        int index = customAnnotation.index;
        if(index < [m_customerArray count]){
            m_selectedUser = [m_customerArray objectAtIndex:index];
            [self gotoSelectCategoryViewController];
        }
    }else if([recog.view isKindOfClass:[BusinessActiveAnnotation class]]){
        BusinessActiveAnnotation * customAnnotation = anView.annotation;
        int index = customAnnotation.index;
        if(index < [m_customerArray count]){
            m_selectedUser = [m_customerArray objectAtIndex:index];
            [self gotoSelectCategoryViewController];
        }
    }
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (![Util isConnectableInternet]){
        return;
    }
    MKAnnotationView * anView =  (MKAnnotationView*)view;
    [mapView deselectAnnotation:view.annotation animated:NO];
    if([view.annotation isKindOfClass:[BusinessAnnotation class]]){
        BusinessAnnotation * customAnnotation = anView.annotation;
        int index = customAnnotation.index;
        if(index < [m_customerArray count]){
            m_selectedUser = [m_customerArray objectAtIndex:index];
            [self gotoSelectCategoryViewController];
        }
    }else if([view.annotation isKindOfClass:[BusinessActiveAnnotation class]]){
        BusinessActiveAnnotation * customAnnotation = anView.annotation;
        int index = customAnnotation.index;
        if(index < [m_customerArray count]){
            m_selectedUser = [m_customerArray objectAtIndex:index];
            [self gotoSelectCategoryViewController];
        }
    }
}
- (void) gotoSelectCategoryViewController
{
    CustomSelectCategoryViewController * controller = (CustomSelectCategoryViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomSelectCategoryViewController"];
    controller.m_selected_business = m_selectedUser;
    controller.m_selectedCateogry = m_selectedCategory;
    controller.m_selectedSubCategory = m_selectedSubCategory;
    controller.isOpened = [self getOpendStateFromUserId:m_selectedUser.row_id];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void) goToCustomItemList
{
    CustomSelectCategoryViewController * controller = (CustomSelectCategoryViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomSelectCategoryViewController"];
    controller.m_selected_business = m_selectedUser;
    controller.m_selectedCateogry = m_selectedCategory;
    controller.m_selectedSubCategory = m_selectedSubCategory;
    controller.isOpened = [self getOpendStateFromUserId:m_selectedUser.row_id];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
