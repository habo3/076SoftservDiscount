//
//  CustomCalloutView.h
//  SoftServeDP
//
//  Created by Mykola on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CustomCalloutViewDelegate;


@interface CustomCalloutView : UIView

@property (nonatomic, unsafe_unretained) id <CustomCalloutViewDelegate> delegate;
@property (nonatomic, copy) NSString *title, *subtitle; 
@property (nonatomic, retain) UIView *leftAccessoryView, *rightAccessoryView;
@property (nonatomic, retain) UIView *titleView, *subtitleView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) CGPoint calloutOffset;


- (void)presentCalloutFromRect:(CGRect)rect inView:(UIView *)view constrainedToView:(UIView *)constrainedView ;

- (void)presentCalloutFromRect:(CGRect)rect inLayer:(CALayer *)layer constrainedToLayer:(CALayer *)constrainedLayer ;

- (void)dismissCalloutAnimated;

@end


@protocol CustomCalloutViewDelegate <NSObject>
@optional

- (NSTimeInterval)calloutView:(CustomCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset;
- (void)calloutViewDidAppear:(CustomCalloutView *)calloutView;
- (void)calloutViewDidDisappear:(CustomCalloutView *)calloutView;

@end