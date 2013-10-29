//
//  PlaceCell.h
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountObject.h"
#import "Category.h"
#import "IconConverter.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface PlaceCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel *nameLabel;
@property (strong,nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailsDistanceBackground;
@property (strong, nonatomic) IBOutlet UIView *circleView; 
@property (strong, nonatomic) IBOutlet UIView *rectangleView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buttonImage;

//-(PlaceCell *) getCustomCellFromDiscountObject:(DiscountObject *)object onTableView:(UITableView *)tableView withCurrentLocation: (CLLocation *)currentLocation;
-(void) initViews;

@end
