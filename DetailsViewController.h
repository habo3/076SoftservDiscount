//
//  DetailsViewController.h
//  SoftServeDP
//
//  Created by Bogdan on 19.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountObject.h"
#import "Category.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Flurry.h"
@class CDDiscountObject;

@interface DetailsViewController : UITableViewController <CLLocationManagerDelegate, UIActionSheetDelegate>{
    CLLocationManager *locationManager;
}
@property  (nonatomic, strong) DiscountObject *discountObject;
@property (nonatomic,strong) CDDiscountObject *discountObjectNew;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) UIImage *pintype;
@end
