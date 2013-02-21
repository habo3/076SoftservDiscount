//
//  DetailsViewController.m
//  SoftServeDP
//
//  Created by Bogdan on 19.02.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailsViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *distanceToObject;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *webSite;

@property (weak, nonatomic) IBOutlet UIView *zeroCellBackgroundView;

@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;

@end

@implementation DetailsViewController
@synthesize discountObject;

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    //self.zeroCellBackgroundView.layer.borderWidth = 1.f;
    //self.zeroCellBackgroundView.layer.borderColor = [UIColor grayColor].CGColor;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.zeroCellBackgroundView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.zeroCellBackgroundView.bounds;
    maskLayer.path = maskPath.CGPath;
    [self.zeroCellBackgroundView.layer setMask:maskLayer];
    
    maskPath.lineWidth = 2;
   
   // [maskPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
//    [self.zeroCellBackgroundView.layer setBorderColor:[[UIColor grayColor]CGColor]];
//    [self.zeroCellBackgroundView.layer setBorderWidth:1];
    
    
    //set labels value
    NSSet *categories = discountObject.categories;
    NSManagedObject *category = [categories anyObject];
    NSString *categoryName = [category valueForKey:@"name"];
    NSLog(@"object name: %@ object category: %@", discountObject.name, categoryName);
    self.discount.text = [NSString stringWithFormat:@"%@%%",[discountObject.discountTo stringValue]];
    self.name.text = discountObject.name;
    self.category.text = categoryName;
    self.distanceToObject.text = @"distance";
    self.address.text = discountObject.address;
    NSSet *contacts = discountObject.contacts;
    for (NSManagedObject *contact in contacts) {
        NSString * type = [contact valueForKey:@"type"];
        if ([type isEqualToString:@"phone"]) {
            self.phone.text = [contact valueForKey:@"value"];
        }
        else if ([type isEqualToString:@"email"]){
            self.email.text = [contact valueForKey:@"value"];
        }
        else if ([type isEqualToString:@"site"]){
            self.webSite.text = [contact valueForKey:@"value"];
        }
    
    }
    

}


#pragma mark - Table view data source


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

- (void)viewDidUnload {
    [self setDiscount:nil];
    [self setName:nil];
    [self setCategory:nil];
    [self setDistanceToObject:nil];
    [self setAddress:nil];
    [self setPhone:nil];
    [self setEmail:nil];
    [self setWebSite:nil];
    [self setZeroCellBackgroundView:nil];
    [self setFavoritesButton:nil];
    [super viewDidUnload];
}
@end
