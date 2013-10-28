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

@end
