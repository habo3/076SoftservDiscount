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

+(void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius{
    
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

    // Highlight button if partner is in Favorites
    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    }
    
    for (UIView *v in [self.mapView subviews]) {
        if ([NSStringFromClass([v class]) isEqualToString:@"MKAttributionLabel"]) {
            v.hidden = YES;
        }
    }
    
    // set mapview delegate and annotation for display
    self.mapView.delegate = self;
    Annotation *myAnn = [[Annotation alloc]init];
    CLLocationCoordinate2D tmpCoord;
    tmpCoord.longitude = [discountObject.geoLongitude doubleValue];
    tmpCoord.latitude = [discountObject.geoLatitude doubleValue];
    myAnn.coordinate = tmpCoord;
    self.pintype = [self makePin];
    myAnn.pintype = self.pintype;
    [self.mapView addAnnotation:myAnn];
     
    // set display region
    MKCoordinateRegion newRegion;
    newRegion.center = tmpCoord;
    newRegion.span.latitudeDelta = DETAIL_MAP_SPAN_DELTA;
    newRegion.span.longitudeDelta = DETAIL_MAP_SPAN_DELTA;
    [self.mapView setRegion:newRegion];
    
    // round upper corners in first cell
    [DetailsViewController roundView:self.zeroCellBackgroundView onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];
    [DetailsViewController roundView:self.zeroCellGrayBackgound onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];

    // set labels value
    NSSet *categories = discountObject.categories;
    Category *category = [categories anyObject];
    NSString *categoryName = category.name;
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

- (UIImage*)makePin
{
    // select category
    NSSet *dbCategories = discountObject.categories;
    Category *dbCategory = [dbCategories anyObject];
    
    // set font
    UIFont *font = [UIFont fontWithName:@"icons" size:10];
    
    // creating new image
    UIImage *pinImage = [self setText:dbCategory.fontSymbol withFont:font
                             andColor:[UIColor whiteColor] onImage:[UIImage imageNamed: @"emptyPin"]];
    return pinImage;
}

- (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage
{
    
    CGRect rect = CGRectZero;
    
    // size of custom text in image
    double margin = 3.0;
    float fontsize = (startImage.size.width - 2 * margin)/3;

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
        NSString *tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
        
        // own const for pin text (height position)
        float ownHeight = 0.4*startImage.size.height;
        
        rect = CGRectMake((startImage.size.width - font.pointSize)/2, ownHeight - font.pointSize/2, startImage.size.width, startImage.size.height);

    
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

- (IBAction)favoriteButton {
    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        discountObject.inFavorites = [NSNumber numberWithBool:NO];
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButton.png"] forState:UIControlStateNormal];
    }
    else if (([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:NO]])|| (!discountObject.inFavorites)) {
        discountObject.inFavorites = [NSNumber numberWithBool:YES];
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    }

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
    CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[discountObject.geoLatitude doubleValue]
                                                            longitude:[discountObject.geoLongitude doubleValue]];
    double distance = [currentLocation distanceFromLocation:objectLocation];
    if (distance > 999){
        self.distanceToObject.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
    }
    else {
        self.distanceToObject.text = [NSString stringWithFormat:@"%dм",(int)distance];
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *objectAddress = discountObject.address;
    NSString *objectName = discountObject.name;
    NSMutableString *shareString = [NSMutableString stringWithFormat:@"Партнер: %@, адреса: %@", objectName, objectAddress];

    NSSet *contacts = discountObject.contacts;
    for (NSManagedObject *contact in contacts) {
        NSString * type = [contact valueForKey:@"type"];
        if ([type isEqualToString:@"phone"]) {
            [shareString appendFormat:@" тел. %@", [contact valueForKey:@"value"]];
        }
        else if ([type isEqualToString:@"email"]){
           [shareString appendFormat:@" email . %@", [contact valueForKey:@"value"]];
        }
        else if ([type isEqualToString:@"site"]){
            [shareString appendFormat:@" site %@", [contact valueForKey:@"value"]];
        }
    }
        
    if(buttonIndex == 0) {
        NSMutableString *faceBookString = [[NSMutableString alloc]initWithString: @"fb://publish/profile/me?text="];
        [faceBookString appendString:shareString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:faceBookString]];
    
    } else if(buttonIndex == 1) {
        NSMutableString *twitterString = [[NSMutableString alloc] initWithString: @"twitter://post?message="];
        [twitterString appendString:shareString];
        NSURL *url = [NSURL URLWithString:twitterString];
        [[UIApplication sharedApplication] openURL:url];
    
    } else if (buttonIndex ==2) {
        NSMutableString *emailString = [[NSMutableString alloc] initWithString: @"mailto:?subject=Ділюсь!&body="];
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
    [super viewDidUnload];
}
@end
