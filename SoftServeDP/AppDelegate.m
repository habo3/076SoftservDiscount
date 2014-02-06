//
//  AppDelegate.m
//  SoftServeDP
//
//  Created by Andrew Gavrish on 1/14/13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Flurry.h"
#import "CDCoreDataManager.h"
#import "JPJsonParser.h"

NSString *const FBSessionStateChangedNotification = @"SoftServeDP:FBSessionStateChangedNotification";

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize coreDataManager = _coreDataManager;

#pragma mark - App methods
-(void) applicationWillEnterForeground:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(FBSession.activeSession.isOpen)
    {
        [userDefaults setObject:[NSNumber numberWithBool:NO]  forKey:@"sessionRequest"];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Initialized flurry analytics
    [Flurry setCrashReportingEnabled:YES];
    
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSString *flurryApiKey = [NSString stringWithString:[dictRoot objectForKey:@"FlurryApiKey"]];
    [Flurry startSession:flurryApiKey];
    
    
    //check if app was ever updated and decide: update in background or in main thread
    [self closeSession];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"geoLocation"])
    {
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"geoLocation"];
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"firstLaunch"];
    }

    return YES;
}

-(void) closeSession
{
//    [FBSession.activeSession closeAndClearTokenInformation];
}


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    switch (state)
    {
        case FBSessionStateOpen:
            if (!error)
            {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream",nil];

    return [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:      FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session,                                                                                                                                                                FBSessionState state,                                                                                                                                                                NSError *error) {
        [self sessionStateChanged:session
                            state:state
                            error:error];
    }];
}


-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

#pragma mark - New managed object context

-(NSManagedObjectContext *)managedObjectContext
{
    return [[CDCoreDataManager sharedInstance] managedObjectContext];
}

- (NSManagedObjectModel *)managedObjectModel
{
    return [[CDCoreDataManager sharedInstance] managedObjectModel];
}

#pragma mark - Application's Documents directory

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}


@end
