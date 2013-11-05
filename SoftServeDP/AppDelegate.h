//
//  AppDelegate.h
//  SoftServeDP
//
//  Created by Bogdan on 1/14/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@class CDCoreDataManager;

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContextNew;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModelNew;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinatorNew;

@property (readonly, strong, nonatomic) CDCoreDataManager *coreDataManager;

- (NSURL *)applicationDocumentsDirectory;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;

@end
