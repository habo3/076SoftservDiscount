//
//  LoginViewController.m
//  SoftServe Discount
//
//  Created by Victor on 18.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()<FBLoginViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@end


@implementation LoginViewController

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
	// Do any additional setup after loading the view.
    if ([[FBSession activeSession] accessToken]) {
        NSLog(@"access");
        [self performSegueWithIdentifier:@"FromLoginToLoad" sender:self.window.rootViewController];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
