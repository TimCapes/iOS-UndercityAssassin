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
@interface UAGameMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *gameMap;
@property (nonatomic, strong) CLGeocoder *geocoder;

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
    self.gameMap.showsUserLocation = YES;
    self.gameMap.mapType = MKMapTypeSatellite;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
