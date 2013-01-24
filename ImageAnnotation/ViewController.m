//
//  ViewController.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "ViewController.h"
#import "CafeAnnotation.h"
#import "myDetailViewController.h"
//#import <CoreGraphics/CoreGraphics.h>
enum
{
    kCityAnnotationIndex = 0,
    kBridgeAnnotationIndex,
    kTeaGardenAnnotationIndex
};

@interface ViewController ()<MKAnnotation>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

- (IBAction)GetLocation:(id)sender;

@property (nonatomic, strong) NSMutableArray *mapAnnotations;

@end


#pragma mark -

@implementation ViewController

/*+ (CGFloat)annotationPadding;
{
    return 10.0f;
}

+ (CGFloat)calloutHeight;
{
    return 40.0f;
}
*/
- (void)gotoLocation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 49.836744;
    newRegion.center.longitude = 24.031359;
    newRegion.span.latitudeDelta = 0.0512872;
    newRegion.span.longitudeDelta = 0.0509863;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    // restore the nav bar to translucent
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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
    CafeAnnotation *myAnnotation;
    myAnnotation= [[CafeAnnotation alloc]init];
    tmpCoord.latitude = 49.8285155;
    tmpCoord.longitude = 23.9921021;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"SoftServe";//@"Чисто";
    myAnnotation.subtitle = @"yeap,wrong coords for test";//Мережа хімчисток";
    myAnnotation.pintype = @"technicalpin.png";
    
    [self.mapAnnotations addObject:myAnnotation];//atIndex:kAnnotationIndex];

    myAnnotation= [[CafeAnnotation alloc]init];
    tmpCoord.latitude = 49.840681;
    tmpCoord.longitude = 24.026327;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"Дублін";
    myAnnotation.subtitle = @"Irish pub";
    myAnnotation.pintype = @"eatpin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    [self.mapAnnotations addObject:myAnnotation];
    
    //CafeAnnotation *myAnnotation;
    myAnnotation= [[CafeAnnotation alloc]init];
    tmpCoord.latitude = 49.836744;
    tmpCoord.longitude = 24.031359;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"4Friends";
    myAnnotation.subtitle = @"Whiskey pub";
    myAnnotation.pintype = @"eatpin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    [self.mapAnnotations addObject:myAnnotation];
    
    myAnnotation= [[CafeAnnotation alloc]init];
    tmpCoord.latitude = 49.835744;
    tmpCoord.longitude = 24.051359;
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.title = @"Фотостудія";
    myAnnotation.subtitle = @"Фото на вагу золота)";
    myAnnotation.pintype = @"photopin.png";
    myAnnotation.leftImage = @"emptyLeftImage.png";
    
    [self.mapAnnotations addObject:myAnnotation];
    
    [self gotoLocation];   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}




#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // in case it's the user location, we already have an annotation, so just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    if ([annotation isKindOfClass:[CafeAnnotation class]])   // for CafeAnnotation
    {
        // type cast for property use
        CafeAnnotation *newAnnotation;
        newAnnotation = (CafeAnnotation *)annotation;
        
        static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
        
        MKAnnotationView *annotationView =
        [_mapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:SFAnnotationIdentifier];
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


- (IBAction)GetLocation:(id)sender {
}
@end
