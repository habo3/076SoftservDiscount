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
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterPicker;
@property (nonatomic) NSArray * objectsFound;
//@property(nonatomic) NSArray *objectsFound1;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSArray  *categoryObjects;
@end

@implementation ListViewController
@synthesize managedObjectContext;
@synthesize pickerView;
@synthesize dataSource;
@synthesize objectsFound;
@synthesize filterButton;
@synthesize selectedRow;
@synthesize selectedIndex;
@synthesize categoryObjects;

//@synthesize objectsFound1;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor colorWithRed:24 green:24 blue:244 alpha:0];

    self.tableView.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
    /*NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
     [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
     inManagedObjectContext:managedObjectContext]];
     */
    objectsFound = [self getAllObjects];
    
    //TheFilter *filter = [TheFilter new];
    NSArray *fetchArr = [self fillPicker];
    

    
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


- (void)viewDidUnload
{
    [self setMyButton:nil];
    [self setMyButton:nil];
    
    //  [self setFilterPicker:nil];
    [super viewDidUnload];
    self.pickerView = nil;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectsFound count];
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
    //for ( DiscountObject *object in objectsFound) {

    cell.circle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.roundRectBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    DiscountObject * object =[objectsFound objectAtIndex:indexPath.row];
    cell.nameLabel.text = object.name ;
    cell.addressLabel.text = object.address;
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
    dvc.discountObject = [objectsFound objectAtIndex:selectedRow];
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