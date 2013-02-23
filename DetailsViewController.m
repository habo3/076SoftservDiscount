//
//  DetailsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 19.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"


@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *distanceToObject;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *webSite;
@property (weak, nonatomic) IBOutlet UIView *zeroCellBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;


+(void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius;

@end

@implementation DetailsViewController

@synthesize discountObject;
@synthesize managedObjectContext;

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
    NSLog(@"inFav:%@", discountObject.inFavorites);
    if ([discountObject.inFavorites isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self.favoritesButton setBackgroundImage:[UIImage imageNamed:@"favoritesButtonHighlited.png"] forState:UIControlStateNormal];
    }
    
    [DetailsViewController roundView:self.zeroCellBackgroundView onCorner:UIRectCornerTopRight|UIRectCornerTopLeft radius:5.0];

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
        self.distanceToObject.text = [NSString stringWithFormat:@"%.0fкм",distance/1000];
    }
    else {
        self.distanceToObject.text = [NSString stringWithFormat:@"%fм",distance];
    }
    
        

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
    [super viewDidUnload];
}
@end