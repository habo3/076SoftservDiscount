#import "CDDiscountObject.h"


@interface CDDiscountObject ()

// Private interface goes here.

@end


@implementation CDDiscountObject

+(id)createWithDictionary:(id)object andContext:(id)managedObjectContext
{
    if ([self isDiscountObjectValid:object]) {
        CDDiscountObject *newDiscountObject = [NSEntityDescription insertNewObjectForEntityForName:@"CDDiscountObject" inManagedObjectContext:managedObjectContext];
        
        for (NSString *key in object) {
            if ([key isEqualToString:@"responsiblePersonInfo"]) {
                continue;
            }
            if ([key isEqualToString:@"description"]) {
                if (![[object valueForKey:key] isKindOfClass:[NSNull class]]) {
                    [newDiscountObject setValue:[object valueForKey:key] forKey:@"descriptionn"];
                }
                continue;
            }
            if ([key isEqualToString:@"pulse"]) {
                if (![[object valueForKey:key] isKindOfClass:[NSNull class]]) {
                    [newDiscountObject setValue:[object valueForKey:key] forKey:key];
                }
                continue;
            }
            if ([key isEqualToString:@"id"]) {
                [newDiscountObject setValue:[[object valueForKey:key] stringValue] forKey:key];
                continue;
            }
            if ([key isEqualToString:@"category"]) {
                NSMutableArray *tempCategory = [[NSMutableArray alloc] init];
                for (NSNumber *idNumber in [object valueForKey:key]) {
                    [tempCategory addObject:[idNumber stringValue]];
                }
                [newDiscountObject setValue:tempCategory forKey:key];
                continue;
            }
            
            [newDiscountObject setValue:[object valueForKey:key] forKey:key];
            
        }
        return newDiscountObject;
    }
    return nil;
}


#pragma mark - Check is Discount object valid
+(BOOL)isDiscountObjectValid:(NSDictionary*)object
{
    
    if ([[[object valueForKey:@"geoPoint"] valueForKey:@"latitude"] doubleValue]== 0.0 && [[[object valueForKey:@"geoPoint"] valueForKey:@"longitude"] doubleValue] == 0.0)
    {
        return NO;
    }
    
    if (![[object valueForKey:@"logo"] isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    if (![[object valueForKey:@"address"] isKindOfClass:[NSString class]])
    {
        return NO;
    }
    
    if ([[[object valueForKey:@"discount"] valueForKey:@"from" ] isKindOfClass:[NSNull class]] || [[[object valueForKey:@"discount"] valueForKey:@"to" ] isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return YES;
}


@end
