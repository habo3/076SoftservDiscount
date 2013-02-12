//
//  SlideMenuImplementor.m
//  SoftServeDP
//
//  Created by Bogdan on 1/14/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "SlideMenu.h"
#import <QuartzCore/QuartzCore.h> //quartz framework for animation move
#import "SettingsViewController.h"
#import "MapViewController.h"
@interface SlideMenu ()

@end

@implementation SlideMenu

//@synthesize managedObjectContextTest; //debug
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.slideMenuDataSource = self;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        // Assign self to the slideMenuDataSource because self will implement SASlideMenuDatSource
        self.slideMenuDataSource = self;
    }
    return self;
}

-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    //[menuButton setBackgroundImage:[UIImage imageNamed:@"menuhighlighted.png"] forState:UIControlStateHighlighted];
    [menuButton setAdjustsImageWhenHighlighted:NO];
    [menuButton setAdjustsImageWhenDisabled:NO];
}

-(void) configureSlideLayer:(CALayer *)layer{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.3;
    layer.shadowOffset = CGSizeMake(-15, 0);
    layer.shadowRadius = 10;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        
    if ([[segue identifier] isEqualToString: @"settings"]) {
        
        UINavigationController *navigationController = [segue destinationViewController];
        SettingsViewController *vc = (SettingsViewController *) navigationController.topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        
    }
    if ([[segue identifier] isEqualToString: @"map"]) {
        
        UINavigationController *navigationController = [segue destinationViewController];
        MapViewController *vc = (MapViewController *) navigationController.topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        
    }
}
-(void) viewDidLoad {
   // NSLog(@"test: %@", managedObjectContextTest);//debug
    [super viewDidLoad];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menuBackground.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
}

-(NSString*) initialSegueId{
    return @"settings";
}

@end
