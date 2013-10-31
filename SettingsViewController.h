//
//  SettingsViewController.h
//  SoftServeDP
//
//  Created by Bogdan on 28.01.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountObject.h"
#import "Flurry.h"

@class CDCoreDataManager;

@interface SettingsViewController : UIViewController
@property (nonatomic, strong) CDCoreDataManager *coreDataManager;
@end
