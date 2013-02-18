//
//  MapViewController.m
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

#define MAP_SPAN_DELTA 0.005


@interface MapViewController ()<MKAnnotation>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CustomCalloutView *calloutView;
@property (nonatomic,strong) NSMutableArray *annArray;
@end

@implementation MapViewController

@synthesize calloutView, annArray;
@synthesize location;
@synthesize managedObjectContext;

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    [self gotoLocation];
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    
    [self.mapView addAnnotations:self.annArray];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    self.annArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D tmpCoord;
    
    // annotation for the
    Annotation *myAnnotation;
    myAnnotation= [[Annotation alloc]init];
    
    // button for callout
    UIImage *image = [UIImage   imageNamed:@"annDetailButton.png"];
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 32 /*image.size.width*/,32 /*image.size.height*/);
    disclosureButton.frame = frame;
    [disclosureButton setBackgroundImage:image forState:UIControlStateNormal];
    disclosureButton.backgroundColor = [UIColor clearColor];
    [disclosureButton addTarget:self action:@selector(disclosureTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // image for callout
    UIView *leftImage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyLeftImage.png"]];
    
    // calloutView init
    self.calloutView.delegate = self;
    self.calloutView = [CustomCalloutView new];
    self.calloutView.leftAccessoryView = leftImage;
    self.calloutView.rightAccessoryView = disclosureButton;
    
    
    // fetch objects from db
    NSPredicate *objectsFind = [NSPredicate predicateWithFormat:nil];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:objectsFind];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    
    UIFont *font = [UIFont fontWithName:@"icons" size:10];
    // image with text
    UIImage *emptyImage =[UIImage imageNamed:@"emptyLeftImage.png"];
    UIImage *emptyPinImage = [UIImage imageNamed:@"emptyPin.png"];
    for (DiscountObject *object in objectsFound)
    {
        NSNumber *dbLongitude = object.geoLongitude;
        NSNumber *dbLatitude = object.geoLatitude;
        NSString *dbTitle = object.name;
        NSString *dbSubtitle = object.address;
        NSSet *dbCategories = object.categories;
        Category *dbCategory = [dbCategories anyObject];
        
        //show getting data from DB (for debug)
        //NSLog(@"name :%@, latitude: %@, longtitude: %@, adress: %@", dbTitle, dbLatitude, dbLongitude, dbSubtitle);
        //NSLog(@"font: %@", dbCategory.fontSymbol);
        
        //display text on images
        UIImage *myNewImage = [self setText:@"-99%"
                                   withFont: nil
                                   andColor:[UIColor blackColor]
                                    onImage:emptyImage];
        UIImage *pinImage = [self setText:dbCategory.fontSymbol withFont:font
                                 andColor:[UIColor whiteColor] onImage:emptyPinImage];
        
        
        myAnnotation= [[Annotation alloc]init];
        
        tmpCoord.latitude = [dbLatitude doubleValue];
        tmpCoord.longitude =[dbLongitude doubleValue];
        myAnnotation.coordinate = tmpCoord;
        myAnnotation.title = dbTitle;
        myAnnotation.subtitle = dbSubtitle;
        myAnnotation.pintype = pinImage;
        myAnnotation.leftImage = [[UIImageView alloc] initWithImage: myNewImage];
        
        [self.annArray addObject:myAnnotation];
    }
    
    [self gotoLocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation!= UIInterfaceOrientationPortraitUpsideDown;
}


- (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage
{
    
    NSString *tmpText = @"";
    CGRect rect = CGRectMake(0, 0, 0, 0);
    
    double margin = 3.0;
    float fontsize = (startImage.size.width - 2 * margin);
    
    if([font isKindOfClass:[UIFont class]])
    {
        // size of custom text in image
        fontsize = fontsize/3;
        font = [font fontWithSize:fontsize];
        
        NSString *cuttedSymbol = [text stringByReplacingOccurrencesOfString:@"&#" withString:@"0"];
        //for debugging
        //NSLog(@"cutted symbol %@",cuttedSymbol);
        
        //converting Unicode Character String (0xe00b) to UTF32Char
        UTF32Char myChar = 0;
        NSScanner *myConvert = [NSScanner scannerWithString:cuttedSymbol];
        [myConvert scanHexInt:(unsigned int *)&myChar];
        
        //set data to string
        NSData *utf32Data = [NSData dataWithBytes:&myChar length:sizeof(myChar)];
        tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
        
        // own const for pin text (height position)
        float ownHeight = 0.4*startImage.size.height;
        
        rect = CGRectMake((startImage.size.width - font.pointSize)/2, ownHeight - font.pointSize/2, startImage.size.width, startImage.size.height);
    }
    else
    {
        
        fontsize = fontsize /text.length*1.3; // multiply by 1.3 for better font visibility
        font = [UIFont systemFontOfSize:fontsize];
        
        margin = (startImage.size.width - font.pointSize * text.length/2)/2;
        rect = CGRectMake(margin, (startImage.size.height - font.pointSize)/2, startImage.size.width, startImage.size.height);
        //for debug
        //NSLog(@"Text length %lu",(unsigned long)text.length);
        //NSLog(@"Point size %f",font.pointSize);
        //NSLog(@"image size.width %f",startImage.size.width);
        tmpText = text;
        
    }
    
    //work with image
    UIGraphicsBeginImageContextWithOptions(startImage.size,NO, 0.0);
    //UIGraphicsBeginImageContext();
    
    [startImage drawInRect:CGRectMake(0,0,startImage.size.width,startImage.size.height)];
    
    //Position and color
    
    [color set];
    
    
    
    //draw text on image and save result
    [tmpText drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
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
        
        CustomAnnotationView *annotationView = (CustomAnnotationView *)
        [_mapView dequeueReusableAnnotationViewWithIdentifier:stringAnnotationIdentifier];
        if (!annotationView) {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                              reuseIdentifier:stringAnnotationIdentifier];
        }
        //setting pin image
        annotationView.image = newAnnotation.pintype;
        return annotationView;
    }
    
    return nil;
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (calloutView.window)
        [calloutView dismissCalloutAnimated/*:NO*/];
    
    [self performSelector:@selector(popupMapCalloutView:) withObject:view afterDelay:0];//1.0/3.0];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    // again, we'll introduce an artifical delay to feel more like MKMapView for this demonstration.
    [calloutView performSelector:@selector(dismissCalloutAnimated) withObject:nil afterDelay:0];//1.0/3.0];
}



- (void)popupMapCalloutView:(CustomAnnotationView *)annotationView {
    if(![[self.mapView.selectedAnnotations objectAtIndex:0]isKindOfClass:[MKUserLocation class]])
    {
        NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
        Annotation *selectedAnnotation = selectedAnnotations.count > 0 ? [selectedAnnotations objectAtIndex:0] : nil;
        
        calloutView.title = selectedAnnotation.title;
        calloutView.subtitle = selectedAnnotation.subtitle;
        calloutView.leftAccessoryView = selectedAnnotation.leftImage;
        ((CustomAnnotationView *)annotationView).calloutView = calloutView;
        [calloutView presentCalloutFromRect:annotationView.bounds
                                     inView:annotationView
                          constrainedToView:self.mapView];
    }
}



- (void)disclosureTapped {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"§ Disclosure pressed! §"
                                                    message:@"Currently detail view in progress, wait for Sprint#3 end. Thanks for understanding"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}


- (void)dismissCallout {
    [calloutView dismissCalloutAnimated];
}



#pragma mark -


- (void)gotoLocation
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 49.836744;
    newRegion.center.longitude = 24.031359;
    newRegion.span.latitudeDelta = MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = MAP_SPAN_DELTA;
    
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


- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = MAP_SPAN_DELTA;
    span.longitudeDelta = MAP_SPAN_DELTA;
    CLLocationCoordinate2D userCoords;
    userCoords.latitude = aUserLocation.coordinate.latitude;
    userCoords.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = userCoords;
    [aMapView setRegion:region animated:YES];
}



- (void)showDetails:(id)sender
{
    [self performSegueWithIdentifier:@"myDetailView" sender:self];
}



@end
