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

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // dynamic layout logic:
    if (_distanceLabel.hidden)
    {
        if((!_addressLabel.text) ||  ([_addressLabel.text isEqual:@""]) )
        {
            _nameLabel.frame = CGRectMake( 53, (self.frame.size.height-21)/2, 228, 21 );
        }
        else
        {
            _nameLabel.frame = CGRectMake( 53, (self.frame.size.height-21-14)/2, 228, 21);
            _addressLabel.frame = CGRectMake( 53, _nameLabel.frame.origin.y+14, 228, 21 );
        }
    }
    
}

@end
