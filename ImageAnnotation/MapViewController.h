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

// iPad impact
#import "OCMapView.h"
#import "SettingsViewController.h"




@interface MapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,CustomCalloutViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) IBOutlet CLLocationManager *location;

- (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage;

- (NSArray*)fillPicker;

- (NSArray*)getPinsByCategory:(int)filterNumber;


// valid for iPad
@property (weak, nonatomic) IBOutlet OCMapView *topMapLayer;
@property (nonatomic) CGFloat topMapLayerPosition;

@end





