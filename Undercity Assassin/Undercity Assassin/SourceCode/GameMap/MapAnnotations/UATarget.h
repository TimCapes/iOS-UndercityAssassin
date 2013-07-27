//
//  UATarget.h
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UATarget : NSObject<MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}
@property(nonatomic, retain) NSString *title;

@end
