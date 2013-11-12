//
//  LoadScreenViewController.h
//  SoftServe Discount
//
//  Created by Maxim on 3.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDCoreDataManager;
@interface LoadScreenViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) CDCoreDataManager *coreDataManager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
