//
//  AppDelegate.m
//  SoftServeDP
//
//  Created by Bogdan on 1/14/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Flurry.h"
#import "CDCoreDataManager.h"
#import "JPJsonParser.h"

NSString *const FBSessionStateChangedNotification = @"SoftServeDP:FBSessionStateChangedNotification";

@implementation AppDelegate

@synthesize managedObjectContextNew = _managedObjectContextNew;
@synthesize managedObjectModelNew = _managedObjectModelNew;
@synthesize persistentStoreCoordinatorNew = _persistentStoreCoordinatorNew;

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
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"geoLocation"];
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"firstLaunch"];
    }

    return YES;
}

-(void) closeSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
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
    
    return [FBSession openActiveSessionWithPermissions:permissions
                                          allowLoginUI:allowLoginUI
                                     completionHandler:^(FBSession *session,
                                                         FBSessionState state,
                                                         NSError *error) {
                                         [self sessionStateChanged:session
                                                             state:state
                                                             error:error];
                                     }];
    
}


-(CDCoreDataManager *)coreDataManager
{
    if (_coreDataManager != Nil) {
        return _coreDataManager;
    }
    
    _coreDataManager = [[CDCoreDataManager alloc] init];
    return _coreDataManager;
}

#pragma mark - New managed object context

-(NSManagedObjectContext *)managedObjectContextNew
{
    if (_managedObjectContextNew != nil) {
        return _managedObjectContextNew;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorNew];
    if (coordinator != nil) {
        _managedObjectContextNew = [[NSManagedObjectContext alloc] init];
        [_managedObjectContextNew setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContextNew;
}

- (NSManagedObjectModel *)managedObjectModelNew
{
    if (_managedObjectModelNew != nil) {
        return _managedObjectModelNew;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewModel" withExtension:@"momd"];
    //NSLog(@"%@",modelURL);
    _managedObjectModelNew = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModelNew;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorNew
{
    if (_persistentStoreCoordinatorNew != nil)
    {
        return _persistentStoreCoordinatorNew;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewModel2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinatorNew = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelNew]];
    if (![_persistentStoreCoordinatorNew addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinatorNew;
}

#pragma mark - Application's Documents directory

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
