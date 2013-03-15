//
//  UICustomSwitch.m
//
//  Created by Hardy Macia on 10/28/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
//  Code can be freely redistruted and modified as long as the above copyright remains.
//

#import "UICustomSwitch.h"


@implementation UICustomSwitch
@synthesize on;


-(id)initWithFrame:(CGRect)rect
{
	if ((self=[super initWithFrame:CGRectMake(rect.origin.x+19,rect.origin.y,43,19)]))
	{
		[self awakeFromNib];
	}
	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor clearColor];

    
    UIImage *switchOnImage =[[UIImage imageNamed:@"switchON.png"] resizableImageWithCapInsets:
                             UIEdgeInsetsMake(0, 6, 0, 2)];
    UIImage *switchOffImage =[[UIImage imageNamed:@"switchOFF.png"] resizableImageWithCapInsets:
                             UIEdgeInsetsMake(0, 2, 0, 6)];
    
	[self setThumbImage:[UIImage imageNamed:@"switchThumb.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:switchOnImage forState:UIControlStateNormal];
	[self setMaximumTrackImage:switchOffImage forState:UIControlStateNormal];
	
	self.minimumValue = 0;
	self.maximumValue = 1;
	self.continuous = NO;
	
	self.on = NO;
	self.value = 0.0;

}



- (void)setOn:(BOOL)turnOn animated:(BOOL)animated;
{
	on = turnOn;
	
	if (animated)
	{
		[UIView	 beginAnimations:@"UICustomSwitch" context:nil];
		[UIView setAnimationDuration:0.2];
	}
	
	if (on)
	{
		self.value = 1.0;
	}
	else 
	{
		self.value = 0.0;
	}
	
	if (animated)
	{
		[UIView	commitAnimations];	
	}
}

- (void)setOn:(BOOL)turnOn
{
	[self setOn:turnOn animated:NO];
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSLog(@"preendTrackingWithtouch");
	[super endTrackingWithTouch:touch withEvent:event];
//	NSLog(@"postendTrackingWithtouch");
	m_touchedSelf = YES;
	
    on = (self.value >= 0.5f);
    
	[self setOn:on animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesBegan:touches withEvent:event];
	NSLog(@"touchesBegan");
	m_touchedSelf = NO;
	on = !on;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesEnded:touches withEvent:event];
	NSLog(@"touchesEnded");
	
	if (!m_touchedSelf)
	{
		[self setOn:on animated:YES];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}


@end
