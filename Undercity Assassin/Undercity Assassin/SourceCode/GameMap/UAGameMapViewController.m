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
@interface UAGameMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *gameMap;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
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
    //CLLocationCoordinate2D opponentCoordinate = CLLocationCoordinate2DMake(0,0);
    region.center = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    NSLog(@"GOT HERE");
    MKCoordinateSpan span;
    span.latitudeDelta  =0.005; // Change these values to change the zoom
    span.longitudeDelta =0.015;
    region.span = span;
    [self.gameMap setRegion:region animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
