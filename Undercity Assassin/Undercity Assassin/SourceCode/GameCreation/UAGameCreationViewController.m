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
#import "UAGamePlayer.h"
#import <FacebookSDK/FacebookSDK.h>


@interface UAGameCreationViewController ()<FBFriendPickerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *demoButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UITableView *playerTable;
@property (weak, nonatomic) IBOutlet UILabel *selectedFriendsView;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundTableCover;
@property (retain, nonatomic) NSMutableArray *invited;
@property (retain, nonatomic) NSMutableArray *accepted;

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
    self.accepted = [NSMutableArray arrayWithObjects:nil];
    self.invited= [NSMutableArray arrayWithObjects:nil];

}

- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self loadAccepted];
    [self loadInvited];

}

- (void) loadInvited {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    NSEntityDescription *testEntity=[NSEntityDescription entityForName:@"UAGamePlayer" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetch setEntity:testEntity];
    //NSPredicate *pred=[NSPredicate predicateWithFormat:@"hasAccepted==%s", NO];
    //[fetch setPredicate:[NSArray arrayWithObject:pred]];
    //NSLog(@"ready to fetch");
    NSError *fetchError=nil;
    NSArray *fetchedObjs=[appDelegate.managedObjectContext executeFetchRequest:fetch error:&fetchError];
    if (fetchError!=nil) {
        NSLog(@" fetchError=%@,details=%@",fetchError,fetchError.userInfo);
        self.invited = [NSMutableArray arrayWithObjects:nil];
    } else {
        NSLog(@"Got insite loop");
        self.invited = [NSMutableArray arrayWithObjects:nil];
        for (int i=0;i < [fetchedObjs count]; i++) {
            [self.invited addObject:[(UAGamePlayer *)[fetchedObjs objectAtIndex:i] name]];
        }
    }
}

- (void) loadAccepted {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    NSEntityDescription *testEntity=[NSEntityDescription entityForName:@"UAGamePlayer" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetch setEntity:testEntity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    //NSPredicate *pred=[NSPredicate predicateWithFormat:@"hasAccepted==%s",YES];
    //NSLog(@"predicate parsed");
    //[fetch setPredicate:[NSArray arrayWithObject:pred]];
    //NSLog(@"predicate set");
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:fetch error:&error] mutableCopy];
    //NSArray *fetchedObjs=[appDelegate.managedObjectContext executeFetchRequest:fetch error:&fetchError];
    if (error!=nil) {
        NSLog(@" error=%@,details=%@",error,error.userInfo);
        self.accepted = [NSMutableArray arrayWithObjects:nil];
    } else {
        self.accepted = [NSMutableArray arrayWithObjects:nil];
        for (int i=0;i < [mutableFetchResults count]; i++) {
            [self.invited addObject:[(UAGamePlayer *)[mutableFetchResults objectAtIndex:i] name]];
        }
    }
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
                  [self savePickedUsers];
                  //TODO: Add users to invite list.
              }
          }
    }];
}
- (void) savePickedUsers {
    NSLog(@"Saving pickedUsers");
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        UAGamePlayer *invitedUser = [NSEntityDescription insertNewObjectForEntityForName:@"UAGamePlayer"
                                                  inManagedObjectContext:appDelegate.managedObjectContext];
        invitedUser.hasAccepted = [NSNumber numberWithBool:NO];
        invitedUser.name = user.name;
        NSError *saveError=nil;
        [appDelegate.managedObjectContext save:&saveError];
        if (saveError!=nil) {
            NSLog(@"[%@ saveContext] Error saving context: Error=%@,details=%@",[self class], saveError,saveError.userInfo);
        }
        NSLog(@"Saved user");
    }
    [self loadInvited];
    [self.playerTable reloadData];
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

#pragma mark TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return @"Accepted";
    } else {
        return @"Invited";
    }
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return [self.accepted count]+1;
    } else {
        return [self.invited count]+1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        if (indexPath.row < [self.accepted count]) {
           UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
            }
            cell.textLabel.text = [self.accepted objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"There are %d confirmed players (including you)", [self.accepted count]+1];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            return cell;

        }
    } else { //if (indexPath.section==1) {
        if (indexPath.row < [self.invited count]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
            }
            cell.textLabel.text = [self.invited objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
            }
            cell.textLabel.text = [NSString stringWithFormat:@"You are waiting on %d invited players", [self.invited count]];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            return cell;
        }
    }
}

@end
