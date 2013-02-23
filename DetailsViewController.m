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


+(void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius;

@end

@implementation DetailsViewController
@synthesize pintype;
@synthesize discountObject;
@synthesize managedObjectContext;
@synthesize mapView;

+(void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius

{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:rectCorner
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    [view.layer setMask:maskLayer];
}

- (void)viewDidLoad
{
 
    [super viewDidLoad];    
    //NSLog(@"inFav:%@", discountObject.inFavorites);
    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    }
    
    // set mapview delegate and annotation for display
    self.mapView.delegate = self;
    Annotation *myAnn = [[Annotation alloc]init];
    CLLocationCoordinate2D tmpCoord;
    tmpCoord.longitude = [discountObject.geoLongitude doubleValue];
    tmpCoord.latitude = [discountObject.geoLatitude doubleValue];
    myAnn.coordinate = tmpCoord;
    myAnn.pintype = self.pintype;
    [self.mapView addAnnotation:myAnn];
    
    //set display region
    MKCoordinateRegion newRegion;
    newRegion.center = tmpCoord;
    newRegion.span.latitudeDelta = DETAIL_MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = DETAIL_MAP_SPAN_DELTA;
    [self.mapView setRegion:newRegion];
    
    [DetailsViewController roundView:self.zeroCellBackgroundView onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];
    [DetailsViewController roundView:self.zeroCellGrayBackgound onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];

    //set labels value
    NSSet *categories = discountObject.categories;
    NSManagedObject *category = [categories anyObject];
    NSString *categoryName = [category valueForKey:@"name"];
    //NSLog(@"object name: %@ object category: %@", discountObject.name, categoryName);
    
    self.discount.text = [NSString stringWithFormat:@"%@%%",[discountObject.discountTo stringValue]];
    self.name.text = discountObject.name;
    self.category.text = categoryName;
    self.distanceToObject.text = @"...";
    self.address.text = discountObject.address;
    NSSet *contacts = discountObject.contacts;
    for (NSManagedObject *contact in contacts) {
        NSString * type = [contact valueForKey:@"type"];
        if ([type isEqualToString:@"phone"]) {
            self.phone.text = [contact valueForKey:@"value"];
        }
        else if ([type isEqualToString:@"email"]){
            self.email.text = [contact valueForKey:@"value"];
        }
        else if ([type isEqualToString:@"site"]){
            self.webSite.text = [contact valueForKey:@"value"];
        }
    
    }

    //set location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; 
    [locationManager startUpdatingLocation];

}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Annotation class]])   // for Annotation
    {
        // type cast for property use
        Annotation *newAnnotation;
        newAnnotation = (Annotation *)annotation;
        static NSString *annotationIdentifier = @"ImagePinIdentifier";
        
        MKAnnotationView *annotationView = (MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        //setting pin image
        annotationView.image = newAnnotation.pintype;
        return annotationView;
    }
    return nil;
}

- (IBAction)favoriteButton {
    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        //NSLog(@"inFav:%@", discountObject.inFavorites);
        discountObject.inFavorites = [NSNumber numberWithBool:NO];
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButton.png"] forState:UIControlStateNormal];
    }
    else if (([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:NO]])|| (!discountObject.inFavorites)) {
        //NSLog(@"inFav:%@", discountObject.inFavorites);
        discountObject.inFavorites = [NSNumber numberWithBool:YES];
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];

    }
    //NSLog(@"inFav:%@", discountObject.inFavorites);
    //NSLog(@"------");
    
    NSError* err;
    if (![self.managedObjectContext save:&err]) {
        NSLog(@"Couldn't save: %@", [err localizedDescription]);
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[discountObject.geoLatitude doubleValue] longitude:[discountObject.geoLongitude doubleValue]];
    double distance = [currentLocation distanceFromLocation:objectLocation];
    if (distance > 999){
        self.distanceToObject.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
    }
    else {
        self.distanceToObject.text = [NSString stringWithFormat:@"%dм",(int)distance];
    }
    
        

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://publish/profile/me?text=hello%20world"]];
    
    } else if(buttonIndex == 1) {
        NSString *stringURL = @"twitter://post?message=hello%20world";
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    
    } else if (buttonIndex ==2) {
        NSString *recipients = @"mailto:first@example.com&subject=Ділюсь!";
        NSString *body = @"&body=Test!";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }
}

- (IBAction)shareAction {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark - Table view data source


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
    [super viewDidUnload];
}
@end
