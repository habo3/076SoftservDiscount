//
//  CustomCalloutView.m
//  SoftServeDP
//
//  Created by Mykola on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "CustomCalloutView.h"


@interface UIView (CustomFrameAdditions)
@property (nonatomic, assign) CGPoint $origin;
@property (nonatomic, assign) CGSize $size;
@property (nonatomic, assign) CGFloat $x, $y, $width, $height; 
@property (nonatomic, assign) CGFloat $left, $top, $right, $bottom; 
@end


#define CALLOUT_MIN_WIDTH 75 
#define CALLOUT_HEIGHT 70 
#define CALLOUT_DEFAULT_WIDTH 153 
#define TITLE_MARGIN 17 
#define TITLE_TOP 11 
#define TITLE_SUB_TOP 3 
#define TITLE_HEIGHT 32 
#define SUBTITLE_TOP 25 
#define SUBTITLE_HEIGHT 12 
#define TITLE_ACCESSORY_MARGIN 6 
#define ACCESSORY_MARGIN 14 
#define ACCESSORY_TOP 8 
#define ACCESSORY_HEIGHT 32 
#define BETWEEN_ACCESSORIES_MARGIN 7 
#define ANCHOR_MARGIN 37 
#define BOTTOM_ANCHOR_MARGIN 10 
#define TOP_SHADOW_BUFFER 2 
#define BOTTOM_SHADOW_BUFFER 5 
#define OFFSET_FROM_ORIGIN 5 
#define ANCHOR_HEIGHT 14 
#define ANCHOR_MARGIN_MIN 24 

@implementation CustomCalloutView {
    UILabel *titleLabel, *subtitleLabel;
    UIImageView *leftCap, *rightCap, *topAnchor, *bottomAnchor, *leftBackground, *rightBackground;
    
    BOOL popupCancelled;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIView *)titleViewOrDefault {
    if (self.titleView)

        return self.titleView;
    else {
        if (!titleLabel) {

            titleLabel = [UILabel new];
            titleLabel.$height = TITLE_HEIGHT;
            titleLabel.opaque = NO;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:12];
            titleLabel.textColor = [UIColor blackColor];
        }
        return titleLabel;
    }
}

- (UIView *)subtitleViewOrDefault {
    if (self.subtitleView)

        return self.subtitleView;
    else {
        if (!subtitleLabel) {

            subtitleLabel = [UILabel new];
            subtitleLabel.$height = SUBTITLE_HEIGHT;
            subtitleLabel.opaque = NO;
            subtitleLabel.backgroundColor = [UIColor clearColor];
            subtitleLabel.font = [UIFont systemFontOfSize:9];
            subtitleLabel.textColor = [UIColor blackColor];
        }
        return subtitleLabel;
    }
}

- (void)rebuildSubviews {
    // remove and re-add  subviews
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setNeedsDisplay];
    
    if (self.titleViewOrDefault) [self addSubview:self.titleViewOrDefault];
    if (self.subtitleViewOrDefault) [self addSubview:self.subtitleViewOrDefault];
    if (self.leftAccessoryView) [self addSubview:self.leftAccessoryView];
    if (self.rightAccessoryView) [self addSubview:self.rightAccessoryView];
}

- (CGFloat)innerContentMarginLeft {
    if (self.leftAccessoryView)
        return ACCESSORY_MARGIN + self.leftAccessoryView.$width + TITLE_ACCESSORY_MARGIN;
    else
        return TITLE_MARGIN;
}

- (CGFloat)innerContentMarginRight {
    if (self.rightAccessoryView)
        return ACCESSORY_MARGIN + self.rightAccessoryView.$width + TITLE_ACCESSORY_MARGIN;
    else
        return TITLE_MARGIN;
}

- (CGFloat)calloutHeight {

    return CALLOUT_HEIGHT;
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    if (size.width < CALLOUT_MIN_WIDTH)
        return CGSizeMake(CALLOUT_DEFAULT_WIDTH, self.calloutHeight);
    
    CGFloat margin = self.innerContentMarginLeft + self.innerContentMarginRight;
    
    // textWidth
    CGFloat availableWidthForText = size.width - margin;
    if (availableWidthForText < 0)
        availableWidthForText = 0;
    
    CGSize preferredTitleSize = [self.titleViewOrDefault sizeThatFits:CGSizeMake(availableWidthForText, TITLE_HEIGHT)];
    CGSize preferredSubtitleSize = [self.subtitleViewOrDefault sizeThatFits:CGSizeMake(availableWidthForText, SUBTITLE_HEIGHT)];
    
    // optimize width 
    CGFloat preferredWidth;
    
    //text checking
    if (preferredTitleSize.width >= 0.000001 || preferredSubtitleSize.width >= 0.000001) {
        preferredWidth = fmaxf(preferredTitleSize.width, preferredSubtitleSize.width) + margin;
    }
    else {

        preferredWidth = self.leftAccessoryView.$width + self.rightAccessoryView.$width + ACCESSORY_MARGIN*2;
        if (self.leftAccessoryView && self.rightAccessoryView)
            preferredWidth += BETWEEN_ACCESSORIES_MARGIN;
    }
    
    preferredWidth = fmaxf(preferredWidth, CALLOUT_MIN_WIDTH);
    
    return CGSizeMake(fminf(preferredWidth, size.width), self.calloutHeight);
}


- (void)presentCalloutFromRect:(CGRect)rect inView:(UIView *)view constrainedToView:(UIView *)constrainedView {
    [self presentCalloutFromRect:rect inLayer:view.layer ofView:view constrainedToLayer:constrainedView.layer ];
}

- (void)presentCalloutFromRect:(CGRect)rect inLayer:(CALayer *)layer constrainedToLayer:(CALayer *)constrainedLayer  {
    [self presentCalloutFromRect:rect inLayer:layer ofView:nil constrainedToLayer:constrainedLayer ];
}


- (void)presentCalloutFromRect:(CGRect)rect inLayer:(CALayer *)layer ofView:(UIView *)view constrainedToLayer:(CALayer *)constrainedLayer  {

    
    // position in layer coordinates 
    CGRect constrainedRect = [constrainedLayer convertRect:constrainedLayer.bounds toLayer:layer];
    [self rebuildSubviews];
    
    // set title/subtitle
    titleLabel.text = self.title;
    subtitleLabel.text = self.subtitle;
    
    // sizing
    self.$size = [self sizeThatFits:CGSizeMake(constrainedRect.size.width, self.calloutHeight + 10)];
    
    //anchor position
    CGFloat anchorX = CGRectGetMidX(rect);
    CGFloat anchorY = CGRectGetMinY(rect);
    CGFloat calloutX = roundf(CGRectGetMidX(constrainedRect) - self.$width / 2);
    
    // posibly max/min positionX
    CGFloat minPointX = calloutX + ANCHOR_MARGIN;
    CGFloat maxPointX = calloutX + self.$width - ANCHOR_MARGIN;
    
    CGFloat adjustX = 0;
    if (anchorX < minPointX) adjustX = anchorX - minPointX;
    if (anchorX > maxPointX) adjustX = anchorX - maxPointX;
    
    // add the callout to the layer/view
    if (view)
        [view addSubview:self];
    else
        [layer addSublayer:self.layer];
    
    CGPoint calloutOrigin = {
        .x = calloutX + adjustX,
        .y =  anchorY - self.calloutHeight + BOTTOM_ANCHOR_MARGIN
    };
    
    self.$origin = calloutOrigin;
    
    // set the *actual* anchor point 
    CGPoint anchorPoint = [layer convertPoint:CGPointMake(anchorX, anchorY) toLayer:self.layer];
    anchorPoint.x /= self.$width;
    anchorPoint.y /= self.$height;
    self.layer.anchorPoint = anchorPoint;
    
    self.$origin = calloutOrigin;
    
    // layout
    [self setNeedsLayout];
    [self layoutIfNeeded];
        
    self.hidden = NO;
    
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    return
    [self.leftAccessoryView pointInside:[self.leftAccessoryView convertPoint:point fromView:self] withEvent:nil] ||
    [self.rightAccessoryView pointInside:[self.rightAccessoryView convertPoint:point fromView:self] withEvent:nil] ||
    [self.titleView pointInside:[self.titleView convertPoint:point fromView:self] withEvent:nil] ||
    [self.subtitleView pointInside:[self.subtitleView convertPoint:point fromView:self] withEvent:nil];
}

- (void)dismissCalloutAnimated {
    
    popupCancelled = YES;
    [self removeFromParent];
}

- (void)removeFromParent {
    
    if (self.superview)
        [self removeFromSuperview];
    else 
        [self.layer removeFromSuperlayer];
}


- (CGFloat)centeredPositionOfView:(UIView *)view ifSmallerThan:(CGFloat)height {
    return view.$height < height ? floorf(height/2 - view.$height/2) : 0;
}

- (CGFloat)centeredPositionOfView:(UIView *)view relativeToView:(UIView *)parentView {
    return (parentView.$height - view.$height) / 2;
}

- (void)layoutSubviews {
    
    //title
    self.titleViewOrDefault.$x = self.innerContentMarginLeft;
    self.titleViewOrDefault.$y = (self.subtitleView || self.subtitle.length ? TITLE_SUB_TOP : TITLE_TOP);
    self.titleViewOrDefault.$width = self.$width - self.innerContentMarginLeft - self.innerContentMarginRight;
    
    //subtitle
    self.subtitleViewOrDefault.$x = self.titleViewOrDefault.$x;
    self.subtitleViewOrDefault.$y = SUBTITLE_TOP;
    self.subtitleViewOrDefault.$width = self.titleViewOrDefault.$width;
    
    //leftAccessory
    self.leftAccessoryView.$x = ACCESSORY_MARGIN;
    self.leftAccessoryView.$y = ACCESSORY_TOP + [self centeredPositionOfView:self.leftAccessoryView ifSmallerThan:ACCESSORY_HEIGHT];
    
    //rightAccessory
    self.rightAccessoryView.$x = self.$width-ACCESSORY_MARGIN-self.rightAccessoryView.$width;
    self.rightAccessoryView.$y = ACCESSORY_TOP + [self centeredPositionOfView:self.rightAccessoryView ifSmallerThan:ACCESSORY_HEIGHT];

}

- (void)drawRect:(CGRect)rect {
    
    
    
    CGSize anchorSize = CGSizeMake(27, ANCHOR_HEIGHT);
    CGFloat anchorX = roundf(self.layer.anchorPoint.x * self.$width - anchorSize.width / 2);
    CGRect anchorRect = CGRectMake(anchorX, 0, anchorSize.width, anchorSize.height);
    
    // make sure the anchor is not too close to the end caps
    if (anchorRect.origin.x < ANCHOR_MARGIN_MIN)
        anchorRect.origin.x = ANCHOR_MARGIN_MIN;
    
    else if (anchorRect.origin.x + anchorRect.size.width > self.$width - ANCHOR_MARGIN_MIN)
        anchorRect.origin.x = self.$width - anchorRect.size.width - ANCHOR_MARGIN_MIN;
    
    // determine size
    CGFloat stroke = 1.0;
    CGFloat radius = [UIScreen mainScreen].scale == 1 ? 4.5 : 6.0;
    
    rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + TOP_SHADOW_BUFFER, self.bounds.size.width, self.bounds.size.height - ANCHOR_HEIGHT);
    rect.size.width -= stroke + 14;
    rect.size.height -= stroke * 2 + TOP_SHADOW_BUFFER + BOTTOM_SHADOW_BUFFER + OFFSET_FROM_ORIGIN;
    rect.origin.x += stroke / 2.0 + 7;
    rect.origin.y += stroke / 2.0;
    
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor *fillColor = [UIColor colorWithRed: 1 green: 0.733 blue: 0.20 alpha: 1];
    UIColor *shadowBlack = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.47];
    UIColor *strokeColor = [UIColor colorWithWhite:1 alpha:0.9];

    CGFloat backgroundStrokeWidth = 2;
    
    // Frames
    CGRect frame = rect;

    // Callout
    {
        CGContextSaveGState(context);
        
        // Background Drawing
        UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
        [backgroundPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + radius)];
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - radius)]; // left
        [backgroundPath addArcWithCenter:CGPointMake(CGRectGetMinX(frame) + radius, CGRectGetMaxY(frame) - radius) radius:radius startAngle:M_PI endAngle:M_PI / 2 clockwise:NO]; // bottom-left corner
        
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMaxY(frame))];
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMinX(anchorRect) + anchorRect.size.width / 2, CGRectGetMaxY(frame) + anchorRect.size.height)];
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMaxY(frame))];
        
        
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame) - radius, CGRectGetMaxY(frame))]; // bottom
        [backgroundPath addArcWithCenter:CGPointMake(CGRectGetMaxX(frame) - radius, CGRectGetMaxY(frame) - radius) radius:radius startAngle:M_PI / 2 endAngle:0.0f clockwise:NO]; // bottom-right corner
        
        [backgroundPath addLineToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + radius)]; // right
        [backgroundPath addArcWithCenter:CGPointMake(CGRectGetMaxX(frame) - radius, CGRectGetMinY(frame) + radius) radius:radius startAngle:0.0f endAngle:-M_PI / 2 clockwise:NO]; // top-right corner
        
        
        
        [backgroundPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + radius, CGRectGetMinY(frame))]; // top
        [backgroundPath addArcWithCenter:CGPointMake(CGRectGetMinX(frame) + radius, CGRectGetMinY(frame) + radius) radius:radius startAngle:-M_PI / 2 endAngle:M_PI clockwise:NO]; // top-left corner
        [backgroundPath closePath];
        
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, CGSizeMake(0.2,3.0), 2.1,shadowBlack.CGColor);
        [fillColor setFill];
        [backgroundPath fill];
        
        //CGContextSetLineWidth(context, backgroundStrokeWidth);
        CGContextStrokePath(context);
        
        [strokeColor setStroke];
        backgroundPath.lineWidth = backgroundStrokeWidth;
        [backgroundPath strokeWithBlendMode:kCGBlendModeLighten alpha:1];
        
        CGContextRestoreGState(context);
    }
    CGColorSpaceRelease(colorSpace);
}

@end


#pragma mark - UIView frame helpers


@implementation UIView (CustomFrameAdditions)

- (CGPoint)$origin { return self.frame.origin; }
- (void)set$origin:(CGPoint)origin { self.frame = (CGRect){ .origin=origin, .size=self.frame.size }; }

- (CGFloat)$x { return self.frame.origin.x; }
- (void)set$x:(CGFloat)x { self.frame = (CGRect){ .origin.x=x, .origin.y=self.frame.origin.y, .size=self.frame.size }; }

- (CGFloat)$y { return self.frame.origin.y; }
- (void)set$y:(CGFloat)y { self.frame = (CGRect){ .origin.x=self.frame.origin.x, .origin.y=y, .size=self.frame.size }; }

- (CGSize)$size { return self.frame.size; }
- (void)set$size:(CGSize)size { self.frame = (CGRect){ .origin=self.frame.origin, .size=size }; }

- (CGFloat)$width { return self.frame.size.width; }
- (void)set$width:(CGFloat)width { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=width, .size.height=self.frame.size.height }; }

- (CGFloat)$height { return self.frame.size.height; }
- (void)set$height:(CGFloat)height { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=self.frame.size.width, .size.height=height }; }

- (CGFloat)$left { return self.frame.origin.x; }
- (void)set$left:(CGFloat)left { self.frame = (CGRect){ .origin.x=left, .origin.y=self.frame.origin.y, .size.width=fmaxf(self.frame.origin.x+self.frame.size.width-left,0), .size.height=self.frame.size.height }; }

- (CGFloat)$top { return self.frame.origin.y; }
- (void)set$top:(CGFloat)top { self.frame = (CGRect){ .origin.x=self.frame.origin.x, .origin.y=top, .size.width=self.frame.size.width, .size.height=fmaxf(self.frame.origin.y+self.frame.size.height-top,0) }; }

- (CGFloat)$right { return self.frame.origin.x + self.frame.size.width; }
- (void)set$right:(CGFloat)right { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=fmaxf(right-self.frame.origin.x,0), .size.height=self.frame.size.height }; }

- (CGFloat)$bottom { return self.frame.origin.y + self.frame.size.height; }
- (void)set$bottom:(CGFloat)bottom { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=self.frame.size.width, .size.height=fmaxf(bottom-self.frame.origin.y,0) }; }

@end
