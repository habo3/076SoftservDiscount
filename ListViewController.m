//
//  ViewController.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
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
#import "CDCity.h"

@interface ListViewController ()

@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@property (nonatomic) NSInteger selectedIndex;
@property(nonatomic, copy) NSString *currentSearchString;
@property (nonatomic, copy) NSArray *tempObjects;
@property (nonatomic, copy) NSArray *filteredObjects;
@property (nonatomic)CLLocation* currentCityLocation;
@property (strong, nonatomic) IBOutlet UITableView *searchBar;
@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toTopButton;


@end

@implementation ListViewController
@synthesize toTopButton;
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
    [self initFilterButton];
    self.discountObjects = [self.coreDataManager discountObjectsFromCoreData];
    self.tempObjects = self.discountObjects;
    [self.strongSearchDisplayController displaysSearchBarInNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.coreDataManager checkImageInObjectExistForDiscountObject:self.discountObjects[1]];
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
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        CLLocationCoordinate2D coordinate;
        NSString *city = [userDefaults objectForKey:@"cityName"];
        if(!city)
            city = @"Львів";
        coordinate = [self getCoordinateOfCity:city];
        self.currentCityLocation= [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        self.discountObjects = [Sortings sortDiscountObjectByDistance:self.discountObjects toLocation:self.currentCityLocation];
        [self.tableView reloadData];
    }
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:filterButton];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [self.coreDataManager saveData];
    [filterButton removeFromSuperview];
}

#pragma mark - Working with Location
- (CLLocationCoordinate2D) getCoordinateOfCity:(NSString *) name
{
    NSArray *cities = [self.coreDataManager citiesFromCoreData];
    CLLocationCoordinate2D coordinate;
    for (CDCity *cityObject in cities)
    {
        if([cityObject.name isEqualToString:name])
        {
            coordinate.latitude = [self averageOfTwoPoints:[[[cityObject.bounds valueForKey:@"southWest"] valueForKey:@"latitude"] doubleValue]
                                                          :[[[cityObject.bounds valueForKey:@"northEast"] valueForKey:@"latitude"] doubleValue]];
            coordinate.longitude = [self averageOfTwoPoints:[[[cityObject.bounds valueForKey:@"southWest"] valueForKey:@"longitude"] doubleValue]
                                                           :[[[cityObject.bounds valueForKey:@"northEast"] valueForKey:@"longitude"] doubleValue]];
        }
    }
    return coordinate;
}

- (double) averageOfTwoPoints:(double)firstPoint :(double)secondPoint
{
    return (firstPoint + secondPoint)/2;
}

#pragma mark - CoreData

-(CDCoreDataManager *)coreDataManager
{
    return [CDCoreDataManager sharedInstance];
}

- (NSArray*)getAllObjects
{
    return  [Sortings sortDiscountObjectByDistance:[self.coreDataManager discountObjectsFromCoreData] toLocation:self.currentCityLocation];
    
}

- (NSArray *)getObjectsByCategory:(NSInteger)filterNumber
{
    NSArray *categories = [self.coreDataManager categoriesFromCoreData];
    return [Sortings sortDiscountObjectByDistance:[[categories objectAtIndex:filterNumber] valueForKey:@"discountObjects"] toLocation:self.currentCityLocation];
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
        
        /* REFACTOR, oskryp: please read following https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsController_Class/Reference/Reference.html
         * you need to rewrite UITableView delegate method to use FetchResultsController
         * As a result you will get great performance benefit
         */
        
        if(self.selectedIndex == 0)
            self.discountObjects = [self getAllObjects];
        else
            self.discountObjects = [self getObjectsByCategory:self.selectedIndex - 1];
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
    
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifer];
        cell.nameLabel.text =  object.name;
        cell.addressLabel.text = object.address;
        [cell initViews];
        [cell setImageinCellFromObject:object];
        [cell setDistanceLabelFromDiscountObject:object WithCurrentLocation:currentLocation];
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
    if(searchString.length == 0)
        self.discountObjects = self.tempObjects;
    if (searchString.length > 0)
    {
        NSArray *objectsToSearch = _tempObjects;
        if (self.currentSearchString.length > 0 && [searchString rangeOfString:self.currentSearchString].location == 0)
            objectsToSearch = _discountObjects;
        
        _discountObjects = [objectsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString]];
    } else
        _discountObjects = _tempObjects;
    
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithRed:0.877986 green:0.87686 blue:0.911683 alpha:1]];
    [controller.searchResultsTableView setSeparatorColor:[UIColor colorWithRed:0.877986 green:0.87686 blue:0.911683 alpha:1]];
    self.currentSearchString = searchString;
    return YES;
}

#pragma mark - ReturnToTop

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if (targetContentOffset->y > 3500)
    {
        self.navigationController.toolbarHidden = NO;
    }else{
        self.navigationController.toolbarHidden = YES;
    }
}


- (IBAction)tabBarButtonIsPressed:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    [self.searchDisplayController.searchResultsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    self.currentLocation = newLocation;
    [self reloadTableWithDistancesValues];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    self.currentLocation = [locations objectAtIndex:0];
    [self reloadTableWithDistancesValues];
}

#pragma mark - seque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController *dvc = [segue destinationViewController];
    dvc.discountObject = [self.discountObjects objectAtIndex:selectedRow];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
@end