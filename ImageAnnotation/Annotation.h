//
//  Annotation.h
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "DiscountObject.h"

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic) UIImage *pintype;
@property (nonatomic) UIView *leftImage;
@property (nonatomic,assign) DiscountObject *object;
@property (nonatomic,assign)CLLocationCoordinate2D coordinate;
@end
