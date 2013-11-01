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
#import "AppDelegate.h"
#import "IconConverter.h"
#import "PlaceCell.h"
#import "CDDiscountObject.h"
#import "CDFavorites.h"
#import "CDCoreDataManager.h"

#define CELL_HEIGHT 80.0

@interface FavoritesViewController (){
    int numberOfRowClicked;
}
@property (strong, nonatomic) NSArray *favoriteObjects;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@end

@implementation FavoritesViewController

@synthesize managedObjectContext;
@synthesize favoriteObjects;
@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize selectedRow;


@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;

-(CDCoreDataManager *)coreDataManager
{
    return [(AppDelegate*) [[UIApplication sharedApplication] delegate] coreDataManager];
}

-(NSArray *)discountObjects
{
    return [self.coreDataManager discountObjectsFromFavorites];
}

-(void)viewDidLoad
{
    [self setNavigationTitle];
}

-(void)viewWillAppear:(BOOL)animated{
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    [super viewWillAppear:animated];
    
    //Sending event to analytics service
    [Flurry logEvent:@"FavoritesViewLoaded"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
    
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
    }
    else
    {
        self.favoriteObjects = [FavoritesViewController sortByName:favoriteObjects];
        [self.tableView reloadData];
    }
    //get favorite objects from DB
    favoriteObjects = [[NSArray alloc] init];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    NSPredicate *findObjectWithFav = [NSPredicate predicateWithFormat:@"inFavorites = %@",[NSNumber numberWithBool:YES]];
    [fetch setPredicate:findObjectWithFav];
    NSError *err;
    favoriteObjects = [managedObjectContext executeFetchRequest:fetch error:&err];  
    
    //set backgound image if no Favorites available
    if (!self.discountObjects.count) {
        self.tableView.backgroundView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"noFavorites"]];
    }
    [self.tableView reloadData];
    
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

- (void)viewDidUnload {
    [super viewDidUnload];
}

//#pragma mark - Table view data source
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.discountObjects.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
////    
////    NSString *cellIdentifer = @"FavoritesCell";
////    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
////    if (cell == nil) {
////        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
////    }
////    // Init style of rrectangleView and circleView
////    [cell initViews];
////    //here forms search object
////    CDDiscountObject * object =[self.discountObjects objectAtIndex:indexPath.row];
////    
////    //set labels
////    cell.nameLabel.text = object.name;
////    cell.addressLabel.text = object.address;
/////*
////    //set location label if GPS available
////    if(geoLocationIsON)
////    {
////            CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[object.geoLatitude doubleValue]
////                                                                    longitude:[object.geoLongitude doubleValue]];
////            double distance = [self.currentLocation distanceFromLocation:objectLocation];
////            if (distance > 999){
////                cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
////            }
////            else {
////                cell.distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
////            }
////    }
////    else
////    {
////        cell.detailsDistanceBackground.hidden = YES;
////        cell.distanceLabel.hidden =YES;
////    }
//// */
////   return cell;
//    
//    NSString *cellIdentifer = @"Cell";
//    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
//    PlaceCell *cell = [[PlaceCell alloc] initPlaceCellWithTable:tableView withIdentifer:cellIdentifer];
//    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
//}

#pragma mark - tableView

-(void) reloadTableWithDistancesValues {
    NSMutableArray *mutableArray = [_discountObjects mutableCopy];
    NSArray *OrderedObjectsByDistance = [mutableArray sortedArrayUsingComparator:^(id a,id b) {
        CDDiscountObject *objectA = (CDDiscountObject *)a;
        CDDiscountObject *objectB = (CDDiscountObject *)b;
        
        CGFloat aLatitude = [[objectA.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat aLongitude = [[objectA.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        
        CGFloat bLatitude = [[objectB.geoPoint valueForKey:@"latitude"] floatValue];
        CGFloat bLongitude = [[objectB.geoPoint valueForKey:@"longitude"] floatValue];
        CLLocation *objectBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
        
        CLLocationDistance distanceA = [objectALocation distanceFromLocation:currentLocation];
        CLLocationDistance distanceB = [objectBLocation distanceFromLocation:currentLocation];
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    _discountObjects = OrderedObjectsByDistance;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discountObjects count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  CELL_HEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"detailsList" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"Cell";
    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
    PlaceCell *cell = [[PlaceCell alloc] initPlaceCellWithTable:tableView withIdentifer:cellIdentifer];
    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
}


#pragma mark - Table view delegate


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

+(NSArray *)sortByName: (NSArray *)array
{
    NSMutableArray *myMutableArray = [array mutableCopy];
    NSMutableCharacterSet *trimChars = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [trimChars addCharactersInString:@"\"\'"];
    [myMutableArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DiscountObject *d1 = obj1;
        DiscountObject *d2 = obj2;
        NSString *trimmedName1 = [d1.name stringByTrimmingCharactersInSet:trimChars];
        NSString *trimmedName2 = [d2.name stringByTrimmingCharactersInSet:trimChars];
        return [trimmedName1 compare:trimmedName2];
    }];
    return myMutableArray;
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

@end
