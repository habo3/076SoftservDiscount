//
//  IconConverter.m
//  SoftServeDP
//
//  Created by Mykola on 2/27/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "IconConverter.h"

@implementation IconConverter

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
