//
//  UATarget.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UATarget.h"

@implementation UATarget


- (NSString *)title {
    return _title;
} 

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    id myAnnotation = [mapView.annotations objectAtIndex:0];
    [mapView selectAnnotation:myAnnotation animated:YES];
}

@end
