//
//  FavoritesViewController.h
//  SoftServeDP
//
//  Created by Bogdan on 23.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
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

+(NSArray *)sortByDistance: (NSArray *)array toLocation: (CLLocation *)location;
+(NSArray *)sortByName: (NSArray *)array;

@end
