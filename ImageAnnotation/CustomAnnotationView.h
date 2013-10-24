//
//  CustomAnnotationView.h
//  SoftServeDP
//
//  Created by Mykola on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomCalloutView.h"


@interface CustomAnnotationView : MKAnnotationView
@property (strong, nonatomic) CustomCalloutView *calloutView;
@property (nonatomic) BOOL isClusterPin;
@end