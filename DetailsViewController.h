//
//  DetailsViewController.h
//  SoftServeDP
//
//  Created by Andrew Gavrish on 19.02.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Flurry.h"
@class CDDiscountObject;

@interface DetailsViewController : UITableViewController <CLLocationManagerDelegate, UIActionSheetDelegate>{
    CLLocationManager *locationManager;
}
@property (nonatomic,strong) CDDiscountObject *discountObject;
@property (weak, nonatomic) UIImage *pintype;


@end
