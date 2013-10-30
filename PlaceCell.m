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

- (id) initPlaceCellWithTable:(UITableView *)tableView withIdentifer:(NSString *)identifer
{
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    return cell;
}

- (PlaceCell *)customCellFromDiscountObject:(CDDiscountObject *)object WithTableView:(UITableView *)tableView WithCurrentLocation:(CLLocation *)currentLocation
{
    [self initViews];
    self.nameLabel.text = object.name;
    self.addressLabel.text = object.address;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
    if(geoLocationIsON)
    {
        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[[object.geoPoint valueForKey:@"latitude" ] doubleValue]
                                                                longitude:[[object.geoPoint valueForKey:@"longitude" ] doubleValue]];
        double distance = [currentLocation distanceFromLocation:objectLocation];
        if (distance > 999){
            self.distanceLabel.text = [NSString stringWithFormat:@"%.0fкм", distance/1000];
        }
        else {
            self.distanceLabel.text = [NSString stringWithFormat:@"%dм",(int)distance];
        }
    }
    else
    {
        self.detailsDistanceBackground.hidden = YES;
        self.distanceLabel.hidden = YES;
    }
    CDCategory *dbCategory = [object.categorys anyObject];
    NSString *symbol = dbCategory.fontSymbol;
    NSString *tmpText = [IconConverter ConvertIconText:symbol];
    UIFont *font = [UIFont fontWithName:@"icons" size:20];
    self.iconLabel.textColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
    self.iconLabel.font = font;
    self.iconLabel.text = tmpText;
    self.iconLabel.textAlignment = UITextAlignmentCenter;
    return self;
}

- (void)initViews
{
    self.rectangleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1].CGColor;
    self.rectangleView.layer.borderWidth = 1.0f;
    self.rectangleView.layer.cornerRadius = 10;
    self.circleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1].CGColor;
    self.circleView.layer.borderWidth = 1.0f;
    self.circleView.layer.cornerRadius = self.circleView.bounds.size.width/2;
}

@end
