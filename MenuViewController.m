//
//  MenuViewController.m
//  SoftServe Discount
//
//  Created by agavrish on 21.10.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "MenuViewController.h"

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
    [self setNavigationTitle];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:255/255.0 green:196/255.0 blue:18/255.0 alpha:1]];
    if([[[UIDevice currentDevice] systemVersion] isEqualToString:@"7.0"])
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBG.png"] forBarMetrics:UIBarMetricsDefault];
    else
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarBGold.png"] forBarMetrics:UIBarMetricsDefault];

}

-(void) setNavigationTitle
{
    UILabel *navigationTitle = [[[UILabel alloc] init] autorelease];
    navigationTitle.backgroundColor = [UIColor clearColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:20.0];
    navigationTitle.textColor = [UIColor blackColor];
    self.navigationItem.titleView = navigationTitle;
    navigationTitle.text = self.navigationItem.title;
    [navigationTitle sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
