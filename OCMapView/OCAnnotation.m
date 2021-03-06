//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"


@interface OCAnnotation ()
@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@end

@implementation OCAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        _annotationsInCluster = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
{
    self = [self init];
    if (self) {
        _coordinate = [annotation coordinate];
        [_annotationsInCluster addObject:annotation];
    }
    
    return self;
}

- (id)initWithOCAnnotation:(OCAnnotation *)annotation;
{
    self = [self init];
    if (self)
    {
        _coordinate = [annotation coordinate];
        _annotationsInCluster = [annotation.annotationsInCluster mutableCopy];
    }
    return self;
}

- (NSArray*)annotationsInCluster;
{
    return [_annotationsInCluster copy];
}

#pragma mark add / remove annotations

- (void)addAnnotation:(id<MKAnnotation>)annotation;
{
    [_annotationsInCluster addObject:annotation];
}

- (void)addAnnotations:(NSArray *)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation;
{
    [_annotationsInCluster removeObject:annotation];
}

- (void)removeAnnotations:(NSArray*)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

#pragma mark center coordinate

- (CLLocationCoordinate2D)coordinate;
{

    if (self.annotationsInCluster.count == 0)
    {
        CLLocationCoordinate2D cllocation;
        cllocation.latitude = 0.0;
        cllocation.longitude = 0.0;
        return cllocation;
    }
    
    // find max/min coords
    CLLocationCoordinate2D min = [self.annotationsInCluster[0] coordinate];
    CLLocationCoordinate2D max = [self.annotationsInCluster[0] coordinate];
    for (id<MKAnnotation> annotation in self.annotationsInCluster) {
        min.latitude = MIN(min.latitude, annotation.coordinate.latitude);
        min.longitude = MIN(min.longitude, annotation.coordinate.longitude);
        max.latitude = MAX(max.latitude, annotation.coordinate.latitude);
        max.longitude = MAX(max.longitude, annotation.coordinate.longitude);
    }
    
    // calc center
    CLLocationCoordinate2D center = min;
    center.latitude += (max.latitude-min.latitude)/2.0;
    center.longitude += (max.longitude-min.longitude)/2.0;
    
    return center;
}

#pragma mark equality

- (BOOL)isEqual:(OCAnnotation*)annotation;
{
    if (![annotation isKindOfClass:[OCAnnotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.annotationsInCluster isEqual:annotation.annotationsInCluster]);
}

@end

