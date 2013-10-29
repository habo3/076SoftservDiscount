//
//  MapViewController.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"
#import "DiscountObject.h"
#import "Category.h"
#import "CustomPicker.h"
#import "DetailsViewController.h"
#import "IconConverter.h"
#import "OCMapView.h"
#import "OCAnnotation.h"
#import "AppDelegate.h"

#define MAP_SPAN_DELTA 0.005


@interface MapViewController ()<MKAnnotation,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet OCMapView *mapView;
@property (nonatomic) CustomCalloutView *calloutView;
@property (nonatomic) NSMutableArray *annArray;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) NSArray *dataSource; 
@property (nonatomic) NSArray *categoryObjects;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,assign) DiscountObject *selectedObject;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MapViewController

@synthesize calloutView, annArray;
@synthesize coordinate = _coordinate;
@synthesize pickerView;
@synthesize mapView = _mapView;
@synthesize location;
@synthesize managedObjectContext;
@synthesize dataSource;
@synthesize categoryObjects;
@synthesize selectedIndex;
@synthesize filterButton;
@synthesize selectedObject;
@synthesize progressView;

#pragma mark - View

- (void)viewDidLoad
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    //Sending event to analytics service
    [Flurry logEvent:@"MapLoaded"];

    [super viewDidLoad];
    [self setNavigationTitle];
    [self setControllerButtons];
    self.mapView.delegate = self;
    self.mapView.clusterSize = 0.05;
    self.pickerView.hidden=TRUE;
    [self.mapView removeOverlays:self.mapView.overlays];
    self.dataSource = [self fillPicker];
    self.annArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([[userDefaults objectForKey:@"firstLaunch"]boolValue])
    {
        [self getLocation:self];
        [userDefaults removeObjectForKey:@"firstLaunch"];
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
        {
            [self getLocation:self];
        }
    }
    self.calloutView.delegate = self;
    self.calloutView = [CustomCalloutView new];
    // button for callout
    UIImage *image = [UIImage   imageNamed:@"annDetailButton.png"];
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 32 ,32);
    disclosureButton.frame = frame;
    [disclosureButton setBackgroundImage:image forState:UIControlStateNormal];
    disclosureButton.backgroundColor = [UIColor clearColor];
    [disclosureButton addTarget:self action:@selector(disclosureTapped) forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = disclosureButton;
    self.annArray = [[self getAllPins] mutableCopy];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annArray];
    [self gotoLocation];

}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:filterButton];
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [filterButton removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation!= UIInterfaceOrientationPortraitUpsideDown;
}

-(void) setNavigationTitle
{
    UILabel *navigationTitle = [[UILabel alloc] init];
    navigationTitle.backgroundColor = [UIColor clearColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:20.0];
    navigationTitle.textColor = [UIColor blackColor];
    self.navigationItem.titleView = navigationTitle;
    navigationTitle.text = self.navigationItem.title;
    [navigationTitle sizeToFit];
}

-(void)setControllerButtons
{
    //filterButton
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height);
    filterButton.frame = filterFrame;
    
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterCategory:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
        
    //geoButton
    UIImage *geoButtonImage = [UIImage imageNamed:@"geoButton.png"];
    UIButton *geoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect geoFrame = CGRectMake(5, self.mapView.frame.size.height-self.navigationController.navigationBar.frame.size.height- geoButtonImage.size.height-25, geoButtonImage.size.width,geoButtonImage.size.height);
    geoButton.frame = geoFrame;
    
    [geoButton setBackgroundImage:geoButtonImage forState:UIControlStateNormal];
    [geoButton addTarget:self action:@selector(getLocation:) forControlEvents:UIControlEventTouchUpInside];
    geoButton.backgroundColor = [UIColor clearColor];
    [self.mapView addSubview:geoButton];
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
    float latitude, longitude;
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:49.841906 longitude:24.021422];
    latitude = [self.mapView.selectedAnnotations.firstObject coordinate].latitude;
    longitude =  [self.mapView.selectedAnnotations.firstObject coordinate].longitude;
    
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
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Could not route path from your current location"
                                       delegate:nil
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil, nil] show];
            return;
        }
        int points_count = 0;
        if ([[responseDict objectForKey:@"routes"] count])
            points_count = [[[[[[responseDict objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"] count];
        
        
        if (!points_count) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Could not route path from your current location"
                                       delegate:nil
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil, nil] show];
            return;
        }
        CLLocationCoordinate2D points[points_count * 3];
        MKPolyline *polyline = [self polylineWithEncodedString:[[[[responseDict objectForKey:@"routes"] objectAtIndex:0]objectForKey:@"overview_polyline"] objectForKey:@"points"]];
        [self.mapView addOverlay:polyline];
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
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    
    overlayView.lineWidth = 5;
    UIColor *color = [UIColor colorWithRed: 87 / 255.0 green: 126 / 255.0 blue: 212 / 255.0 alpha: 1.];
    overlayView.strokeColor = color;
    overlayView.fillColor = [color colorWithAlphaComponent:0.5f];
    return overlayView;
}

#pragma mark - createAnnotation

- (Annotation*)createAnnotationFromData:(DiscountObject*)discountObject
{
    CLLocationCoordinate2D tmpCoord;
    
    // annotation for pins
    Annotation *myAnnotation = [[Annotation alloc]init];
    
    // font for pins image
    UIFont *font = [UIFont fontWithName:@"icons" size:10];
    // image with text
    UIImage *emptyImage =[UIImage imageNamed:@"emptyLeftImage.png"];
    UIImage *emptyPinImage = [UIImage imageNamed:@"emptyPin.png"];
    
    NSNumber *dbLongitude = discountObject.geoLongitude;
    NSNumber *dbLatitude = discountObject.geoLatitude;
    NSString *dbTitle = discountObject.name;
    NSString *dbSubtitle = discountObject.address;
    NSSet *dbCategories = discountObject.categories;
    NSString *dbDiscountTo = [NSString stringWithFormat:@"%@%%", discountObject.discountTo];
    NSString *dbDiscountFrom;
    if(![discountObject.discountTo isEqualToNumber:discountObject.discountFrom])
        dbDiscountFrom = [NSString stringWithFormat:@"%@-", discountObject.discountFrom];
    else
        dbDiscountFrom = [NSString stringWithFormat:@""];

    Category *dbCategory = [dbCategories anyObject];

    // formating discountValue to "x%", where x discountValue
    NSString *discount = [dbDiscountFrom stringByAppendingString:dbDiscountTo];
    
    // creating new image
    UIImage *myNewImage = [self setText:discount
                               withFont: nil
                               andColor:[UIColor blackColor]
                                onImage:emptyImage];
    UIImage *pinImage = [self setText:dbCategory.fontSymbol withFont:font
                             andColor:[UIColor whiteColor] onImage:emptyPinImage];
    
    
    myAnnotation= [[Annotation alloc]init];
    
    tmpCoord.latitude = [dbLatitude doubleValue];
    tmpCoord.longitude =[dbLongitude doubleValue];
    myAnnotation.coordinate = tmpCoord;
    myAnnotation.object = discountObject;
    myAnnotation.title = dbTitle;
    myAnnotation.subtitle = dbSubtitle;
    myAnnotation.pintype = pinImage;
    myAnnotation.leftImage = [[UIImageView alloc] initWithImage: myNewImage];
    return myAnnotation;
}


#pragma mark - Picker section

- (NSArray*)getAllPins
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    // fetch objects from db
    NSPredicate *objectsFind = [NSPredicate predicateWithFormat:nil];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category"
                                 inManagedObjectContext:managedObjectContext]];
    [fetch setPredicate:objectsFind];
    NSArray *objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    
    Annotation *currentAnn = [[Annotation alloc]init];
    for (Category *object1 in objectsFound)
    {
        double scaleX, scaleY, distanceFromObject;
        distanceFromObject = 0.00006;
        scaleX = 0.0;
        scaleY = distanceFromObject;
        
        NSSet *dbAllObjInCategory= object1.discountobject;
        for(DiscountObject *object in dbAllObjInCategory)
        {
            currentAnn = [self createAnnotationFromData:object];
            for(Annotation *ann in tmpArray)
            {
                if((currentAnn.coordinate.latitude - ann.coordinate.latitude) < 0.0001
                    && (currentAnn.coordinate.latitude - ann.coordinate.latitude) > -0.0001
                    && (currentAnn.coordinate.longitude - ann.coordinate.longitude) < 0.0001
                    && (currentAnn.coordinate.longitude - ann.coordinate.longitude) > -0.0001)
                {
                    CLLocationCoordinate2D coord;
                    coord.latitude = currentAnn.coordinate.latitude + scaleX;
                    coord.longitude = currentAnn.coordinate.longitude + scaleY;
                    currentAnn.coordinate = coord;
                }
                scaleX = scaleX + distanceFromObject;
                if(scaleX > distanceFromObject)
                    scaleX = -1 * distanceFromObject;
                scaleY = scaleY + distanceFromObject;
                if(scaleY > distanceFromObject)
                    scaleY = -1 * distanceFromObject;
            }

            if(currentAnn.coordinate.latitude != 0 && currentAnn.coordinate.longitude != 0)
                [tmpArray addObject:currentAnn];
        }
    }
    return tmpArray;
}

- (NSArray*)getPinsByCategory:(int)filterNumber
{
    // fetch objects from db
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    Category *selectedCategory = [self.categoryObjects objectAtIndex:filterNumber];
    NSSet *dbAllObjInSelCategory = selectedCategory.discountobject;
    
    Annotation *currentAnn;
    for(DiscountObject *object in dbAllObjInSelCategory)
    {
        currentAnn = [self createAnnotationFromData:object];
        [tmpArray addObject:currentAnn];
    }
    return  tmpArray;
}

- (NSArray*)fillPicker
{

    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Category"
                              inManagedObjectContext:managedObjectContext]];
    categoryObjects = [managedObjectContext executeFetchRequest:fetch error:nil];
    NSMutableArray *fetchArr = [[NSMutableArray alloc]init];

    [fetchArr addObject:@"Усі категорії"];
    for ( Category *object in categoryObjects)
    {

        [fetchArr addObject:(NSString*)object.name];
    }
    return [NSArray arrayWithArray:fetchArr];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component
{
    return dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [dataSource objectAtIndex:row];
}

#pragma mark - TextOnImage

- (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage
{
    NSString *tmpText = @"";
    CGRect rect = CGRectZero;
    
    double margin = 3.0;
    float fontsize = (startImage.size.width - 2 * margin);

    
    if([font isKindOfClass:[UIFont class]])
    {
        // size of custom text in image
        float ownHeight;
        float ownWidth;
        fontsize = fontsize/3;
        font = [font fontWithSize:fontsize];
        if([startImage isEqual:[UIImage imageNamed:@"cluster"]])
        {
            tmpText = text;

            ownWidth = (0.652 - text.length * 0.08) * startImage.size.width;
            ownHeight = 0.48 * startImage.size.height;
        }
        else
        {
            tmpText = [IconConverter ConvertIconText:text];
            ownWidth = 0.49 * startImage.size.width;
            ownHeight = 0.4 * startImage.size.height;
        }
        rect = CGRectMake(ownWidth - font.pointSize/2, ownHeight - font.pointSize/2, startImage.size.width, startImage.size.height);
    }
    else
    {
        fontsize = text.length > 5 ? 7.5 : 9;
        
        font = [UIFont systemFontOfSize:fontsize];
        font = [UIFont boldSystemFontOfSize:fontsize];
        margin = (startImage.size.width - font.pointSize * text.length/1.85)/2;
        rect = CGRectMake(margin, (startImage.size.height - font.pointSize)/2, startImage.size.width, startImage.size.height);
        tmpText = text;
    }
    
    //work with image
    UIGraphicsBeginImageContextWithOptions(startImage.size,NO, 0.0);
    
    [startImage drawInRect:CGRectMake(0,0,startImage.size.width,startImage.size.height)];
    [color set];
    
    //draw text on image and save result
    [tmpText drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
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
        annotationView.image = [self setText:text withFont:font andColor:[UIColor whiteColor] onImage: image];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if (calloutView.window)
        [calloutView dismissCalloutAnimated];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self getDirections];
    
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
            self.selectedObject = selectedAnnotation.object;

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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = self.selectedObject;
    dvc.managedObjectContext = self.managedObjectContext;
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
    NSString *city = [userDefaults objectForKey:@"cityName"];
    if(!city)
    {
        city = @"Львів";
    }

    //for offline maps
    NSDictionary *cityCoords = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSValue valueWithCGPoint:CGPointMake(48.467003,35.036259)], @"Дніпропетровськ",
    [NSValue valueWithCGPoint:CGPointMake(48.917222,24.707222)], @"Івано-Франківськ",
    [NSValue valueWithCGPoint:CGPointMake(50.450100,30.523400)], @"Київ",
    [NSValue valueWithCGPoint:CGPointMake(50.748716,25.330406)], @"Луцьк",
    [NSValue valueWithCGPoint:CGPointMake(49.839826,24.028675)], @"Львів",
    [NSValue valueWithCGPoint:CGPointMake(46.471767,30.719800)], @"Одеса",
    [NSValue valueWithCGPoint:CGPointMake(50.628999,26.246517)], @"Рівне",
    [NSValue valueWithCGPoint:CGPointMake(44.953212,34.101952)], @"Сімферополь",
    [NSValue valueWithCGPoint:CGPointMake(48.287171,25.957920)], @"Чернівці",
    nil];
    
    CLLocationCoordinate2D coordinate;
    CGPoint tmpPoint = [[cityCoords objectForKey:city] CGPointValue];
    coordinate.latitude = tmpPoint.x;
    coordinate.longitude = tmpPoint.y;
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = coordinate.latitude;
    newRegion.center.longitude = coordinate.longitude;
    newRegion.span.latitudeDelta = MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = MAP_SPAN_DELTA;
    [self.mapView setRegion:newRegion animated:YES];
}

- (IBAction) getLocation:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"] boolValue];
    if(geoLocationIsON)
    {
        if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied)
        {
            if(self.mapView.showsUserLocation)
            {
                self.mapView.showsUserLocation = FALSE;
                [location stopUpdatingLocation];
            }
            else
            {
                self.mapView.showsUserLocation = TRUE;
                if(!self.location)
                {
                    self.location = [[CLLocationManager alloc]init];
                    location.delegate = self;
                }
                location.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                location.distanceFilter = kCLDistanceFilterNone;
                [location startUpdatingLocation];
            }
        }
        else
        {
            [self gotoLocation];
        }
    }
    else
    {
        [self gotoLocation];
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

#pragma mark - filter 

- (IBAction)filterCategory:(UIControl *)sender
{
    if(self.pickerView.isHidden){
        self.pickerView.hidden=FALSE;}
    else{
        self.pickerView.hidden=TRUE;
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.pickerView selectRow:row inComponent:component animated:YES];
    if(row ==0)
        self.annArray = [[self getAllPins] mutableCopy];
    else
        self.annArray = [[self getPinsByCategory:row-1] mutableCopy];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annArray];
}



- (void)categoryWasSelected:(NSNumber *)selectIndex element:(id)element {
    
    if(selectedIndex != [selectIndex integerValue])
    {
        self.selectedIndex = [selectIndex integerValue];
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        if (self.selectedIndex<1)
            self.annArray = [[self getAllPins] mutableCopy];
        else
            self.annArray = [[self getPinsByCategory:self.selectedIndex - 1] mutableCopy];
        [self.mapView addAnnotations:self.annArray];
    }
}

@end
