//
//  MenuViewController.m
//  SoftServe Discount
//
//  Created by agavrish on 21.10.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "MenuViewController.h"
#import "CustomViewMaker.h"
#import <FacebookSDK/FacebookSDK.h>
#import "KxIntroViewController.h"
#import "NSOperationQueue+SharedQueue.h"
#import "AppDelegate.h"

@interface MenuViewController()<FBLoginViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) FBLoginView *loginview;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

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
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        [self putFBButton];
        if ([[FBSession activeSession] accessTokenData].accessToken)
            [self.facebookButton setTitle:@"Log Out" forState:UIControlStateNormal];
        else
            [self.facebookButton setTitle:@"Log In" forState:UIControlStateNormal];
    }
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

-(void)putFBButton
{
    self.facebookButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookButton  addTarget:self action:@selector(loginFBButton:) forControlEvents:UIControlEventTouchDown];
    
    UIImage *loginImage = [UIImage imageNamed:@"facebookLoginButton.png"];
    loginImage = [self imageWithImage:loginImage scaledToSize:CGSizeMake(250, 60)];
    [self.facebookButton  setBackgroundImage:loginImage forState:UIControlStateNormal];
    [self.facebookButton  setBackgroundImage:nil forState:UIControlStateSelected];
    [self.facebookButton  setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.facebookButton .frame = CGRectMake(35, self.view.bounds.size.height-150, 271, 101);
    [self.facebookButton  sizeToFit];
    
    
    [self.view addSubview:self.facebookButton];
    
}

-(IBAction)loginFBButton:(id)sender
{
    if ([[FBSession activeSession] accessTokenData].accessToken) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Logout from Facebook?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log Out", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];
    }
    else
    {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] openSessionWithAllowLoginUI:YES];
//        NSLog(@"logIN");
        [self.facebookButton setTitle:@"Log Out" forState:UIControlStateNormal];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        return;
    if (buttonIndex == 0) {
        //        [(AppDelegate *)[[UIApplication sharedApplication] delegate] closeSession];
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
//        NSLog(@"logOUT");
        [self.facebookButton setTitle:@"Log In" forState:UIControlStateNormal];
    }
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
