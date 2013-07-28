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

@property (strong, nonatomic) IBOutlet MKMapView *gameMap;
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
    NSLog(@"view Did Load");
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
    NSLog(@"Setup Map Called");
    self.gameMap.delegate = self;
    self.gameMap.showsUserLocation = YES;
    self.gameMap.mapType = MKMapTypeSatellite;
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
    NSLog(@"DidUpdateUserLocation called");
    [self.geocoder reverseGeocodeLocation:self.gameMap.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        [self setupMap];
    }];
}

- (IBAction)assassinate:(id)sender {
    //TODO: Check distance and display message with results in a pop-up/modal.  Allow sharing to Facebook.
    CLLocation *me = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude: self.locationManager.location.coordinate.longitude];
    
    CLLocation *opponent = [[CLLocation alloc] initWithLatitude:self.opponent.latitude longitude:self.opponent.longitude];
    CLLocationDistance distance = [opponent distanceFromLocation:opponent]; //USe me normally opponent to opponent to test success
    if (distance <=250) {//distance in meters
        [self assassinationSuccessful];
    }else  {
        [self assassinationFailed: distance];
    }
}

- (void) assassinationSuccessful {
    NSLog(@"To Do: Assassination successful");
}

- (void) assassinationFailed: (CLLocationDistance) distance{
    NSLog(@"To Do: Assassination failed as was at %f away.", distance);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
