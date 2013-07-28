//
//  UAStartViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UAStartViewController.h"
#import "UAGameCreationViewController.h"
#import "IIViewDeckController.h"
#import "UAAppDelegate.h"
#import "UASwipeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
@interface UAStartViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation UAStartViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize viewControllers = _viewControllers;

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
    [self setupNumberOfPages];
    [self setupScrollView];
    UAAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                //[self updateView];
            }];
        }
    }

    // Do any additional setup after loading the view from its nib.
}

- (void) setupNumberOfPages {
    NSUInteger numberPages = 2;
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
}
- (void) setupScrollView {
    self.scrollView.pagingEnabled=YES;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, (self.view.frame.size.height-88)*2);//Don't forget to subtract size of status bar
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= 2) {
        return;
    }
    // replace the placeholder if necessary
    UASwipeViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[UASwipeViewController alloc] initWithPageNumber:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = 0;
        frame.origin.y = (CGRectGetHeight(frame)-88)*page; //Don't forget to subtract size of status bar
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        NSString *imageName;
        if (page==0) {
            imageName = @"image_city_skyline";
        }
        else if (page==1){
            imageName = @"image_facebook_background";
            [controller.button addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
        }

        controller.swipeImage.image = [UIImage imageNamed:imageName];
    }
}


- (void) loginWithFacebook {
    NSLog(@"Attempting login with facebook");
    [self openSession];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSLog(@"In session state changed");
    
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"Calling signedIn");
            [self signedIn];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    NSLog(@"Called open Session");
    UAAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        NSLog(@"Close and clear");
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        NSLog(@"No open session");
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
            NSLog(@"Created a session");
        }
        // if the session isn't open, let's open it now and present the login UX to the user
        NSLog(@"Completion handler");
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                     FBSessionState state,
                                                     NSError *error) {
            [self sessionStateChanged:session state:state error:error];
            // and here we make sure to update our UX according to the new session state
        }];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"Called Scroll View Did Scroll");
    NSLog(@"Content offset y is %f",scrollView.contentOffset.y);
    if(scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= 400.0) {
        NSLog(@"called blurring percentage");
        float percent = 1 - (scrollView.contentOffset.y / 400.0);
        NSLog(@"percentage to blur is %f",percent);
        ((UASwipeViewController *)self.viewControllers[0]).swipeImage.alpha = percent;
        ((UASwipeViewController *)self.viewControllers[0]).button.alpha = 0;
        ((UASwipeViewController *)self.viewControllers[0]).scrollText.alpha=0;
        ((UASwipeViewController *)self.viewControllers[0]).explainerText.alpha=0;
    } else if (scrollView.contentOffset.y > 400.0){
        NSLog(@"Alpha is setting to 0");
         ((UASwipeViewController *)self.viewControllers[0]).swipeImage.alpha = 0;
    } else if (scrollView.contentOffset.y <= 0) {
        NSLog(@"Alpha is setting to 1");
         ((UASwipeViewController *)self.viewControllers[0]).swipeImage.alpha = 1;
        ((UASwipeViewController *)self.viewControllers[0]).scrollText.alpha=1;
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate  {
    
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

//This code will eventually be pushed back. A fully interactive start-menu is needed post FB sign-in.
- (void) signedIn {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];

    UAGameCreationViewController *gameCreation = [[UAGameCreationViewController alloc] initWithNibName:@"UAGameCreationViewController" bundle: [NSBundle mainBundle]];
    
    appDelegate.navigationController = [appDelegate makeNavigationControllerWithViewController:gameCreation];
    appDelegate.navigationController.navigationBarHidden = YES;
    
    IIViewDeckController *deckViewController = (IIViewDeckController *) appDelegate.window.rootViewController;
    deckViewController.centerController = appDelegate.navigationController;
}
@end
