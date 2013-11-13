//
//  CALayer+setUIColor.m
//  SoftServeDP
//
//  Created by Andrew Gavrish on 23.02.13.
//  Copyright (c) 2013 Andrew Gavrish. All rights reserved.
//

#import "CALayer+setUIColor.h"

@implementation CALayer (setUIColor)

- (void) setBorderUIColor: (UIColor *) newBorderColor;
{
  self.borderColor = [newBorderColor CGColor];
}

@end
