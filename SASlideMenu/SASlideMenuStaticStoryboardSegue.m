//
//  SASlideMenuStaticStoryboardSegue.m
//  SASlideMenu
//
//  Created by Stefano Antonelli on 11/24/12.
//  Copyright (c) 2012 Stefano Antonelli. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SASlideMenuStaticStoryboardSegue.h"
#import "SASlideMenuStaticViewController.h"

@implementation SASlideMenuStaticStoryboardSegue

-(void) perform{
    
    SASlideMenuStaticViewController* source = self.sourceViewController;
    
    UINavigationController* destination = self.destinationViewController;
    
    //Remove shadow from navigation bar title.
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],UITextAttributeTextShadowColor,
                                                           nil]];
    //Set navigation bar pattern and shadow.
    UIImage *navigationBarBackground = [UIImage imageNamed: @"navigationBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    destination.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    destination.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    destination.navigationBar.layer.shadowRadius = 0.5f;
    destination.navigationBar.layer.shadowOpacity = 0.5f;

    //Set Back button
    UIImage *backButtonImage = [[UIImage imageNamed:@"backButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 38, 0, 1)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //set menu button
    UIButton* menuButton = [[UIButton alloc] init];
    [source.slideMenuDataSource configureMenuButton:menuButton];
    [menuButton addTarget:source action:@selector(doSlideToSide) forControlEvents:UIControlEventTouchUpInside];
    UINavigationItem* navigationItem = destination.navigationBar.topItem;
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];

    if ([source.slideMenuDataSource respondsToSelector:@selector(configureSlideLayer:)]) {
        [source.slideMenuDataSource configureSlideLayer:[destination.view layer]];
    }else{
        CALayer* layer = destination.view.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.3;
        layer.shadowOffset = CGSizeMake(-15, 0);
        layer.shadowRadius = 10;
        layer.masksToBounds = NO;
        layer.shadowPath =[UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
    }
    [source switchToContentViewController:destination];
    
}

@end
