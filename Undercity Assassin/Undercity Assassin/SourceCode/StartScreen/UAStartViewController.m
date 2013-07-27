//
//  UAStartViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UAStartViewController.h"
#import "UAGameMapViewController.h"
#import "UAGameOptionsViewController.h"
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
    [self signedIn];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    NSLog(@"In session state changed");
    
    switch (state) {
        case FBSessionStateOpen: {

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
    NSLog(@"Adding session");
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         NSLog(@"Inside completion handler");
         [self sessionStateChanged:session state:state error:error];
     }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate  {
    
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

//This code will eventually be pushed back. A fully interactive start-menu is needed post FB sign-in.
- (IBAction) signedIn {
    UAAppDelegate *appDelegate = (UAAppDelegate *)[[UIApplication sharedApplication] delegate];

    UAGameMapViewController *mapView = [[UAGameMapViewController alloc] initWithNibName:@"UAGameMapViewController" bundle: [NSBundle mainBundle]];
    
    appDelegate.navigationController = [appDelegate makeNavigationControllerWithViewController:mapView];
    appDelegate.navigationController.navigationBarHidden = YES;
    
    UAGameOptionsViewController *gameOptions = [[UAGameOptionsViewController alloc] initWithNibName:@"UAGameOptionsViewController" bundle:[NSBundle mainBundle]];
    
    IIViewDeckController *deckViewController = (IIViewDeckController *) appDelegate.window.rootViewController;
    deckViewController.leftController = gameOptions;
    deckViewController.centerController = appDelegate.navigationController;
}
@end
