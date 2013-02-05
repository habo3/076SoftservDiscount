//
//  ViewController.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"
#import "myDetailViewController.h"
#import "DiscountObject.h"
#import "Category.h"
//#import <CoreGraphics/CoreGraphics.h>
/*enum
{
    kCityAnnotationIndex = 0,
    kBridgeAnnotationIndex,
    kTeaGardenAnnotationIndex
};*/

@interface MapViewController ()<MKAnnotation>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;


@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) NSMutableArray *myLocations;


@end


#pragma mark -

@implementation MapViewController

@synthesize location;
@synthesize managedObjectContext;

- (void)gotoLocation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 49.836744;
    newRegion.center.longitude = 24.031359;
    newRegion.span.latitudeDelta = 0.0512872;
    newRegion.span.longitudeDelta = 0.0509863;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (IBAction) getLocation:(id)sender {
    
    if(self.mapView.showsUserLocation)
    {
        self.mapView.showsUserLocation = FALSE;
        [location stopUpdatingLocation];
    }
    else
    {
    self.mapView.showsUserLocation = TRUE;
    
    self.location = [[CLLocationManager alloc]init];
    location.delegate = self;
    location.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    location.distanceFilter = kCLDistanceFilterNone;
    [location startUpdatingLocation];
    }
}
    /*location.
    self.myLocations = [[NSMutableArray alloc] initWithCapacity:1];
    CLLocationCoordinate2D geoCoord;
    geoCoord.latitude = 49.838093;
    geoCoord.longitude= 24.025973;
    
    
    
    //CLLocation *locationManager;
}*/


- (void)viewWillAppear:(BOOL)animated
{

    UIColor * rgbColor = [UIColor colorWithRed:0.988 green: 0.69 blue: 0.184 alpha:1.0];
    self.navigationController.navigationBar.tintColor = rgbColor;
    [super viewDidAppear:animated];
    [self gotoLocation];
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotations:self.mapAnnotations];
}

- (void)viewDidLoad
{
    
    self.mapView.delegate = self;
    
    self.mapAnnotations = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D tmpCoord;
    
    // annotation for the 
    Annotation *myAnnotation;
    myAnnotation= [[Annotation alloc]init];
    tmpCoord.latitude = 49.8285155;
    tmpCoord.longitude = 23.9921021;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"SoftServe";//@"Чисто";
    myAnnotation.subtitle = @"yeap,wrong coords for test";//Мережа хімчисток";
    myAnnotation.pintype = @"technicalpin.png";
    
    [self.mapAnnotations addObject:myAnnotation];//atIndex:kAnnotationIndex];

    myAnnotation= [[Annotation alloc]init];
    tmpCoord.latitude = 49.840681;
    tmpCoord.longitude = 24.026327;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"Дублін";
    myAnnotation.subtitle = @"Irish pub";
    myAnnotation.pintype = @"eatpin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    [self.mapAnnotations addObject:myAnnotation];
    
    //Annotation *myAnnotation;
    myAnnotation= [[Annotation alloc]init];
    tmpCoord.latitude = 49.836744;
    tmpCoord.longitude = 24.031359;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"4Friends";
    myAnnotation.subtitle = @"Whiskey pub";
    myAnnotation.pintype = @"eatpin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    [self.mapAnnotations addObject:myAnnotation];
    
    myAnnotation= [[Annotation alloc]init];
    tmpCoord.latitude = 49.835744;
    tmpCoord.longitude = 24.051359;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"Фотостудія";
    myAnnotation.subtitle = @"Фото на вагу золота)";
    myAnnotation.pintype = @"photopin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    NSPredicate *objectsFind = [NSPredicate predicateWithFormat:nil];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:objectsFind];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    
    for (DiscountObject *object in objectsFound)
    {
        NSNumber *longtitude = object.geoLongitude;
        NSNumber *latitude = object.geoLongitude;
        NSString *title = object.name;
        NSString *subtitle = object.address;
        NSLog(@"name :%@, latitude: %@, longtitude: %@, adress: %@", title, latitude, longtitude, subtitle);//debug
    }
    
    [self.mapAnnotations addObject:myAnnotation];
    
    [self gotoLocation];
    
    
        
    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation!= UIInterfaceOrientationPortraitUpsideDown;
}




#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    if ([annotation isKindOfClass:[Annotation class]])   // for Annotation
    {
        // type cast for property use
        Annotation *newAnnotation;
        newAnnotation = (Annotation *)annotation;
        
        static NSString *stringAnnotationIdentifier = @"StringAnnotationIdentifier";
        
        MKAnnotationView *annotationView =
        [_mapView dequeueReusableAnnotationViewWithIdentifier:stringAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:stringAnnotationIdentifier];
        }
        
        annotationView.canShowCallout = YES;
         // DON'T FORGET TO CHANGE IT TO myAnnotation.pintype
        annotationView.image = [UIImage imageNamed:newAnnotation.pintype];
       
        
        
        //==========================Changes pin background, but not Annotation ===================
        //UIColor * rgbColor = [UIColor  colorWithRed:0.99 green: 0.71  blue: 0.08  alpha:1.0];
        //annotationView.backgroundColor = rgbColor;
        
        UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:newAnnotation.leftImage]];// @"eatpin.png"/*@"softicon.png"*/]];
        annotationView.leftCalloutAccessoryView = sfIconView;
        UIButton* detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [detailButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = detailButton;
        //annotationView.canShowCallout = YES;
        //annotationView.draggable = NO;
        return annotationView;
    }

    return nil;
}

- (void)showDetails:(id)sender
{
    [self performSegueWithIdentifier:@"myDetailView" sender:self];
}



@end
