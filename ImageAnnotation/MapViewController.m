//
//  MapViewController.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"
#import "DetailsViewController.h"
#import "OCMapView.h"
#import "OCAnnotation.h"
#import "AppDelegate.h"
#import "CDCoreDataManager.h"
#import "CDCategory.h"
#import "CDDiscountObject.h"
#import "CDCity.h"
#import "CustomViewMaker.h"
#import "ActionSheetStringPicker.h"

#define MAP_SPAN_DELTA 0.045


@interface MapViewController ()<MKAnnotation,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet OCMapView *mapView;
@property (nonatomic) CustomCalloutView *calloutView;
@property (nonatomic) NSMutableArray *annArray;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,assign) NSString *selectedObjectID;
@property (strong, nonatomic) NSArray *discountObjects;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *cities;
@property (nonatomic) BOOL geoLocationIsOn;
@end

@implementation MapViewController

@synthesize calloutView, annArray;
@synthesize coordinate = _coordinate;
@synthesize mapView = _mapView;
@synthesize location;
@synthesize selectedIndex = _selectedIndex;
@synthesize filterButton;
@synthesize selectedObjectID = _selectedObjectID;
@synthesize geoLocationIsOn = _geoLocationIsOn;
@synthesize coreDataManager = _coreDataManager;
@synthesize discountObjects = _discountObjects;
@synthesize categories = _categories;
@synthesize cities = _cities;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CustomViewMaker customNavigationBarForView:self];
    [self initFilterButton];
    
    self.mapView.delegate = self;
    self.mapView.clusterSize = 0.05;
    [self.mapView removeOverlays:self.mapView.overlays];
    self.annArray = [[NSMutableArray alloc] init];
    
    [self initCallout];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    dispatch_async(dispatch_get_main_queue(), ^{
            self.annArray = [self getAllPins];
            [self.mapView addAnnotations:self.annArray];
    });

    [self gotoLocation];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Sending event to analytics service
    [Flurry logEvent:@"MapLoaded"];
    [self.navigationController.navigationBar addSubview:filterButton];
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.geoLocationIsOn = [[userDefaults objectForKey:@"geoLocation"] boolValue];
    if(self.geoLocationIsOn)
    {
        [self initGeoButton];
        self.mapView.showsUserLocation = YES;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [filterButton removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation!= UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

-(NSArray *)discountObjects
{
    return [self.coreDataManager discountObjectsFromCoreData];
}

-(NSArray *)categories
{
    return [self.coreDataManager categoriesFromCoreData];
}

-(NSArray *)cities
{
    return [self.coreDataManager citiesFromCoreData];
}

#pragma mark - customizing view

-(void) initFilterButton
{
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height);
    filterButton.frame = filterFrame;
    
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
}

- (void) initGeoButton
{
    UIImage *geoButtonImage = [UIImage imageNamed:@"geoButton.png"];
    UIButton *geoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect geoFrame = CGRectMake(5, self.mapView.frame.size.height-self.navigationController.navigationBar.frame.size.height
                                 - geoButtonImage.size.height + 40, geoButtonImage.size.width,geoButtonImage.size.height);
    geoButton.frame = geoFrame;
    
    [geoButton setBackgroundImage:geoButtonImage forState:UIControlStateNormal];
    [geoButton addTarget:self action:@selector(gotoLocation) forControlEvents:UIControlEventTouchUpInside];
    geoButton.backgroundColor = [UIColor clearColor];
    [self.mapView addSubview:geoButton];
}

-(void) initCallout
{
    self.calloutView.delegate = self;
    self.calloutView = [CustomCalloutView new];
    [self initDisclosureButton];
}

-(void) initDisclosureButton
{
    UIImage *image = [UIImage   imageNamed:@"annDetailButton.png"];
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 32 ,32);
    disclosureButton.frame = frame;
    [disclosureButton setBackgroundImage:image forState:UIControlStateNormal];
    disclosureButton.backgroundColor = [UIColor clearColor];
    [disclosureButton addTarget:self action:@selector(disclosureTapped) forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = disclosureButton;
}

#pragma mark - PathMaker

-(void)centerMapForCoordinateArray:(CLLocationCoordinate2D *)routes andCount:(int)count
{
	MKCoordinateRegion region;
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < count; idx++)
	{
		CLLocationCoordinate2D currentLocation = routes[idx];
		if(currentLocation.latitude > maxLat)
			maxLat = currentLocation.latitude;
		if(currentLocation.latitude < minLat)
			minLat = currentLocation.latitude;
		if(currentLocation.longitude > maxLon)
			maxLon = currentLocation.longitude;
		if(currentLocation.longitude < minLon)
			minLon = currentLocation.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	[self.mapView setRegion:region animated:YES];
}

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString
{
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}

- (void)getDirections
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), ^{
        CLLocationCoordinate2D coordinate;
        coordinate = self.mapView.userLocation.coordinate;
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude];
        
        float latitude = [self.mapView.selectedAnnotations.firstObject coordinate].latitude;
        float longitude =  [self.mapView.selectedAnnotations.firstObject coordinate].longitude;
        CLLocation *keyPlace = [[CLLocation alloc] initWithLatitude: latitude longitude: longitude];
        
        CLLocationCoordinate2D endCoordinate;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=driving", userLocation.coordinate.latitude, userLocation.coordinate.longitude, keyPlace.coordinate.latitude, keyPlace.coordinate.longitude]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData =  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!error) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            if ([[responseDict valueForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"geoLocation"];
                [userDefaults synchronize];
                self.geoLocationIsOn = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Помилка"
                                            message:@"Неможливо прокласти шлях з вашого поточного місця знаходження. Відлісковування геолокації вимкунто! Щоб знову відслідковувати геолокацію перейдіть в налаштування."
                                           delegate:nil
                                  cancelButtonTitle:@"Закрити"
                                  otherButtonTitles:nil, nil] show];
                });
                return;
            }
            int points_count = 0;
            if ([[responseDict objectForKey:@"routes"] count])
                points_count = [[[[[[responseDict objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"] count];
            
            
            if (!points_count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Помилка"
                                            message:@"Неможливо прокласти шлях з вашого поточного місця знаходження. Відлісковування геолокації вимкунто! Щоб знову відслідковувати геолокацію перейдіть в налаштування."
                                           delegate:nil
                                  cancelButtonTitle:@"Закрити"
                                  otherButtonTitles:nil, nil] show];
                });
                return;
            }
            CLLocationCoordinate2D points[points_count * 3];
            
            MKPolyline *polyline = [self polylineWithEncodedString:[[[[responseDict objectForKey:@"routes"] objectAtIndex:0]objectForKey:@"overview_polyline"] objectForKey:@"points"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView addOverlay:polyline];
            });
            int j = 0;
            NSArray *steps = nil;
            if (points_count && [[[[responseDict objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] count])
                steps = [[[[[responseDict objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
            for (int i = 0; i < points_count; i++) {
                
                double st_lat = [[[[steps objectAtIndex:i] objectForKey:@"start_location"] valueForKey:@"lat"] doubleValue];
                double st_lon = [[[[steps objectAtIndex:i] objectForKey:@"start_location"] valueForKey:@"lng"] doubleValue];
                if (st_lat > 0.0f && st_lon > 0.0f) {
                    points[j] = CLLocationCoordinate2DMake(st_lat, st_lon);
                    j++;
                }
                double end_lat = [[[[steps objectAtIndex:i] objectForKey:@"end_location"] valueForKey:@"lat"] doubleValue];
                double end_lon = [[[[steps objectAtIndex:i] objectForKey:@"end_location"] valueForKey:@"lng"] doubleValue];
                if(j < points_count)
                    points[j] = CLLocationCoordinate2DMake(end_lat, end_lon);
                endCoordinate = CLLocationCoordinate2DMake(end_lat, end_lon);
                j++;
                
            }
        }
    });

}

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.lineWidth = 5;
    UIColor *color = [UIColor colorWithRed: 87.0 / 255.0 green: 126.0 / 255.0 blue: 212.0 / 255.0 alpha: 1.0];
    overlayView.strokeColor = color;
    overlayView.fillColor = [color colorWithAlphaComponent:0.5f];
    return overlayView;
}

#pragma mark - createAnnotation

- (Annotation*)createAnnotationFromData:(CDDiscountObject*)discountObject
{
    CLLocationCoordinate2D tmpCoord;
    // annotation for pins
    Annotation *myAnnotation = [[Annotation alloc]init];
    
    // font for pins image
    UIFont *font = [UIFont fontWithName:@"icons" size:10];
    // image with text
    UIImage *emptyImage =[UIImage imageNamed:@"emptyLeftImage.png"];
    UIImage *emptyPinImage = [UIImage imageNamed:@"emptyPin.png"];
    
    NSNumber *dbLongitude = [discountObject.geoPoint valueForKey:@"longitude"];
    NSNumber *dbLatitude = [discountObject.geoPoint valueForKey:@"latitude"];
    NSString *dbTitle = discountObject.name;
    NSString *dbSubtitle = discountObject.address;
    NSSet *dbCategories = discountObject.categorys;
    NSString *dbDiscountTo = [NSString stringWithFormat:@"%@%%", [discountObject.discount valueForKey:@"to"]];
    NSString *dbDiscountFrom;
    if(![[discountObject.discount valueForKey:@"to"] isEqualToNumber:[discountObject.discount valueForKey:@"from"]])
        dbDiscountFrom = [NSString stringWithFormat:@"%@-", [discountObject.discount valueForKey:@"from"]];
    else
        dbDiscountFrom = [NSString stringWithFormat:@""];

    CDCategory *dbCategory = [dbCategories anyObject];

    // formating discountValue to "x%", where x discountValue
    NSString *discount = [dbDiscountFrom stringByAppendingString:dbDiscountTo];
    
    // creating new image
    UIImage *myNewImage = [CustomViewMaker setText:discount
                               withFont: nil
                               andColor:[UIColor blackColor]
                                onImage:emptyImage];
    UIImage *pinImage = [CustomViewMaker setText:dbCategory.fontSymbol withFont:font
                             andColor:[UIColor whiteColor] onImage:emptyPinImage];    
    
    myAnnotation= [[Annotation alloc]init];
    
    tmpCoord.latitude = [dbLatitude doubleValue];
    tmpCoord.longitude =[dbLongitude doubleValue];
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.identeficator = discountObject.id;
    myAnnotation.object = discountObject;
    myAnnotation.title = dbTitle;
    myAnnotation.subtitle = dbSubtitle;
    myAnnotation.pintype = pinImage;
    myAnnotation.leftImage = [[UIImageView alloc] initWithImage: myNewImage];
    return myAnnotation;
}


#pragma mark - Picker section

- (NSMutableArray*)getAllPins
{
    NSMutableDictionary *hash = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrayOfAnnotations= [[NSMutableArray alloc]init];
    Annotation *currentAnn;
    NSArray *array = [self.coreDataManager discountObjectsFromCoreData];
        for (CDDiscountObject *object in array) {
            double scaleX, scaleY, distanceFromObject;
            distanceFromObject = 0.00006;
            scaleX = 0.0;
            scaleY = distanceFromObject;
            currentAnn = [self createAnnotationFromData:object];
            NSString *key = [NSString stringWithFormat:@"%1.4f|%1.4f",currentAnn.coordinate.latitude, currentAnn.coordinate.longitude];
            NSMutableArray *array = [hash valueForKey:key]?[hash valueForKey:key]:[[NSMutableArray alloc] init];
            [array addObject:currentAnn];
            [hash setValue:array forKey:key];
            
            if(currentAnn.coordinate.latitude != 0 && currentAnn.coordinate.longitude != 0)
                [arrayOfAnnotations addObject:currentAnn];
        }
    
    for (NSString *key in [hash allKeys]) {
        NSMutableArray *array = [[hash valueForKey:key] copy];
        if([array count] > 1)
        {
            double distanceFromObject = 0.00006;
            float scaleX = 0.0;
            float scaleY = distanceFromObject;
            for (int i = 1; i < [array count]; i++)
            {
                Annotation *current = array[i];
                CLLocationCoordinate2D coord;
                coord.latitude = current.coordinate.latitude + scaleX;
                coord.longitude = current.coordinate.longitude + scaleY;
                current.coordinate = coord;
                scaleX = scaleX + distanceFromObject;
                if(scaleX > distanceFromObject)
                    scaleX = -1 * distanceFromObject;
                scaleY = scaleY + distanceFromObject;
                if(scaleY > distanceFromObject)
                    scaleY = -1 * distanceFromObject;
            }
        }
    }

    return arrayOfAnnotations;
}

- (NSArray*)getPinsByCategory:(int)filterNumber
{
    NSMutableArray *arrayOfAnnotations= [[NSMutableArray alloc]init];
    CDCategory *category = [self.categories objectAtIndex:filterNumber];
    NSArray *allObjectsFromCategory = [category valueForKey:@"discountObjects"];
    Annotation *currentAnn;
    for (CDDiscountObject *object in allObjectsFromCategory) {
        currentAnn = [self createAnnotationFromData:object];
        [arrayOfAnnotations addObject:currentAnn];
    }
    return arrayOfAnnotations;
}

#pragma mark - MKMapViewPin

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *stringAnnotationIdentifier = @"StringAnnotationIdentifier";
    CustomAnnotationView *annotationView = (CustomAnnotationView *)
    [_mapView dequeueReusableAnnotationViewWithIdentifier:stringAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:stringAnnotationIdentifier];
    }
    
    if ([annotation isKindOfClass:[OCAnnotation class]])
    {
        annotationView.isClusterPin = YES;
        OCAnnotation *newAnn = [[OCAnnotation alloc] initWithOCAnnotation:annotation];
        UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:10.0];
        UIImage *image = [UIImage imageNamed:@"cluster"];
        NSString *text = [[NSString alloc] initWithFormat:@"%i",[newAnn.annotationsInCluster count] ];
        annotationView.image = [CustomViewMaker setText:text withFont:font andColor:[UIColor whiteColor] onImage: image];
        return annotationView;
    }
    else  if ([annotation isKindOfClass:[Annotation class]])
    {
        Annotation *newAnnotation;
        newAnnotation = (Annotation *)annotation;
        annotationView.isClusterPin = NO;
        annotationView.image = newAnnotation.pintype;
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated{
    if(self.mapView.region.span.latitudeDelta > 0.0025 && self.mapView.region.span.longitudeDelta > 0.0025)
        self.mapView.clusteringEnabled = YES;
    else
        self.mapView.clusteringEnabled = NO;
    [self.mapView doClustering];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(CustomAnnotationView *)view {

    if (calloutView.window)
        [calloutView dismissCalloutAnimated];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    if(self.geoLocationIsOn)
    {
        [self getDirections];
    }

    Annotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    [self.mapView setCenterCoordinate:selectedAnnotation.coordinate animated:YES];
    [self performSelector:@selector(popupMapCalloutView:) withObject:view afterDelay:0.5];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {

    [calloutView performSelector:@selector(dismissCalloutAnimated) withObject:nil afterDelay:0];
}

#pragma mark - custom callout

- (void)popupMapCalloutView:(CustomAnnotationView *)annotationView {
    if(![[self.mapView.selectedAnnotations objectAtIndex:0]isKindOfClass:[MKUserLocation class]])
    {
        NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
        Annotation *selectedAnnotation = selectedAnnotations.count > 0 ? [selectedAnnotations objectAtIndex:0] : nil;
        if(!annotationView.isClusterPin){
            calloutView.title = selectedAnnotation.title;
            calloutView.subtitle = selectedAnnotation.subtitle;

            calloutView.leftAccessoryView = selectedAnnotation.leftImage;
            self.selectedObjectID = selectedAnnotation.identeficator;

            ((CustomAnnotationView *)annotationView).calloutView = calloutView;
            [calloutView presentCalloutFromRect:annotationView.bounds
                                     inView:annotationView
                          constrainedToView:self.mapView];
        }
        else
        {
            [self.mapView doClustering];
            [self.mapView deselectAnnotation:[[self.mapView selectedAnnotations] objectAtIndex:0] animated: YES];
            if(self.mapView.region.span.latitudeDelta > 0.0015 && self.mapView.region.span.longitudeDelta > 0.0015)
                [self zoomCluster:selectedAnnotation];
        }
    }

}

- (void)disclosureTapped {
    [self performSegueWithIdentifier:@"detailsMap" sender:self];
}


- (void)dismissCallout {
    [calloutView dismissCalloutAnimated];
}

#pragma mark - location

-(void) zoomCluster:(Annotation *) cluster
{
    CLLocationCoordinate2D coordinate = cluster.coordinate;
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = coordinate.latitude;
    newRegion.center.longitude = coordinate.longitude;
    newRegion.span.latitudeDelta = self.mapView.region.span.latitudeDelta / 8 ;
    newRegion.span.longitudeDelta = self.mapView.region.span.longitudeDelta / 8;
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)gotoLocation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CLLocationCoordinate2D coordinate;
    NSString *city = [userDefaults objectForKey:@"cityName"];
    if(!city)
        city = @"Львів";
    coordinate = [self getCoordinateOfCity:city];
    if(self.geoLocationIsOn
       && self.mapView.userLocation.coordinate.latitude != 0.0)
        coordinate = self.mapView.userLocation.coordinate;

    MKCoordinateRegion newRegion;
    newRegion.center.latitude = coordinate.latitude;
    newRegion.center.longitude = coordinate.longitude;
    newRegion.span.latitudeDelta = MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = MAP_SPAN_DELTA;
    [self.mapView setRegion:newRegion animated:YES];

}

- (CLLocationCoordinate2D) getCoordinateOfCity:(NSString *) name
{
    CLLocationCoordinate2D coordinate;
    for (CDCity *cityObject in self.cities)
    {
        if([cityObject.name isEqualToString:name])
        {
            coordinate.latitude = [self averageOfTwoPoints:[[[cityObject.bounds valueForKey:@"southWest"] valueForKey:@"latitude"] doubleValue]
                                                          :[[[cityObject.bounds valueForKey:@"northEast"] valueForKey:@"latitude"] doubleValue]];
            coordinate.longitude = [self averageOfTwoPoints:[[[cityObject.bounds valueForKey:@"southWest"] valueForKey:@"longitude"] doubleValue]
                                                           :[[[cityObject.bounds valueForKey:@"northEast"] valueForKey:@"longitude"] doubleValue]];
        }
    }
    return coordinate;
}

- (double) averageOfTwoPoints:(double)firstPoint :(double)secondPoint
{
    return (firstPoint + secondPoint)/2;
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

#pragma mark - filter

- (NSArray*)fillPicker
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    NSString *categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",@"Усі категорії", [self getAllPins].count];
    NSMutableArray *names = [[NSMutableArray alloc] initWithObjects:categoryNameWithDetails, nil];
    for (CDCategory *category in categories) {
        categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",category.name, [[category valueForKey:@"discountObjects"] allObjects].count];
        [names addObject:categoryNameWithDetails];
    }
    return names;
}

-(void) filterButtonClicked:(UIControl *)sender{

    [ActionSheetStringPicker showPickerWithTitle:@"" rows:[self fillPicker]
                                initialSelection:self.selectedIndex target:self
                                   successAction:@selector(categoryWasSelected:element:)
                                    cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (void)categoryWasSelected:(NSNumber *)selectedIndex element:(id)element {
    if(self.selectedIndex != [selectedIndex integerValue])
    {
        self.selectedIndex = [selectedIndex integerValue];
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        if (self.selectedIndex<1)
            self.annArray = [[self getAllPins] mutableCopy];
        else
            self.annArray = [[self getPinsByCategory:self.selectedIndex - 1] mutableCopy];
        [self.mapView addAnnotations:self.annArray];
    }
}

#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    for (CDDiscountObject *object in self.discountObjects) {
        if([object.id isEqualToString:self.selectedObjectID])
        {
            dvc.discountObject = object;
            break;
        }
    }
}

@end
