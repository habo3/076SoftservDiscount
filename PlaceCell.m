//
//  PlaceCell.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "PlaceCell.h"


@implementation PlaceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initViews
{
    self.rectangleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1].CGColor;
    self.rectangleView.layer.borderWidth = 1.0f;
    self.rectangleView.layer.cornerRadius = 10;
    
    self.circleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1].CGColor;
    self.circleView.layer.borderWidth = 1.0f;
    self.circleView.layer.cornerRadius = self.circleView.bounds.size.width/2;
}
//
//-(PlaceCell *) getCustomCellFromDiscountObject:(DiscountObject *)object onTableView:(UITableView *)tableView withCurrentLocation: (CLLocation *)currentLocation
//{
//    NSString *cellIdentifer = @"Cell";
//    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
//    if (cell == nil) {
//        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
//    }
//    [self initViews];
//    cell.nameLabel.text = object.name ;
//    cell.addressLabel.text = object.address;
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
//    if(geoLocationIsON)
//    {
//        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[object.geoLatitude doubleValue]
//                                                                longitude:[object.geoLongitude doubleValue]];
//        double distance = [currentLocation distanceFromLocation:objectLocation];
//        if (distance > 999){
//            cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
//        }
//        else {
//            cell.distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
//        }
//    }
//    else
//    {
//        cell.detailsDistanceBackground.hidden = YES;
//        cell.distanceLabel.hidden = YES;
//    }
//    Category *dbCategory = [object.categories anyObject];
//    NSString *symbol = dbCategory.fontSymbol;
//    NSString *tmpText = [IconConverter ConvertIconText:symbol];
//    UIFont *font = [UIFont fontWithName:@"icons" size:20];
//    cell.iconLabel.textColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
//    cell.iconLabel.font = font;
//    cell.iconLabel.text = tmpText;
//    cell.iconLabel.textAlignment = UITextAlignmentCenter;
//    return cell;
//}

@end
