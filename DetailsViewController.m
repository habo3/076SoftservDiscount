//
//  DetailsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 19.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"
#import "Annotation.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CDDiscountObject.h"
#import "CDCategory.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "CDCoreDataManager.h"
#import "CustomViewMaker.h"

#define DETAIL_MAP_SPAN_DELTA 0.002

@interface DetailsViewController ()<MKAnnotation,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *distanceToObject;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *webSite;
@property (weak, nonatomic) IBOutlet UIView *zeroCellBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *zeroCellGrayBackgound;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *distanceBackground;
@property (strong, nonatomic) CDCoreDataManager *coreDataManager;

@property (weak, nonatomic) IBOutlet UIImageView *discountImage;

@end

@implementation DetailsViewController
@synthesize coordinate = _coordinate;
@synthesize pintype;
@synthesize mapView;
@synthesize discountObject = _discountObject;
@synthesize discountImage = _discountImage;
@synthesize coreDataManager = _coreDataManager;

#pragma mark - General
- (void)viewDidLoad
{
    [super viewDidLoad];
    [CustomViewMaker customNavigationBarForView:self];
    [self initMapView];    
    // round upper corners in first cell
    [CustomViewMaker roundView:self.zeroCellBackgroundView onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];
    [CustomViewMaker roundView:self.zeroCellGrayBackgound onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];

    // set labels value
    NSString *discountFrom;
    if(![[self.discountObject.discount valueForKey:@"from"]  isEqualToNumber: [self.discountObject.discount valueForKey:@"to"]])
        discountFrom = [NSString stringWithFormat:@"%@-", [self.discountObject.discount valueForKey:@"from"]];
    else
        discountFrom = [NSString stringWithFormat:@""];
    self.discount.text = [NSString stringWithFormat:@"%@%@%%", discountFrom, [[self.discountObject.discount valueForKey:@"to"] stringValue]];
    self.discount.font = [UIFont boldSystemFontOfSize: self.discount.text.length > 5 ? 10.0 : 13.0];
    self.name.text = self.discountObject.name;
    self.category.text = [[self.discountObject.categorys anyObject] valueForKey:@"name"];
    
    NSString *categoriesText = [[NSMutableString alloc] init];
    for (CDCategory *category in self.discountObject.categorys) {
        categoriesText = [categoriesText stringByAppendingFormat:@"%@ ",category.name];
    }
   
    self.category.text = [categoriesText copy];
    
    self.address.text = self.discountObject.address;
    
    if ( !(self.discountObject.phone == nil || [self.discountObject.phone count] == 0 ) ) {
        self.phone.text = [self.discountObject.phone objectAtIndex:0];
    }
    if ( !(self.discountObject.email == nil || [self.discountObject.email count] == 0 ) ) {
        self.email.text = [self.discountObject.email objectAtIndex:0];
    }
    if ( !(self.discountObject.site == nil || [self.discountObject.site count] == 0 ) ) {
        self.webSite.text = [self.discountObject.site objectAtIndex:0];
    }

    [self loadLogo];
    
    [self isObjectInFavoritesButtonController];
}

- (void) viewWillAppear:(BOOL)animated
{
    //Sending event to analytics service
    [Flurry logEvent:@"DetailsViewLoaded"];
    
    self.discountImage.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0].CGColor;
    self.discountImage.layer.borderWidth = 1.0f;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = ([[userDefaults objectForKey:@"geoLocation"] boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        self.distanceToObject.hidden = NO;
        self.distanceBackground.hidden = NO;
    }
    else
    {
        self.distanceToObject.hidden = YES;
        self.distanceBackground.hidden = YES;
    }
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] coreDataManager];
}

#pragma mark - design of view

-(void)loadLogo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), ^{
        NSString *http = @"http://softserve.ua";
        NSString *imageUrl = [http stringByAppendingString:[self.discountObject.logo valueForKey:@"src"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _discountImage.image = image;
        });
    });
    
}

#pragma mark - MapView

- (void) initMapView
{
    self.mapView.delegate = self;
    Annotation *myAnn = [[Annotation alloc]init];
    CLLocationCoordinate2D tmpCoord;
    tmpCoord.longitude = [[self.discountObject.geoPoint valueForKey:@"longitude"] doubleValue];
    tmpCoord.latitude = [[self.discountObject.geoPoint valueForKey:@"latitude"] doubleValue];
    myAnn.coordinate = tmpCoord;
    self.pintype = [self makePin];
    myAnn.pintype = self.pintype;
    
    MKCoordinateRegion newRegion;
    newRegion.center = tmpCoord;
    newRegion.span.latitudeDelta = DETAIL_MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = DETAIL_MAP_SPAN_DELTA;

    [self.mapView addAnnotation:myAnn];
    [self.mapView setRegion:newRegion];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Annotation class]])
    {
        Annotation *newAnnotation;
        newAnnotation = (Annotation *)annotation;
        static NSString *annotationIdentifier = @"ImagePinIdentifier";
        
        MKAnnotationView *annotationView = (MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        annotationView.image = newAnnotation.pintype;
        return annotationView;
    }
    return nil;
}

- (UIImage*)makePin
{
    NSSet *dbCategories = self.discountObject.categorys;
    CDCategory *dbCategory = [dbCategories anyObject];
    UIFont *font = [UIFont fontWithName:@"icons" size:10];    
    UIImage *pinImage = [CustomViewMaker setText:dbCategory.fontSymbol withFont:font
                             andColor:[UIColor whiteColor] onImage:[UIImage imageNamed: @"emptyPin"]];    
    return pinImage;
}

#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:
                                  [[_discountObject.geoPoint valueForKey:@"latitude"]doubleValue]
                                                            longitude:
                                  [[_discountObject.geoPoint valueForKey:@"longitude"]doubleValue]];
    double distance = [currentLocation distanceFromLocation:objectLocation];
    if (distance > 999){
        self.distanceToObject.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
    }
    else {
        self.distanceToObject.text = [NSString stringWithFormat:@"%dм",(int)distance];
    }
}

#pragma mark - favorites and Share
- (IBAction)favoriteButton
{
    //    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
    //        discountObject.inFavorites = [NSNumber numberWithBool:NO];
    //        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButton.png"] forState:UIControlStateNormal];
    //    }
    //    else if (([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:NO]])|| (!discountObject.inFavorites)) {
    //        discountObject.inFavorites = [NSNumber numberWithBool:YES];
    //        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    //    }
    //
    //    NSError* err;
    //    if (![self.managedObjectContext save:&err]) {
    //        NSLog(@"Couldn't save: %@", [err localizedDescription]);
    //    }
    
    
    [self.coreDataManager addDiscountObjectToFavoritesWithObject:self.discountObject];
    
    [self isObjectInFavoritesButtonController];
    
}

-(void)isObjectInFavoritesButtonController
{
    if ([self.discountObject.isInFavorites isEqual:[NSNumber numberWithBool:YES]]) {
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButton.png"] forState:UIControlStateNormal];
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *objectAddress = self.discountObject.address;
    NSString *objectName = self.discountObject.name;
    NSMutableString *shareString = [NSMutableString stringWithFormat:@"Партнер: %@, адреса: %@", objectName, objectAddress];
    
    if ( !(self.discountObject.phone == nil || [self.discountObject.phone count] == 0 ) ) {
        [shareString appendFormat:@" тел. %@", [self.discountObject.phone objectAtIndex:0]];
    }
    if ( !(self.discountObject.email == nil || [self.discountObject.email count] == 0 ) ) {
        [shareString appendFormat:@" email . %@", [self.discountObject.email objectAtIndex:0]];
    }
    if ( !(self.discountObject.site == nil || [self.discountObject.site count] == 0 ) ) {
        [shareString appendFormat:@" site %@", [self.discountObject.site objectAtIndex:0]];
    }
    
    if(buttonIndex == 0) {
        
        SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];    
        

            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [fbController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result){
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled.....");
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Posted....");
                    }
                        break;
                }};
            
            [fbController addImage:[UIImage imageNamed:@"1.jpg"]];
            [fbController setInitialText:@"Check out this article."];
            [fbController addURL:[NSURL URLWithString:@"http://soulwithmobiletechnology.blogspot.com/"]];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];

    } else if(buttonIndex == 1) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheetOBJ setInitialText:@"Learn iOS programming at weblineindia.com!"];
            [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
        }
    } else if (buttonIndex ==2) {
        NSMutableString *emailString = [[NSMutableString alloc] initWithString: @"mailto:?body="];
        //MAIL URL  @"mailto:?subject=TITLE!&body=
        [emailString appendString:shareString];
        NSString *email = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

- (IBAction)shareAction {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - Table view data source

- (void)viewDidUnload {

    [self setDiscount:nil];
    [self setName:nil];
    [self setCategory:nil];
    [self setDistanceToObject:nil];
    [self setAddress:nil];
    [self setPhone:nil];
    [self setEmail:nil];
    [self setWebSite:nil];
    [self setZeroCellBackgroundView:nil];
    [self setFavoritesButton:nil];
    [self setZeroCellGrayBackgound:nil];
    [self setDistanceBackground:nil];
    [super viewDidUnload];
}


@end
