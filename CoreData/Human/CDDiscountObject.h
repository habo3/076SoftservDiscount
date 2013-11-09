#import "_DiscountObject.h"

@interface CDDiscountObject : _DiscountObject {}
// Custom logic goes here.

+(id)createWithDictionary:object andContext:managedObjectContext;

@end
