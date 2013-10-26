//
//  AppDelegate.m
//  SoftServeDP
//
//  Created by Bogdan on 1/14/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "JSONParser.h"
#import "Flurry.h"

NSString *const FBSessionStateChangedNotification = @"SoftServeDP:FBSessionStateChangedNotification";

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize managedObjectContextNew = _managedObjectContextNew;
@synthesize managedObjectModelNew = _managedObjectModelNew;
@synthesize persistentStoreCoordinatorNew = _persistentStoreCoordinatorNew;

-(void) applicationWillEnterForeground:(UIApplication *)application
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(FBSession.activeSession.isOpen)
    {
        [userDefaults setObject:[NSNumber numberWithBool:NO]  forKey:@"sessionRequest"];
    }
    if(![[userDefaults objectForKey:@"sessionRequest"]boolValue])
    {
        JSONParser *parser =[[JSONParser alloc] init ];
        parser.managedObjectContext = self.managedObjectContext;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [parser updateDBWithOptions];
        });
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
    
    JSONParser *parser = [[JSONParser alloc] init ];
    parser.managedObjectContext = self.managedObjectContext;
    if (![userDefaults objectForKey:@"lastDBUpdate"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [parser updateDB];
        });
        // set update frequency
        [userDefaults setObject:[NSNumber numberWithInt:0] forKey:@"updatePeriod"];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [parser updateDBWithOptions];
        });
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

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SoftServeDP.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewModel.sqlite"];
    
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
