//
//  FavoritesViewController.h
//  SoftServeDP
//
//  Created by Andrew Gavrish on 23.02.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Flurry.h"

@class CDCoreDataManager;

@interface FavoritesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CDCoreDataManager *coreDataManager;
@property (strong,nonatomic) NSArray *discountObjects;


@end
