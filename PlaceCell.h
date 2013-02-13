//
//  PlaceCell.h
//  ListView
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel *nameLabel;
@property (strong,nonatomic) IBOutlet UILabel *addressLabel;
@property (strong,nonatomic) IBOutlet UIImageView *Image;

@end
