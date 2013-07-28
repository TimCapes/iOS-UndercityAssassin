//
//  UAGameCreationViewController.h
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UAGameCreationViewController : UIViewController
- (void) performPublishAction:(void (^)(void)) action ;
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error;
@end
