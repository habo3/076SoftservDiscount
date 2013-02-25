//
//  PlaceCell.h
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountObject.h"
@interface PlaceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *circle;
@property (weak, nonatomic) IBOutlet UIView *roundRectBg;
@property (strong,nonatomic) IBOutlet UILabel *nameLabel;
@property (strong,nonatomic) IBOutlet UILabel *addressLabel;
//@property (strong,nonatomic) IBOutlet UIImageView *Image;
//@property (assign,nonatomic) DiscountObject *selectedObject;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buttonImage;

@end
