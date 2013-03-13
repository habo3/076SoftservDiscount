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
#import "IconConverter.h"

@interface FavoritesViewController (){
    int numberOfRowClicked;
}
@property (strong, nonatomic) NSArray *favoriteObjects;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@end

@implementation FavoritesViewController

@synthesize managedObjectContext;
@synthesize favoriteObjects;
@synthesize currentLocation;
@synthesize geoLocationIsON;

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    if(geoLocationIsON)
    {
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
    }
    else
    {
        UIImageView *distanceBackround = (UIImageView*)[cell viewWithTag:10];
        distanceBackround.hidden = YES;
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:3];
        distanceLabel.hidden =YES;
    }
    
    //set category icon
    Category *dbCategory = [object.categories anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *tmpText = [IconConverter ConvertIconText:symbol];
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

    //remove text from "Back" button
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue];
    
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
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
    if (!favoriteObjects.count) {
        self.tableView.backgroundView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"noFavorites"]];
    }
    [self.tableView reloadData];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
