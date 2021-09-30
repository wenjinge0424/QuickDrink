//
//  SPGooglePlacesAutocompleteViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol SPGooglePlacesAutocompleteViewControllerDelegate
- (void)SPGooglePlacesCompleateWith:(NSString*) resultString :(CLLocationCoordinate2D) position;
@end

@class SPGooglePlacesAutocompleteQuery;

@interface SPGooglePlacesAutocompleteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    NSMutableArray * m_customSearch;
    
    BOOL shouldBeginEditing;
}
@property (retain, nonatomic) id<SPGooglePlacesAutocompleteViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) NSMutableArray * customItems;

@end
