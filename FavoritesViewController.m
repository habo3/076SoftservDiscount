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

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 10;


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
    numberOfRowClicked = indexPath.row;
    [self performSegueWithIdentifier:@"gotoDetailsFromFavorites" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [favoriteObjects objectAtIndex:numberOfRowClicked];
    dvc.managedObjectContext = self.managedObjectContext;

    //remove text from "Back" button (c)Bogdan
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil] ;
}

-(void) reloadTableWithDistancesValues {

    self.favoriteObjects = [FavoritesViewController sortByDistance:favoriteObjects toLocation:currentLocation];
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    [locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    [self reloadTableWithDistancesValues];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [locationManager stopUpdatingLocation];
    self.currentLocation = [locations objectAtIndex:0];
    [self reloadTableWithDistancesValues];
}


+(NSArray *)sortByDistance: (NSArray *)array toLocation: (CLLocation *)location {
    NSMutableArray *mutableArray = [array mutableCopy];
        NSArray *OrderedObjectsByDistance = [mutableArray sortedArrayUsingComparator:^(id a,id b) {
        DiscountObject *objectA = (DiscountObject *)a;
        DiscountObject *objectB = (DiscountObject *)b;
        
        CGFloat aLatitude = objectA.geoLatitude.floatValue;
        CGFloat aLongitude = objectA.geoLongitude.floatValue;
        CLLocation *objectALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        CGFloat bLatitude = objectB.geoLatitude.floatValue;
        CGFloat bLongitude = objectB.geoLongitude.floatValue;
        CLLocation *objectBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
            
        CLLocationDistance distanceA = [objectALocation distanceFromLocation:location];
        CLLocationDistance distanceB = [objectBLocation distanceFromLocation:location];
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
    
    //get favorite objects
    favoriteObjects = [[NSArray alloc] init];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    NSPredicate *findObjectWithFav = [NSPredicate predicateWithFormat:@"inFavorites = %@",[NSNumber numberWithBool:YES]];
    [fetch setPredicate:findObjectWithFav];
    NSError *err;
    favoriteObjects = [managedObjectContext executeFetchRequest:fetch error:&err];
    [locationManager startUpdatingLocation];
    if (!favoriteObjects.count) {
        self.tableView.backgroundView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"noFavorites"]];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
