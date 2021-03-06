//
//  UAAppDelegate.h
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import <FacebookSDK/FacebookSDK.h>
@interface UAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) FBSession *session;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (UINavigationController *) makeNavigationControllerWithViewController: (UIViewController *) viewController;

@end
