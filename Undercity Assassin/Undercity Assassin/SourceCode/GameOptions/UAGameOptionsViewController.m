//
//  UAGameOptionsViewController.m
//  Undercity Assassin
//
//  Created by Tim Capes on 2013-07-27.
//  Copyright (c) 2013 Tim Capes. All rights reserved.
//

#import "UAGameOptionsViewController.h"

@interface UAGameOptionsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *gameOptionsView;

@end

@implementation UAGameOptionsViewController

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
    [self setGameOptionsView:nil];
    [super viewDidUnload];
}
#pragma mark TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return @"User";
    } else if (section==1){
        return @"Scores";
    } else {
        return @"Options";
    }
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    } else if (section==1){
        return 2;
    } else {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
        }
        cell.textLabel.text = @"Facebook Player Cell";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        return cell;
    } else if (indexPath.section==1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
        }
        cell.textLabel.text = @"Scoring Cells";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        return cell;
    } else { //if(indexPath.section==2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UAGamePlayerCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAGamePlayerCell"];
        }
        cell.textLabel.text = @"Options Cells";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        return cell;
    }
}
@end
