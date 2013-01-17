//
//  SASlideMenuStaticViewController.h
//  SASlideMenu
//
//  Created by Stefano Antonellio on 7/29/12.
//  Copyright (c) 2012 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuDataSource.h"

@interface SASlideMenuStaticViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (assign, nonatomic) NSObject<SASlideMenuDataSource>* slideMenuDataSource;

-(void) switchToContentViewController:(UIViewController*) content;
-(void) doSlideToSide;

@end
