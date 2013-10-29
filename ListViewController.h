//
//  ViewController.h
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Flurry.h"
@class CDCoreDataManager;

@interface ListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) CDCoreDataManager *coreDataManager;
@property(strong, nonatomic) NSArray *dataSource;
@property (strong,nonatomic) NSArray *discountObjects;

@end
