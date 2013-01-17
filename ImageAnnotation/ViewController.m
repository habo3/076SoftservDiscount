//
//  ViewController.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "ViewController.h"
#import "CafeAnnotation.h"
//1

enum
{
    kCityAnnotationIndex = 0,
    kBridgeAnnotationIndex,
    kTeaGardenAnnotationIndex
};

@interface ViewController ()<MKAnnotation>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
//@property (nonatomic, strong) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, strong) NSMutableArray *mapAnnotations;

@end


#pragma mark -

@implementation ViewController

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}

+ (CGFloat)calloutHeight;
{
    return 40.0f;
}

- (void)gotoLocation
{

    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 49.836744;
    newRegion.center.longitude = 24.031359;
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    // restore the nav bar to translucent
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [super viewDidAppear:animated];
    [self gotoLocation];
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotations:self.mapAnnotations];
}

- (void)viewDidLoad
{
    
    self.mapView.delegate = self;

    self.mapAnnotations = [[NSMutableArray alloc] initWithCapacity:2];
    
    // annotation for the City of San Francisco
    CafeAnnotation *sfAnnotation = [[CafeAnnotation alloc] init];
    [self.mapAnnotations insertObject:sfAnnotation atIndex:kCityAnnotationIndex];

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
    
    if ([annotation isKindOfClass:[CafeAnnotation class]])   // for City of San Francisco
    {
        static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
        
        MKAnnotationView *annotationView =
        [_mapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (annotationView)
            return annotationView;
        else     //== nil)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:SFAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"eatpin.png"]];
            
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"softicon.png"]];
            annotationView.leftCalloutAccessoryView = sfIconView;
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(writeSomething:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton setTitle:annotation.title forState:UIControlStateNormal];
            annotationView.rightCalloutAccessoryView = rightButton;
            //annotationView.canShowCallout = YES;
            //annotationView.draggable = NO;
            return annotationView;
       }
        return annotationView;
    }

    return nil;
}

@end
