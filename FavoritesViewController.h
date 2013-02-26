//
//  FavoritesViewController.h
//  SoftServeDP
//
//  Created by Bogdan on 23.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FavoritesViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

+(NSArray *)sortByDistance: (NSArray *)array toLocation: (CLLocation *)location;
@end
