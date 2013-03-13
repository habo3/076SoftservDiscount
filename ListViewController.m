//
//  ViewController.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import "ListViewController.h"
#import "PlaceCell.h"
#import "DiscountObject.h"
#import "Category.h"
#import "DetailsViewController.h"
#import "CustomPicker.h"
#import <QuartzCore/QuartzCore.h>
#import "FavoritesViewController.h"
#import "IconConverter.h"

#define CELL_HEIGHT 80.0

@interface ListViewController ()
{
    NSArray *searchResults;
}

@property (nonatomic) NSArray * objectsFound;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSArray  *categoryObjects;
@property (nonatomic) NSArray *sortedObjects;
@property (nonatomic) BOOL searching;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL geoLocationIsON;
@end

@implementation ListViewController
@synthesize managedObjectContext;
@synthesize dataSource;
@synthesize objectsFound;
@synthesize filterButton;
@synthesize selectedRow;
@synthesize selectedIndex;
@synthesize categoryObjects;
@synthesize currentLocation;
@synthesize sortedObjects;
@synthesize tableView = _tableView;
@synthesize geoLocationIsON;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor colorWithRed:24 green:24 blue:244 alpha:0];
    
    self.tableView.delegate = self;
    
    objectsFound = [self getAllObjects];
    
    NSArray *fetchArr = [self fillPicker];
    
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height );
    
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    filterButton.frame = filterFrame;
    [filterButton setBackgroundImage:filterButtonImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterCategory:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
    
    
    self.dataSource = [NSArray arrayWithArray:fetchArr];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"] boolValue];
    if(geoLocationIsON)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 10;
        [self reloadTableWithDistancesValues];
        [locationManager startUpdatingLocation];
    }
    else
    {
        self.objectsFound = [FavoritesViewController sortByName:objectsFound];
        [self.tableView reloadData];
    }
        
    [self.searchDisplayController.searchBar setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"searchBarBG.png"]]];
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:filterButton];
        
}

#pragma mark - search

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.tableView reloadData];
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{

    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSMutableArray *address = [[NSMutableArray alloc]init];
    for(DiscountObject *object in objectsFound)
    {
        
        if (object.name)
        {
            [names addObject:object.name];
            if (!object.address)
            {
                [address addObject:@""];
            }
            else
            {
                [address addObject:object.address];
            }
        }
        
    }

    NSPredicate *template = [NSPredicate predicateWithFormat:@"name contains[cd] $SEARCH OR address contains[cd]  $SEARCH"];
    NSDictionary *replace = [NSDictionary dictionaryWithObject:self.searchDisplayController.searchBar.text forKey:@"SEARCH"];
    NSPredicate *predicate = [template predicateWithSubstitutionVariables:replace];
    searchResults = [objectsFound filteredArrayUsingPredicate:predicate];
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark - filter

- (IBAction)filterCategory:(UIControl *)sender {
    
    [CustomPicker showPickerWithRows:self.dataSource initialSelection:self.selectedIndex target:self successAction:@selector(categoryWasSelected:element:)];
}

- (void)categoryWasSelected:(NSNumber *)selectIndex element:(id)element {
    
    if(selectedIndex != [selectIndex integerValue])
    {
        self.selectedIndex = [selectIndex integerValue];
        if (self.selectedIndex<1)
            self.objectsFound = [NSArray arrayWithArray: [self getAllObjects]];
        else
        {
            self.objectsFound = [NSArray arrayWithArray: [self getObjectsByCategory:self.selectedIndex-1]];
            
        }
        if(geoLocationIsON)
        {
            [self reloadTableWithDistancesValues];
        }
        else {
            [self.tableView reloadData];  
        }
        
    }
}

- (NSArray*)getAllObjects
{
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];
    
    NSArray *resultArray = [managedObjectContext executeFetchRequest:fetch error:nil];
    return resultArray;
}

- (NSArray*)getObjectsByCategory:(int)filterNumber
{
    // fetch objects from db
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    Category *selectedCategory = [self.categoryObjects objectAtIndex:filterNumber];
    
    for(DiscountObject *object in selectedCategory.discountobject)
    {
            [tmpArray addObject:object];
    }

    return tmpArray;
}

- (NSArray*)fillPicker
{

    NSFetchRequest *fetch1 = [[NSFetchRequest alloc] init];
    [fetch1 setEntity:[NSEntityDescription entityForName:@"Category"
                                  inManagedObjectContext:managedObjectContext]];
    categoryObjects = [managedObjectContext executeFetchRequest:fetch1 error:nil];
    NSMutableArray *fetchArr = [[NSMutableArray alloc]init];

    [fetchArr addObject:@"Усі категорії"];
    for ( Category *object in categoryObjects)
    {
        [fetchArr addObject:(NSString*)object.name];
    }
    return [NSArray arrayWithArray:fetchArr];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [dataSource objectAtIndex:row];
}



#pragma mark - tableView

-(void) reloadTableWithDistancesValues {
    
    self.objectsFound = [FavoritesViewController sortByDistance:objectsFound toLocation:currentLocation];
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        tableView.separatorColor = [UIColor colorWithWhite:0 alpha:0];
        return [searchResults count];
        
    } else {
        return [objectsFound count];
        
    }
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaceCell"
                                              owner:nil
                                            options:nil] objectAtIndex:0];
        
    }
    //here forms search object
    DiscountObject * object;
    

    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        _searching = YES;
        object =[searchResults objectAtIndex:indexPath.row];

    } else {
        _searching = NO;
        object =[objectsFound objectAtIndex:indexPath.row];
    }
  
    cell.nameLabel.text = object.name ;
    cell.addressLabel.text = object.address;
    if (geoLocationIsON)
    {
        cell.detailsDistanceBackground.hidden = NO;
        cell.distanceLabel.text = @"...";
        if (self.currentLocation) {
            
            CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[object.geoLatitude doubleValue]
                                                                    longitude:[object.geoLongitude doubleValue]];
            double distance = [self.currentLocation distanceFromLocation:objectLocation];
            if (distance > 999){
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
            }
            else {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
            }
        }
    }
    else
    {
        cell.detailsDistanceBackground.hidden = YES;
        cell.distanceLabel.hidden = YES;
    }
    cell.circle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.roundRectBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    

    
    UIImage *buttonImage = [UIImage imageNamed:@"disclosureButton"];
    cell.buttonImage.image = buttonImage;
    Category *dbCategory = [object.categories anyObject];
    NSString *symbol = dbCategory.fontSymbol;

    NSString *tmpText = [IconConverter ConvertIconText:symbol];
    UIFont *font = [UIFont fontWithName:@"icons" size:20];
    cell.iconLabel.textColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
    cell.iconLabel.font = font;
    cell.iconLabel.text = tmpText;
    cell.iconLabel.textAlignment = UITextAlignmentCenter;
    
    
    return cell;
}

#pragma mark - location 

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [filterButton removeFromSuperview];
    DetailsViewController *dvc = [segue destinationViewController];
    if( _searching){
        dvc.discountObject = [searchResults objectAtIndex:selectedRow];
    }
    else {
        dvc.discountObject = [objectsFound objectAtIndex:selectedRow];
    }
    dvc.managedObjectContext = self.managedObjectContext;
    
    //remove text from "Back" button (c)Bogdan
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil] ;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


@end