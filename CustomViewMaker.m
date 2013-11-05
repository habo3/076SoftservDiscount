//
//  CustomViewMaker.m
//  SoftServe Discount
//
//  Created by agavrish on 05.11.13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "CustomViewMaker.h"

@implementation CustomViewMaker

+(void)roundView:(UIView *)view onCorner:(UIRectCorner)rectCorner radius:(float)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:rectCorner
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    [view.layer setMask:maskLayer];
}

+ (UIImage *)setText:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)color onImage:(UIImage*)startImage
{
        NSString *tmpText = @"";
        CGRect rect = CGRectZero;
        
        double margin = 3.0;
        float fontsize = (startImage.size.width - 2 * margin);
        
        
        if([font isKindOfClass:[UIFont class]])
        {
            // size of custom text in image
            float ownHeight;
            float ownWidth;
            fontsize = fontsize/3;
            font = [font fontWithSize:fontsize];
            if([startImage isEqual:[UIImage imageNamed:@"cluster"]])
            {
                tmpText = text;
                
                ownWidth = (0.652 - text.length * 0.08) * startImage.size.width;
                ownHeight = 0.48 * startImage.size.height;
            }
            else
            {
                tmpText = [CustomViewMaker ConvertIconText:text];
                ownWidth = 0.49 * startImage.size.width;
                ownHeight = 0.4 * startImage.size.height;
            }
            rect = CGRectMake(ownWidth - font.pointSize/2, ownHeight - font.pointSize/2, startImage.size.width, startImage.size.height);
        }
        else
        {
            fontsize = text.length > 5 ? 7.5 : 9;
            
            font = [UIFont systemFontOfSize:fontsize];
            font = [UIFont boldSystemFontOfSize:fontsize];
            margin = (startImage.size.width - font.pointSize * text.length/1.85)/2;
            rect = CGRectMake(margin, (startImage.size.height - font.pointSize)/2, startImage.size.width, startImage.size.height);
            tmpText = text;
        }
        
        //work with image
        UIGraphicsBeginImageContextWithOptions(startImage.size,NO, 0.0);
        
        [startImage drawInRect:CGRectMake(0,0,startImage.size.width,startImage.size.height)];
        [color set];
        
        //draw text on image and save result
        [tmpText drawInRect:CGRectIntegral(rect) withFont:font];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;
}

+ (void) customNavigationBarForView:(UIViewController *) view
{
    UILabel *navigationTitle = [[UILabel alloc] init];
    navigationTitle.backgroundColor = [UIColor clearColor];
    navigationTitle.font = [UIFont boldSystemFontOfSize:20.0];
    navigationTitle.textColor = [UIColor blackColor];
    view.navigationItem.titleView = navigationTitle;
    navigationTitle.text = view.navigationItem.title;
    [navigationTitle sizeToFit];
}

+(NSString*)ConvertIconText:(NSString*)text
{
    
    NSString *tmpText =@"";
    NSString *cuttedSymbol = [text stringByReplacingOccurrencesOfString:@"&#" withString:@"0"];
    
    //converting Unicode Character String (0xe00b) to UTF32Char
    UTF32Char myChar = 0;
    NSScanner *myConvert = [NSScanner scannerWithString:cuttedSymbol];
    [myConvert scanHexInt:(unsigned int *)&myChar];
    
    //set data to string
    NSData *utf32Data = [NSData dataWithBytes:&myChar length:sizeof(myChar)];
    tmpText = [[NSString alloc] initWithData:utf32Data encoding:NSUTF32LittleEndianStringEncoding];
    return tmpText;
}

@end
