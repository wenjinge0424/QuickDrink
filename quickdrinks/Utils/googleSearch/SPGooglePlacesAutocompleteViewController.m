//
//  SPGooglePlacesAutocompleteViewController.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteViewController.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "DBCong.h"

@interface SPGooglePlacesAutocompleteViewController ()

@end

@implementation SPGooglePlacesAutocompleteViewController
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
        searchQuery.radius = 100.0;
        shouldBeginEditing = YES;
        
        
    }
    return self;
}

- (void)viewDidLoad {
    self.searchDisplayController.searchBar.placeholder = @"";
    m_customSearch = [NSMutableArray new];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    [selectedPlaceAnnotation release];
    [mapView release];
    [searchQuery release];
    [super dealloc];
}

- (IBAction)recenterMapToUserLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = self.mapView.userLocation.coordinate;
    
    [self.mapView setRegion:region animated:YES];
}



- (NSMutableArray *) customSeach
{
    NSString * searchStr = [self.searchDisplayController.searchBar text];
    if(self.customItems && self.customItems.count > 0){
        m_customSearch = [NSMutableArray new];
        for(DBUsers * item in self.customItems){
            if([item.row_userName rangeOfString:searchStr options:NSCaseInsensitiveSearch].location != NSNotFound){
                [m_customSearch addObject:item];
                
            }
        }
        return m_customSearch;
    }
    return [NSMutableArray new];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count] + [m_customSearch count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [searchResultPlaces objectAtIndex:indexPath.row - [m_customSearch count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    if(indexPath.row < [m_customSearch count]){
        DBUsers * item = [m_customSearch objectAtIndex:indexPath.row];
        cell.textLabel.text = item.row_userName;
    }else{
        cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
        cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    [selectedPlaceAnnotation release];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:NO];
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [m_customSearch count]){
        DBUsers * item = [m_customSearch objectAtIndex:indexPath.row];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate SPGooglePlacesCompleateWith:item.row_userName :CLLocationCoordinate2DMake(item.row_position_lat, item.row_position_lng)];
        }];
    }else{
        SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
        [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            if (error) {
//                SPPresentAlertViewWithErrorAndTitle(error, @"Could not map selected Place");
            } else if (placemark) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self.delegate SPGooglePlacesCompleateWith:addressString :placemark.location.coordinate];
                }];
            }
        }];
    }
    
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    searchQuery.location = self.mapView.userLocation.coordinate;
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
//            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
            [self customSeach];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [searchResultPlaces release];
            searchResultPlaces = [places retain];
            [self customSeach];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:NO];
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:NO];
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:NO];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.showsCancelButton = YES;
}

#pragma mark -
#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"SPGooglePlacesAutocompleteAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton addTarget:self action:@selector(annotationDetailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = detailButton;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // Whenever we've dropped a pin on the map, immediately select it to present its callout bubble.
    [self.mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
}

- (void)annotationDetailButtonPressed:(id)sender {
    // Detail view controller application logic here.
}

@end
