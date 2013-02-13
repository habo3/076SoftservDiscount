//
//  CustomAnnotationView.m
//  SoftServeDP
//
//  Created by Mykola on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView


- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *calloutMaybe = [self.calloutView hitTest:[self.calloutView convertPoint:point fromView:self] withEvent:event];
    return calloutMaybe ?: [super hitTest:point withEvent:event];
}



@end
