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
    [self setupAdminResetPanner];
    // Do any additional setup after loading the view from its nib.
}

- (void) setupAdminResetPanner {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(reset)];
    [panRecognizer setMinimumNumberOfTouches:3];
    [panRecognizer setMaximumNumberOfTouches:3];
    [panRecognizer setDelaysTouchesBegan:YES];
    [[self view] addGestureRecognizer:panRecognizer];
}

- (void) reset {
    //TODO:Throw up a RESET SCREEN
    NSLog(@"Reset Attempted");
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
    CLLocationDistance distance = [me distanceFromLocation:me]; //Use me normally opponent to opponent to test success
    if (distance <=250) {//distance in meters
        [self assassinationSuccessful];
    }else  {
        [self assassinationFailed: distance];
    }
}

- (void) assassinationSuccessful {
    NSLog(@"To Do: Assassination successful");
// Post a status update to the user's feed via the Graph API, and display an alert view
// with the results or an error.

// This code uses 3 different ways of sharing using the Facebook SDK to enable a solid user experience: It is heavily influenced by the demo code in the helloFacebook example.
// The first method tries to share via the Facebook app. This allows sharing without
// the user having to authorize your app, and is available as long as the user has the
// correct Facebook app installed. This publish will result in a fast-app-switch to the
// Facebook app.
    
// The second method tries to share via Facebook's iOS6 integration, which also
// allows sharing without the user having to authorize your app, and is available as
// long as the user has linked their Facebook account with iOS6. This publish will
// result in a popup iOS6 dialog.
    
// The third method tries to share via a Graph API request. This does require the user
// to authorize your app. They must also grant your app publish permissions. This
// allows the app to publish without any user interaction.
    
//We'd prefer to have the user confirm publication so this method is a last resort and may be replaced by a window inviting the user to share in app.

// If it is available, we will first try to post using the share dialog in the Facebook app
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:nil
                                                              name:@"Target Eliminated"
                                                           caption:nil
                                                       description:@"I successfully eliminated a target in undercity assassin."
                                                           picture:nil
                                                       clientState:nil
                                                           handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                               if (error) {
                                                                   NSLog(@"Error: %@", error.description);
                                                               } else {
                                                                   NSLog(@"Success!");
                                                               }
                                                           }];

    if (!appCall) {
        // Next try to post using Facebook's iOS6 integration
        BOOL displayedNativeDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                              initialText:@"I successfully eliminated a target in undercity assassin"
                                                                                    image:nil
                                                                                      url:nil
                                                                                  handler:nil];
        
        if (!displayedNativeDialog) {
            // Lastly, fall back on a request for permissions and a direct post using the Graph API
            if ([[FBSession activeSession]isOpen]) {
                NSLog(@"Session was open");
                /*
                 * if the current session has no publish permission we need to reauthorize
                 */
                [self performPublishAction:^{
                    NSString *message = [NSString stringWithFormat:@"I successfully eliminated a target in undercity assassin"];
                    [FBRequestConnection startForPostStatusUpdate:message
                                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                    
                                                    [self showAlert:message result:result error:error];
                                                }];
                }];
            }else{
                NSLog(@"Got to here without publishing");
                [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceOnlyMe
                                                      allowLoginUI:YES
                                                 completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                         [self performPublishAction:^{
                             NSString *message = [NSString stringWithFormat:@"I successfully eliminated a target in undercity assassin"];
                             [FBRequestConnection startForPostStatusUpdate:message
                                                         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     
                                     [self showAlert:message result:result error:error];
                        }];
                     }];
                }];
            }
        }
    }
}

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // For simplicity, we will use any error message provided by the SDK,
        // but you may consider inspecting the fberrorShouldNotifyUser or
        // fberrorCategory to provide better recourse to users. See the Scrumptious
        // sample for more examples on error handling.
        if (error.fberrorUserMessage) {
            alertMsg = error.fberrorUserMessage;
        } else {
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void) assassinationFailed: (CLLocationDistance) distance{
    NSLog(@"To Do: Assassination failed as was at %f away.", distance);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        NSLog(@"Permission not found");
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                }
                                                //Ignore errors (such as if user cancels).
                                            }];
    } else {
        NSLog(@"Posting");
        action();
    }
    
}

@end
