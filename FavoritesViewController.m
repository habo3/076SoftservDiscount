//
//  FavoritesViewController.m
//  SoftServeDP
//
//  Created by Andrew Gavrish on 23.02.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//


#import "FavoritesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"
#import "AppDelegate.h"
#import "PlaceCell.h"
#import "CDDiscountObject.h"
#import "CDFavorites.h"
#import "CDCoreDataManager.h"
#import "Sortings.h"
#import "CustomViewMaker.h"
#import "JPJsonParser.h"
#import "NSOperationQueue+SharedQueue.h"
#import "DownloadOperation.h"

@interface FavoritesViewController ()

@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation FavoritesViewController

@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize selectedRow;

@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;

#pragma mark - General

-(void)viewDidLoad
{
    [CustomViewMaker customNavigationBarForView:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Sending event to analytics service
    [Flurry logEvent:@"FavoritesViewLoaded"];
    
    self.discountObjects = [[self.coreDataManager discountObjectsFromFavorites] copy];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"] boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
        [self reloadTableWithDistancesValues];
    }
    else
        self.discountObjects = [Sortings sortDiscountObjectByName:self.discountObjects];
    if (!self.discountObjects.count)
        self.tableView.backgroundView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"noFavorites"]];
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self downloadFavorites];
    });

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

#pragma mark - tableView

- (void) reloadTableWithDistancesValues
{
    self.discountObjects = [Sortings sortDiscountObjectByDistance:self.discountObjects toLocation:currentLocation];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discountObjects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"detailsFavorites" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"Cell";
    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }

    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
}


#pragma mark - Location Manager

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


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
}

#pragma mark - Favorites Update
-(BOOL)isTimeToUpdate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *currentDate = [[NSDate alloc] init];
    int lastUpdate = [currentDate timeIntervalSince1970];
    
    if (  (lastUpdate - [[userDefaults valueForKey:@"favoritesLastUpdate"] integerValue]) >= 600 ) {
        return YES;
    }
    return NO;
}

-(void)downloadFavorites
{
    if ([[FBSession activeSession] accessToken] && ([self isTimeToUpdate] || ![self.discountObjects count]) )
    {
        [self putActivity];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *url = [NSString stringWithFormat:@"http://softserve.ua/discount/api/v1/user/favorites/b1d6f099e1b5913e86f0a9bb9fbc10e5?id=%@",[JPJsonParser getUserIDFromFacebook]];
        DownloadOperation *downloadFavorites = [[DownloadOperation alloc] init];
        [downloadFavorites performOperationWithURL:url completion:^{
            if ([downloadFavorites.downloader.parsedData count] && downloadFavorites.downloader.parsedData)
            {
                [self.coreDataManager deleteAllFavorites];
                [self.coreDataManager addDiscountObjectToFavoritesWithDictionaryObjects:downloadFavorites.downloader.parsedData];
                NSDate *currentDate = [[NSDate alloc] init];
                int lastUpdate = [currentDate timeIntervalSince1970];
                [userDefaults setValue:[NSNumber numberWithInt:lastUpdate] forKey:@"favoritesLastUpdate"];
            }
        }];
        [[NSOperationQueue sharedOperationQueue] addOperation:downloadFavorites];
        
        NSBlockOperation *blockOperation2 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.spinner.hidden = YES;
                [self.spinner removeFromSuperview];
                self.discountObjects = [self.coreDataManager discountObjectsFromFavorites];
                if (self.discountObjects.count)
                    self.tableView.backgroundView = nil;
                self.discountObjects = [Sortings sortDiscountObjectByName:self.discountObjects];
                [self.tableView reloadData];
            });
            
            [userDefaults setValue:@YES forKey:@"isFavoritesDownloaded"];
        }];
        [blockOperation2 addDependency:downloadFavorites];
        [[NSOperationQueue sharedOperationQueue] addOperation:blockOperation2];
    }
}

-(void)putActivity
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinner setFrame:CGRectMake((self.navigationController.navigationBar.frame.size.width)-(self.spinner.frame.size.width) - 25, (self.navigationController.navigationBar.frame.size.height/2)-(self.spinner.frame.size.height/2), self.spinner.frame.size.width, self.spinner.frame.size.height)];
    [self.spinner startAnimating];
    
    [self.navigationController.navigationBar addSubview:self.spinner];
    
}

@end