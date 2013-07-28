//
//  UAGameCreationViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UAGameCreationViewController.h"
#import "UAGameMapViewController.h"
#import "UAGameOptionsViewController.h"
#import "IIViewDeckController.h"
#import "UAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface UAGameCreationViewController ()<FBFriendPickerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *demoButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UITableView *playerTable;
@property (weak, nonatomic) IBOutlet UILabel *selectedFriendsView;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundTableCover;

@end

@implementation UAGameCreationViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    self.backgroundTableCover.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDemoButton:nil];
    [self setInviteButton:nil];
    [self setPlayerTable:nil];
    [self setSelectedFriendsView:nil];
    [self setBackgroundTableCover:nil];
    [super viewDidUnload];
}
- (IBAction)demo {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UAGameMapViewController *mapView = [[UAGameMapViewController alloc] initWithNibName:@"UAGameMapViewController" bundle: [NSBundle mainBundle]];
    
    appDelegate.navigationController = [appDelegate makeNavigationControllerWithViewController:mapView];
    appDelegate.navigationController.navigationBarHidden = YES;
    
    UAGameOptionsViewController *gameOptions = [[UAGameOptionsViewController alloc] initWithNibName:@"UAGameOptionsViewController" bundle:[NSBundle mainBundle]];
    
    IIViewDeckController *deckViewController = (IIViewDeckController *) appDelegate.window.rootViewController;
    deckViewController.leftController = gameOptions;
    deckViewController.centerController = appDelegate.navigationController;
}

- (IBAction)pickFriendsButtonClick:(id)sender {
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        NSLog(@"ActiveSession not open");
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                              NSLog(@"Got to error alert");
                                          } else if (session.isOpen) {
                                              NSLog(@"recalled with session now open");
                                              [self pickFriendsButtonClick:sender];
                                              
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        NSLog(@"getting friend picker");
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    NSLog(@"Loading data");
    [self.friendPickerController loadData];
    NSLog(@"Clearing selection");
    [self.friendPickerController clearSelection];
    NSLog(@"Presenting Controller");
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    [self sendRequests];
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void) sendRequests {
    NSMutableString *text = [[NSMutableString alloc] init];
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.id];
    }
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     text, @"to",
                                     nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"I've invited you to come play Undercity Assassin with me"]
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
          if (error) {
              // Case A: Error launching the dialog or sending request.
              NSLog(@"Error sending request.");
          } else {
              if (result == FBWebDialogResultDialogNotCompleted) {
                  // Case B: User clicked the "x" icon
                  NSLog(@"User canceled request.");
              } else {
                  NSLog(@"Request Sent.");
                  //TODO: Add users to invite list.
              }
          }
    }];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    //TODO: WebAPI pulling data on invites from cloud and sending invites to cloud to track table of friends and whether they have joined the game. Also TODO: Post to friends inviting them to game!
    self.selectedFriendsView.text = text;
    
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)startGame:(id)sender {
    if ([self shouldStartGame]) {
        //TODO: Set an ingame flag in core data to avoid this screen and go straight to the app once loaded.
    } else {
        //TODO: Throw up a modal explaining the game is currently in demo only version and the WebAPI to play multiplayer is coming soon.
    }
}

-(BOOL) shouldStartGame {
    return  NO; // API NOT YET BUILT.
}

@end
