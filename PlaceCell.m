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
    self.discountImage.image = [UIImage imageNamed:@"zeroCellBackgroundImg.png"] ;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), ^{
        NSString *http = @"http://softserve.ua";
        NSString *imageUrl = [http stringByAppendingString:[object.logo valueForKey:@"src"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.discountImage.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0].CGColor;
            self.discountImage.layer.borderWidth = 1.0f;
            self.discountImage.image = image;
        });
    });

    
    return self;
}

- (void)initViews
{
    self.rectangleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0].CGColor;
    self.rectangleView.layer.borderWidth = 1.0f;
    self.rectangleView.layer.cornerRadius = 10;
}

@end
