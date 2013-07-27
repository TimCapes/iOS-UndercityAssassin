//
//  UAGameMapViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UAGameMapViewController.h"
#import <MapKit/MapKit.h>
#import "UAAppDelegate.h"
#import "IIViewDeckController.h"
#import "UATarget.h"

@interface UAGameMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *gameMap;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property CLLocationCoordinate2D opponent;

@end

@implementation UAGameMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)openMenu:(id)sender {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    IIViewDeckController *deckView = (IIViewDeckController *)  appDelegate.window.rootViewController;
    if (!deckView.isAnySideOpen) {
        [deckView openLeftViewAnimated:YES];
    }
    else {
        [deckView closeLeftViewAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //TEMPORARY CODE FOR DEMO: SAMPLE OPPONENT AT BNOTIONS
    self.opponent = CLLocationCoordinate2DMake(43.649897,-79.370374);
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    [self setupMap];
    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view from its nib.
}

- (void) setupMap {
    
    self.gameMap.delegate = self;
    self.gameMap.showsUserLocation = YES;
    
    MKCoordinateRegion region;
    region.center = self.opponent;

    MKCoordinateSpan span;
    span.latitudeDelta  =ABS(self.opponent.latitude - self.locationManager.location.coordinate.latitude)*2; // ENSURE INITIAL MAP HAS USER AND TARGET VISIBLE!
    span.longitudeDelta =ABS(self.opponent.longitude - self.locationManager.location.coordinate.longitude)*2; //ENSURE INITIAL MAP HAS USER AND TARGET VISIBLE!
    region.span = span;
    
    [self.gameMap setRegion:region animated:YES];
    
    UATarget *target= [[UATarget alloc] init];
    target.coordinate = self.opponent;
    target.title=@"Your Target";
    //target.subtitle = @"Assassinate this person";
    [self.gameMap addAnnotation:target];
    [self.gameMap selectAnnotation:target animated:NO];

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.geocoder reverseGeocodeLocation:self.gameMap.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        //self.placemark = [placemarks objectAtIndex:0];
        //Rezooming Code??
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
