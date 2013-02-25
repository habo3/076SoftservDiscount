//
//  FavoritesViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 23.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import "FavoritesViewController.h"
#import "DiscountObject.h"
#import <QuartzCore/QuartzCore.h>
#import "Category.h"
#import "DetailsViewController.h"

@interface FavoritesViewController (){
    int numberOfRowClicked;
}
@property (strong, nonatomic) NSArray *favoriteObjects;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation FavoritesViewController

@synthesize managedObjectContext;
@synthesize favoriteObjects;
@synthesize currentLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];

    favoriteObjects = [[NSArray alloc] init];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    NSPredicate *findObjectWithFav = [NSPredicate predicateWithFormat:@"inFavorites = %@",[NSNumber numberWithBool:YES]];
    [fetch setPredicate:findObjectWithFav];
    NSError *err;
    favoriteObjects = [managedObjectContext executeFetchRequest:fetch error:&err];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return favoriteObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"element";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    DiscountObject * object =[favoriteObjects objectAtIndex:indexPath.row];
    
    //set labels
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = object.name;
    UILabel *adressLabel = (UILabel *)[cell viewWithTag:2];
    adressLabel.text = object.address;
    //set location label if GPS available
    if (self.currentLocation) {
        
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:3];
        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[object.geoLatitude doubleValue]
                                                                longitude:[object.geoLongitude doubleValue]];
        double distance = [self.currentLocation distanceFromLocation:objectLocation];
        if (distance > 999){
            distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
        }
        else {
            distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
        }
    }
    
    //set gray borders
    UIView *circleView = [cell viewWithTag:4];
    circleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UIView *roundRectView = [cell viewWithTag:5];
    roundRectView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //set category icon
    Category *dbCategory = [object.categories anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *cuttedSymbol = [symbol stringByReplacingOccurrencesOfString:@"&#" withString:@"0"];
    UTF32Char myChar = 0;
    NSScanner *myConvert = [NSScanner scannerWithString:cuttedSymbol];
    [myConvert scanHexInt:(unsigned int *)&myChar];
    NSData *utf32Data = [NSData dataWithBytes:&myChar length:sizeof(myChar)];
    NSString *tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
    UIFont *fontTest = [UIFont fontWithName:@"icons" size:21];
    UILabel *categoryIcon = (UILabel *)[cell viewWithTag:6];
    categoryIcon.text = tmpText;
    [categoryIcon setFont:fontTest];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    numberOfRowClicked = indexPath.row;
    [self performSegueWithIdentifier:@"gotoDetailsFromFavorites" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [favoriteObjects objectAtIndex:0];//[favoriteObjects objectAtIndex:numberOfRowClicked];
    dvc.managedObjectContext = self.managedObjectContext;

    //remove text from "Back" button (c)Bogdan
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil] ;
}

-(void) reloadTableWithDistancesValues {
    NSArray *testArray = [[NSArray alloc] init];
    testArray = [self sortByDistance:favoriteObjects toLocation:currentLocation];
    self.favoriteObjects = testArray;
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;    
    [locationManager stopUpdatingLocation];
    [self reloadTableWithDistancesValues];
}

-(NSArray *)sortByDistance: (NSArray *)array toLocation: (CLLocation *)location {
    NSMutableArray *mutableArray = [array mutableCopy];
        NSArray *OrderedObjectsByDistance = [mutableArray sortedArrayUsingComparator:^(id a,id b) {
        DiscountObject *userA = (DiscountObject *)a;
        DiscountObject *userB = (DiscountObject *)b;
        
        CGFloat aLatitude = [userA.geoLatitude floatValue];
        CGFloat aLongitude = [userA.geoLongitude floatValue];
        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        CGFloat bLatitude = [userB.geoLatitude floatValue];
        CGFloat bLongitude = [userB.geoLongitude floatValue];
        CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
        
//        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:locationCoordinates.latitude longitude:locationCoordinates.longitude];
        
        CLLocationDistance distanceA = [participantALocation distanceFromLocation:location];
        CLLocationDistance distanceB = [participantBLocation distanceFromLocation:location];
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return OrderedObjectsByDistance;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
