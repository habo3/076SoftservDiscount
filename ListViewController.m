//
//  ViewController.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import "ListViewController.h"
#import "PlaceCell.h"
#import "DetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CDCoreDataManager.h"
#import "CDDiscountObject.h"
#import "CDCategory.h"
#import "CDCity.h"
#import <UIKit/UIKit.h>
#import "ActionSheetStringPicker.h"
#import "Sortings.h"
#import "CustomViewMaker.h"

@interface ListViewController ()

@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@property (nonatomic) NSInteger selectedIndex;
@property(nonatomic, copy) NSString *currentSearchString;
@property (nonatomic, copy) NSArray *tempObjects;
@property (nonatomic, copy) NSArray *filteredObjects;
@property (nonatomic)CDCity* currentCity;
@property (strong, nonatomic) IBOutlet UITableView *searchBar;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;


@end

@implementation ListViewController
@synthesize filterButton;
@synthesize selectedRow;
@synthesize currentLocation;
@synthesize geoLocationIsON;
@synthesize discountObjects = _discountObjects;
@synthesize coreDataManager = _coreDataManager;
@synthesize selectedIndex = _selectedIndex;
@synthesize searchBar = _searchBar;

#pragma mark - General

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CustomViewMaker customNavigationBarForView:self];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = ([[userDefaults objectForKey:@"geoLocation"] boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
    if(geoLocationIsON)
    {
        self.discountObjects=[self.currentCity.discountObjects allObjects];
    }
    else
    {self.discountObjects = [self.coreDataManager discountObjectsFromCoreData];
    }
    [self initFilterButton];
    _tempObjects = _discountObjects;
    [self.strongSearchDisplayController displaysSearchBarInNavigationBar];
}



-(void)viewWillAppear:(BOOL)animated
{
    //Sending event to analytics service
    [Flurry logEvent:@"ListViewLoaded"];
    
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
    {
        self.discountObjects = [Sortings sortDiscountObjectByName:self.discountObjects];
        [self.tableView reloadData];
    }
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:filterButton];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [filterButton removeFromSuperview];
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

- (NSArray*)getAllObjects
{
    return [self.coreDataManager discountObjectsFromCoreData];
}

- (NSSet *)getObjectsByCategory:(NSInteger)filterNumber
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    return [[categories objectAtIndex:filterNumber] valueForKey:@"discountObjects"];
}

-(CDCity *)currentCity
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *city = [userDefaults objectForKey:@"cityName"];
    NSArray *allcities=[self.coreDataManager citiesFromCoreData];
    CDCity *myCity;
    
    for(NSUInteger i=0;i<allcities.count;i++)
    {
        
        if( [city isEqualToString:[[allcities objectAtIndex:i] name]])
            myCity=[allcities objectAtIndex:i] ;
    }
    return myCity;
}

#pragma mark - filter

- (void) initFilterButton
{
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height );
    
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    filterButton.frame = filterFrame;
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
}

-(void) filterButtonClicked:(UIControl *)sender{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    NSString *categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",@"Усі категорії", [self getAllObjects].count];
    NSMutableArray *names = [[NSMutableArray alloc] initWithObjects:categoryNameWithDetails, nil];
    for (CDCategory *category in categories) {
        categoryNameWithDetails = [NSString stringWithFormat:@"%@ \t % i",category.name, [[category valueForKey:@"discountObjects"] allObjects].count];
        [names addObject:categoryNameWithDetails];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:names initialSelection:self.selectedIndex target:self successAction:@selector(categoryWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (void)categoryWasSelected:(NSNumber *)selectedIndex element:(id)element {
    if(self.selectedIndex != [selectedIndex integerValue])
    {
        self.selectedIndex = [selectedIndex integerValue];
        if(self.selectedIndex == 0)
            self.discountObjects = [self getAllObjects];
        else
            self.discountObjects = [[self getObjectsByCategory:self.selectedIndex - 1] allObjects];
        [self.tableView reloadData];
    }
}

- (void) reloadTableWithDistancesValues
{
    self.discountObjects = [Sortings sortDiscountObjectByDistance:self.discountObjects toLocation:currentLocation];
    [self.tableView reloadData];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discountObjects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"detailsList" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifer = @"Cell";
    CDDiscountObject * object = [self.discountObjects objectAtIndex:indexPath.row];
    PlaceCell *cell = [[PlaceCell alloc] initPlaceCellWithTable:tableView withIdentifer:cellIdentifer];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        cell.nameLabel.text =  object.name;
        cell.addressLabel.text = object.address;
        [cell initViews];
        [cell setImageinCellFromObject:object];
        [cell setDistanceLabelFromDiscountObject:object WithCurrentLocation:currentLocation];
        NSLog(@"%@",cell.backgroundColor);
        return cell;
    }
    return [cell customCellFromDiscountObject:object WithTableView:tableView WithCurrentLocation:self.currentLocation];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - searching

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _discountObjects = _tempObjects;
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _discountObjects = _tempObjects;
    [self.tableView reloadData];
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [controller setSearchResultsDelegate:[self.tableView delegate]];
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) { // Should always be the case
        NSArray *objectsToSearch = _tempObjects;
        NSLog(@"count %lu", (unsigned long)objectsToSearch.count);
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0) { // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            objectsToSearch = _discountObjects;
        }
        _discountObjects = [objectsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
        NSLog(@"count %lu", (unsigned long)objectsToSearch.count);
    } else {
        _discountObjects = _tempObjects;
    }
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithRed:0.877986 green:0.87686 blue:0.911683 alpha:1]];
    [controller.searchResultsTableView setSeparatorColor:[UIColor colorWithRed:0.877986 green:0.87686 blue:0.911683 alpha:1]];
    self.currentSearchString = searchString;
    return YES;
}


#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    [self reloadTableWithDistancesValues];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    self.currentLocation = [locations objectAtIndex:0];
    [self reloadTableWithDistancesValues];
}

#pragma mark - seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
@end