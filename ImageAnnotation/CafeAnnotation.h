//
//  CafeAnnotation.h
//  ImageAnnotation
//
//  Created by Mykola on 1/14/13.
//  Copyright (c) 2013 Mykola. All rights reserved.
//
#import <MapKit/MapKit.h>

@interface CafeAnnotation : NSObject <MKAnnotation>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *pintype;
@property (nonatomic,copy) NSString *leftImage;
@property (nonatomic,assign)CLLocationCoordinate2D coordinate;
@end
