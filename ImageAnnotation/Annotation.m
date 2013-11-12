//
//  Annotation.m
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
@synthesize pintype;
@synthesize leftImage;
@synthesize object;
@synthesize identeficator = _identeficator;

- (BOOL)isEqual:(Annotation*)annotation;
{
    if (![annotation isKindOfClass:[Annotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.title isEqualToString:annotation.title] &&
            [self.identeficator isEqualToString:annotation.identeficator] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.pintype isEqual:annotation.pintype] &&
            [self.leftImage isEqual:annotation.leftImage] &&
            [self.object isEqual:annotation.object]);
}


@end
