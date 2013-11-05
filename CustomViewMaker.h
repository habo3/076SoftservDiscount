//
//  CustomViewMaker.h
//  SoftServe Discount
//
//  Created by agavrish on 05.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomViewMaker : NSObject

+ (void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius;

+ (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage;

+ (void) customNavigationBarForView:(UIViewController *) view;

@end
