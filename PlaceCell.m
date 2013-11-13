//
//  PlaceCell.m
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "PlaceCell.h"
#import "CDCoreDataManager.h"

@interface PlaceCell ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) CDCoreDataManager *coreDataManager;

@end

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

-(void)setDistanceLabelFromDiscountObject:(CDDiscountObject *)object WithCurrentLocation:(CLLocation *)currentLocation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL geoLocationIsON = [[userDefaults objectForKey:@"geoLocation"]boolValue]&&[CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
    if(geoLocationIsON)
    {
        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:[[object.geoPoint valueForKey:@"latitude" ] doubleValue]                                                                longitude:[[object.geoPoint valueForKey:@"longitude" ] doubleValue]];
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
}

-(void)setImageinCellFromObject:(CDDiscountObject*)object
{
    self.coreDataManager = [CDCoreDataManager sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, nil), ^{
       UIImage *image = [self.coreDataManager checkImageInObjectExistForDiscountObject:object];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.discountImage.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0].CGColor;
            self.discountImage.layer.borderWidth = 1.0f;
            if(image)
                self.activityIndicatorView.hidden = YES;
            self.discountImage.image = image;
        });
    });
}

- (PlaceCell *)customCellFromDiscountObject:(CDDiscountObject *)object WithTableView:(UITableView *)tableView WithCurrentLocation:(CLLocation *)currentLocation
{
    [self initViews];
    self.nameLabel.text = object.name;
    self.addressLabel.text = object.address;
    [self setDistanceLabelFromDiscountObject:object WithCurrentLocation:currentLocation];
    [self setImageinCellFromObject:object];
    
    return self;
}

- (void)initViews
{
    self.rectangleView.layer.borderColor = [UIColor colorWithRed:0.8039 green:0.8039 blue:0.8039 alpha:1.0].CGColor;
    self.rectangleView.layer.borderWidth = 1.0f;
    self.rectangleView.layer.cornerRadius = 10;
}

@end
