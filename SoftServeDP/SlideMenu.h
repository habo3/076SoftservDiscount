//
//  SlideMenuImplementor.h
//  SoftServeDP
//
//  Created by Bogdan on 1/14/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuStaticViewController.h"
#import "SASlideMenuDataSource.h"

@interface SlideMenu :SASlideMenuStaticViewController<SASlideMenuDataSource>
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
