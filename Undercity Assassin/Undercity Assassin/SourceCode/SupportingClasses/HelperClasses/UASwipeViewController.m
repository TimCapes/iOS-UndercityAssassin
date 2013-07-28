//
//  UASwipeViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UASwipeViewController.h"

@interface UASwipeViewController (){
    int pageNumber;

}

@end

@implementation UASwipeViewController

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

- (id)initWithPageNumber:(NSUInteger)page
{
    if (self = [super initWithNibName:@"UASwipeViewController" bundle:nil])
    {
        pageNumber = page;
    }
    if (page==0) {
        [self.view sendSubviewToBack:self.button];
        [self.view sendSubviewToBack:self.explainerText];
    } else if(page==1) {
        [self.view sendSubviewToBack:self.scrollText];
    }
    return self;
}

- (void)viewDidUnload {
    [self setExplainerText:nil];
    [self setScrollText:nil];
    [super viewDidUnload];
}
@end
