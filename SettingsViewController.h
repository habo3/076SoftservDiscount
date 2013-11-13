//
//  SettingsViewController.h
//  SoftServeDP
//
//  Created by Andrew Gavrish on 28.01.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flurry.h"

@class CDCoreDataManager;

@interface SettingsViewController : UIViewController
@property (nonatomic, strong) CDCoreDataManager *coreDataManager;
@end
