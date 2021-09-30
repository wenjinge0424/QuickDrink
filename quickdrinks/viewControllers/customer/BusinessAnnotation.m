//
//  BusinessAnnotation.m
//  quickdrinks
//
//  Created by mojado on 6/23/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "BusinessAnnotation.h"

@implementation BusinessAnnotation
-(id) initWithTitle:(NSString *)newtitle Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    if(self){
        _title = newtitle;
        _coordinate = location;
    }
    return self;
}
- (UIImage*) resizeImage:(UIImage*)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(newImage);
    return [UIImage imageWithData:data];
}


- (MKAnnotationView*) annotationView
{
    MKAnnotationView * annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"BusinessAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [self resizeImage:[UIImage imageNamed:@"ico_map_pin"] size:CGSizeMake(40, 40)];//[UIImage imageNamed:@"ico_map_pin"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}
@end

@implementation BusinessActiveAnnotation
-(id) initWithTitle:(NSString *)newtitle Location:(CLLocationCoordinate2D)location
{
    self = [super init];
    if(self){
        _title = newtitle;
        _coordinate = location;
    }
    return self;
}
- (UIImage*) resizeImage:(UIImage*)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(newImage);
    return [UIImage imageWithData:data];
}


- (MKAnnotationView*) annotationView
{
    MKAnnotationView * annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"BusinessActiveAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [self resizeImage:[UIImage imageNamed:@"ico_green_map"] size:CGSizeMake(60, 60)];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    UIView * subView = [[UIView alloc] initWithFrame:CGRectMake(-40, 60, 140, 30)];
    [subView setBackgroundColor:[UIColor lightGrayColor]];
    subView.layer.cornerRadius = 10.f;
    subView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    subView.layer.borderWidth = 1.f;
    [annotationView addSubview:subView];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 20)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:14.f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:_title];
    [subView addSubview:label];
    return annotationView;
}
@end
