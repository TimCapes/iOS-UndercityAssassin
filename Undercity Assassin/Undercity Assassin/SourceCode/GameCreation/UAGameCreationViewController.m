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
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    //TODO: WebAPI pulling data on invites from cloud and sending invites to cloud to track table of friends and whether they have joined the game.
    self.selectedFriendsView.text = text;
    
    [self dismissModalViewControllerAnimated:YES];
}


@end
