//
//  MapViewController.h
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomCalloutView.h"
#import "Annotation.h"
#import "CustomAnnotationView.h"
#import "CustomPicker.h"
#import "Flurry.h"

@class CDCoreDataManager;

@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,CustomCalloutViewDelegate>

@property (strong, nonatomic) CDCoreDataManager *coreDataManager;

@property (nonatomic,retain) IBOutlet CLLocationManager *location;

- (NSArray*)fillPicker;

@end





