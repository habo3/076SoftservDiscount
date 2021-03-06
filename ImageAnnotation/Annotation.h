//
//  Annotation.h
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "CDDiscountObject.h"
#import <MapKit/MKPointAnnotation.h>
#import <MapKit/MKAnnotation.h>
@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic, strong) NSString *identeficator;
@property (nonatomic) UIImage *pintype;
@property (nonatomic) UIView *leftImage;
@property (nonatomic,assign) CDDiscountObject *object;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@end
