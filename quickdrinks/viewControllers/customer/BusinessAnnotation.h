//
//  BusinessAnnotation.h
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BusinessAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString * title;
@property (atomic) int index;
@property (atomic) int opened;

- (id) initWithTitle:(NSString*)newtitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *) annotationView;
@end

@interface BusinessActiveAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString * title;
@property (atomic) int index;
@property (atomic) int opened;

- (id) initWithTitle:(NSString*)newtitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *) annotationView;
@end
