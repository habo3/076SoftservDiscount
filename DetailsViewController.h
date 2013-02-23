//
//  DetailsViewController.h
//  SoftServeDP
//
//  Created by Bogdan on 19.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountObject.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DetailsViewController : UITableViewController <CLLocationManagerDelegate, UIActionSheetDelegate>{
    CLLocationManager *locationManager;
}
@property  (nonatomic, weak) DiscountObject *discountObject;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
