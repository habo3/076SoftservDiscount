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
    //[fetch setPredicate:objectsFind];
    /*NSArray */
    objectsFound = [managedObjectContext executeFetchRequest:fetch error:nil];
    
    for ( DiscountObject *object in objectsFound) {
        NSLog(@"name: %@ address: %@ latitude: %@ longitude: %@", object.name, object.address, object.geoLatitude, object.geoLongitude);
    
    }
    //[self.dataSource  init];
    
    NSFetchRequest *fetch1=[[NSFetchRequest alloc] init];
    [fetch1 setEntity:[NSEntityDescription entityForName:@"Category"
                                 inManagedObjectContext:managedObjectContext]];
    //[fetch setPredicate:objectsFind];
    /*NSArray */
    objectsFound1 = [managedObjectContext executeFetchRequest:fetch1 error:nil];
    NSMutableArray *fetchArr = [[NSMutableArray alloc]init];
    //NSString *first
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
        
    //}
    

    /*cell.addressLabel.text = [NSString stringWithFormat: @"Cell #%i",indexPath.row];*/
    
     

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Accessory tapped %@", indexPath);
}


@end
