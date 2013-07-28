//
//  UASwipeViewController.h
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UASwipeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *swipeImage;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *explainerText;
@property (weak, nonatomic) IBOutlet UILabel *scrollText;
- (id)initWithPageNumber:(NSUInteger)page;
@end
