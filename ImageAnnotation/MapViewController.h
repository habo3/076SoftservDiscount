//
//  ViewController.h
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) IBOutlet CLLocationManager *location;
@end
