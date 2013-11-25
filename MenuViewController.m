//
//  MenuViewController.m
//  SoftServe Discount
//
//  Created by agavrish on 21.10.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "MenuViewController.h"
#import "CustomViewMaker.h"
#import "KxIntroViewController.h"

@interface MenuViewController()

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void) viewDidLoad
{
    [CustomViewMaker customNavigationBarForView:self];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:255.0/255.0 green:196.0/255.0 blue:18.0/255.0 alpha:1.0]];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBG.png"] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBGOld.png"] forBarMetrics:UIBarMetricsDefault];
}

-(void) viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];  
    if([[userDefaults objectForKey:@"firstLaunch"]boolValue])
    {
        [KxIntroViewController performIntro:self];
        [userDefaults removeObjectForKey:@"firstLaunch"];
        [userDefaults synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
