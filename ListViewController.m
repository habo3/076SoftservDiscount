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
#import "PickerView.h"
#import "Category.h"

@interface ListViewController ()
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterPicker;
@property (nonatomic) NSArray * objectsFound;
@property(nonatomic) NSArray *objectsFound1;

@end

@implementation ListViewController
@synthesize managedObjectContext;
@synthesize pickerView;
@synthesize dataSource;
@synthesize objectsFound;
@synthesize objectsFound1;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"DiscountObject"
                                 inManagedObjectContext:managedObjectContext]];

    objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    
    for ( DiscountObject *object in objectsFound) {
        NSLog(@"name: %@ address: %@ latitude: %@ longitude: %@", object.name, object.address, object.geoLatitude, object.geoLongitude);
    
    }

    
    NSFetchRequest *fetch1=[[NSFetchRequest alloc] init];
    [fetch1 setEntity:[NSEntityDescription entityForName:@"Category"
                                 inManagedObjectContext:managedObjectContext]];
    
    objectsFound1 = [managedObjectContext executeFetchRequest:fetch1 error:nil];
    NSMutableArray *fetchArr = [[NSMutableArray alloc]init];

    [fetchArr addObject:@"Усі категорії"];
    for ( Category *object1 in objectsFound1) {
        NSLog(@"name: %@", object1.name);
    
        [fetchArr addObject:(NSString*)object1.name];
    }
    
    self.dataSource = [NSArray arrayWithArray:fetchArr];   

}

- (IBAction)btnShowPickerClick:(id)sender {
    
    
    PickerView *objPickerView = [[PickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) withNSArray:self.dataSource];
    
  //   objPickerView.delegate =self;
    [self.view.superview addSubview:objPickerView];
    [objPickerView showPicker];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaceCell"
                                             owner:nil
                                           options:nil] objectAtIndex:0];
    
    }
    //for ( DiscountObject *object in objectsFound) {
    
    DiscountObject * object =[objectsFound objectAtIndex:indexPath.row];
    cell.nameLabel.text = object.name ;
    cell.addressLabel.text = object.address;
    
    Category *dbCategory = [object.categories anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *cuttedSymbol = [symbol stringByReplacingOccurrencesOfString:@"&#" withString:@"0"];
    //for debugging
    NSLog(@"cutted symbol %@",cuttedSymbol);
    
    //converting Unicode Character String (0xe00b) to UTF32Char
    UTF32Char myChar = 0;
    NSScanner *myConvert = [NSScanner scannerWithString:cuttedSymbol];
    [myConvert scanHexInt:(unsigned int *)&myChar];
    
    UIImage *startImage = [UIImage imageNamed:@"emptyLeftImage"]; 
    //set data to string
    NSData *utf32Data = [NSData dataWithBytes:&myChar length:sizeof(myChar)];
    NSString *tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
    UIGraphicsBeginImageContextWithOptions(startImage.size,NO, 0.0);
    UIFont *font = [UIFont fontWithName:@"icons" size:15];
    //UIGraphicsBeginImageContext();
    
    [startImage drawInRect:CGRectMake(0,0,startImage.size.width,startImage.size.height)];
    //Position and color
    CGRect rect = CGRectMake((startImage.size.width - font.pointSize)/2, font.pointSize/2, startImage.size.width, startImage.size.height);
    UIColor *iconColor = [UIColor greenColor];//colorWithRed:0.9832 green:0.9765 blue:0.698 alpha:1];
    [iconColor set];
    
    //draw text on image and save result
    [tmpText drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = resultImage;
    
    //}
    

    /*cell.addressLabel.text = [NSString stringWithFormat: @"Cell #%i",indexPath.row];*/
    
     

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Accessory tapped %@", indexPath);
}


@end
