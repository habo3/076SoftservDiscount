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

@interface ListViewController ()
{
    //NSArray *recipes;
    NSArray *searchResults;
}
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterPicker;
@property (nonatomic) NSArray * objectsFound;
//@property(nonatomic) NSArray *objectsFound1;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSArray  *categoryObjects;
@property (nonatomic) BOOL searching;
@end

@implementation ListViewController
@synthesize managedObjectContext;
//@synthesize pickerView;
@synthesize dataSource;
@synthesize objectsFound;
@synthesize filterButton;
@synthesize selectedRow;
@synthesize selectedIndex;
@synthesize categoryObjects;
//@synthesize searching;


@synthesize tableView = _tableView;



/*- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
*/

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    /*$SEARCH OR optionTwo contains[cd]*/
    
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSMutableArray *address = [[NSMutableArray alloc]init];
    for(DiscountObject *object in objectsFound)
    {
        [names addObject:object.name];
        [address addObject:object.address];
        
    }
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@" contains[cd] %@",searchText];
    NSPredicate *template = [NSPredicate predicateWithFormat:@"name contains[cd] $SEARCH OR address contains[cd]  $SEARCH"];
    NSDictionary *replace = [NSDictionary dictionaryWithObject:self.searchDisplayController.searchBar.text forKey:@"SEARCH"];
    NSPredicate *predicate = [template predicateWithSubstitutionVariables:replace];
    //objectsFound
    searchResults = [objectsFound filteredArrayUsingPredicate:predicate];
    /*if(searchResults.count != 0)
        searching = YES;*/
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //searching = YES;
        return [searchResults count];
        
    } else {
        //searching = NO;
        return [objectsFound count];
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaceCell"
                                                     owner:nil
                                                   options:nil] objectAtIndex:0];
    return  cell.frame.size.height;
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    //searching = YES;
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor colorWithRed:24 green:24 blue:244 alpha:0];

    self.tableView.delegate = self;

    objectsFound = [self getAllObjects];
    
    NSArray *fetchArr = [self fillPicker];
    //UIColor *searchBarColor = self.navigationController.navigationBar.backgroundColor;
    //self.searchDisplayController.searchBar.backgroundColor = searchBarColor;//self.navigationController.navigationBar.tintColor
    UIImage *navigationBarBackground = [UIImage imageNamed: @"navigationBar.png"];
    [self.searchDisplayController.searchBar setBackgroundImage:navigationBarBackground];
    
    UIImage *filterButtonImage = [UIImage imageNamed:@"filterButton.png"];
    CGRect filterFrame = CGRectMake(self.navigationController.navigationBar.frame.size.width - filterButtonImage.size.width-5 , self.navigationController.navigationBar.frame.size.height- filterButtonImage.size.height-8, filterButtonImage.size.width,filterButtonImage.size.height );
    //filterButton = [filter createFilterButtonInRect:filterFrame];
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //CGRect filterFrame = rect;
    filterButton.frame = filterFrame;
    [filterButton setBackgroundImage:[UIImage imageNamed:@"filterButton.png"] forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterCategory:) forControlEvents:UIControlEventTouchUpInside];
    filterButton.backgroundColor = [UIColor clearColor];
    
    //return filterButton;
    self.dataSource = [NSArray arrayWithArray:fetchArr];
    
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
    NSSet *dbAllObjInSelCategory = selectedCategory.discountobject;
    
    for(DiscountObject *object in dbAllObjInSelCategory)
    {
        [tmpArray addObject:object];
    }
    return  tmpArray;
}

- (NSArray*)fillPicker
{
    //NSArray *objectsFound = [[NSArray alloc]init];
    NSFetchRequest *fetch1 = [[NSFetchRequest alloc] init];
    [fetch1 setEntity:[NSEntityDescription entityForName:@"Category"
                                  inManagedObjectContext:managedObjectContext]];
    categoryObjects = [managedObjectContext executeFetchRequest:fetch1 error:nil];
    NSMutableArray *fetchArr = [[NSMutableArray alloc]init];
    //NSString *first
    [fetchArr addObject:@"Усі категорії"];
    for ( Category *object in categoryObjects)
    {
        //NSLog(@"name: %@", object1.name);
        [fetchArr addObject:(NSString*)object.name];
    }
    return [NSArray arrayWithArray:fetchArr];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:filterButton];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component
{
    return dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [dataSource objectAtIndex:row];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"detailsList" sender:self];
    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [self.tableView reloadData];
    
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        //cell.nameLabel.text = [searchResults objectAtIndex:indexPath.row];
        /*DiscountObject */object =[searchResults objectAtIndex:indexPath.row];
        cell.nameLabel.text = object.name ;
        cell.addressLabel.text = object.address;
    } else {
        _searching = NO;
        /*DiscountObject */ object =[objectsFound objectAtIndex:indexPath.row];
        cell.nameLabel.text = object.name ;
        cell.addressLabel.text = object.address;
        //cell.nameLabel.text = [objectsFound objectAtIndex:indexPath.row];
    }
    cell.circle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.roundRectBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //DiscountObject * object =[objectsFound objectAtIndex:indexPath.row];
    //cell.nameLabel.text = object.name ;
    //cell.addressLabel.text = object.address;
    UIImage *buttonImage = [UIImage imageNamed:@"disclosureButton"];
    cell.buttonImage.image = buttonImage;
    Category *dbCategory = [object.categories anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *cuttedSymbol = [symbol stringByReplacingOccurrencesOfString:@"&#" withString:@"0"];
    //for debugging
    //NSLog(@"cutted symbol %@",cuttedSymbol);
    
    //converting Unicode Character String (0xe00b) to UTF32Char
    UTF32Char myChar = 0;
    NSScanner *myConvert = [NSScanner scannerWithString:cuttedSymbol];
    [myConvert scanHexInt:(unsigned int *)&myChar];
    
    //UIImage *startImage = [UIImage imageNamed:@"emptyLeftImage"];

    //set data to string
    NSData *utf32Data = [NSData dataWithBytes:&myChar length:sizeof(myChar)];
    NSString *tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
    UIFont *font = [UIFont fontWithName:@"icons" size:20];
    cell.iconLabel.textColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
    cell.iconLabel.font = font;
    cell.iconLabel.text = tmpText;
    cell.iconLabel.textAlignment = UITextAlignmentCenter;

//    UIGraphicsBeginImageContextWithOptions(startImage.size,NO, 0.0);
//
//    //UIGraphicsBeginImageContext();
//    
//    [startImage drawInRect:CGRectMake(0,0,startImage.size.width,startImage.size.height)];
//    //Position and color
//    CGRect rect = CGRectMake((startImage.size.width - font.pointSize)/2, font.pointSize/2, startImage.size.width, startImage.size.height);
//    UIColor *iconColor = [UIColor greenColor];//colorWithRed:0.9832 green:0.9765 blue:0.698 alpha:1];
//    [iconColor set];
//    
//    //draw text on image and save result
//    [tmpText drawInRect:CGRectIntegral(rect) withFont:font];
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    cell.imageView.image = resultImage;
    //cell.selectedObject = object;
    //}
    
    
    /*cell.addressLabel.text = [NSString stringWithFormat: @"Cell #%i",indexPath.row];*/
    
    
    
    return cell;
}

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
            self.objectsFound = [NSArray arrayWithArray: [self getObjectsByCategory:self.selectedIndex-1]];
        [self.tableView reloadData];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [filterButton removeFromSuperview];
    DetailsViewController *dvc = [segue destinationViewController];
    if( _searching)//_tableView == self.searchDisplayController.searchResultsTableView)
    {
        dvc.discountObject = [searchResults objectAtIndex:selectedRow];
    }
        else {
        dvc.discountObject = [objectsFound objectAtIndex:selectedRow];
    }
    //dvc.pintype = self.selectedPintype;
    dvc.managedObjectContext = self.managedObjectContext;
    
    //remove text from "Back" button (c)Bogdan
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil] ;
    
}
/*
 - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 //selectedRow = indexPath.row;
 //[self performSegueWithIdentifier:@"detailsList" sender:self];
 NSLog(@"Accessory tapped %@", indexPath );
 
 }*/


@end