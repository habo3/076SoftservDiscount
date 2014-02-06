//
//  AppDelegate.h
//  SoftServeDP
//
//  Created by Andrew Gavrish on 1/14/13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@class CDCoreDataManager;

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) CDCoreDataManager *coreDataManager;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;

@end
