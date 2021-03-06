//
//  LoadScreenViewController.h
//  SoftServe Discount
//
//  Created by Maxim on 3.11.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPJsonParser.h"
#import "DownloadOperation.h"

@class CDCoreDataManager;
@interface LoadScreenViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) CDCoreDataManager *coreDataManager;

@end
